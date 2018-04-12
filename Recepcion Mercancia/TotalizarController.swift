//
//  TotalizarController.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 25/1/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class TotalizarController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var proveedor: Proveedor!
    var usuario: User!
    var articulo: Article!
    
    var articulos = [Article]()
    
    var numero_factura = ""
    
    // Si se va a relizar un segue a ArticleController usamos esta variable para detectar si es una edicion
    var isEdit = false
    
    // Cuando se selecciona un article se actualiza esta variable, por defecto es el primer articulo.
    var selectedArticle = 0
    
    @IBOutlet weak var articleTablewView: UITableView!
    @IBOutlet weak var numeroFacturaText: UITextField!
    @IBOutlet weak var usuarioLabel: UILabel!
    @IBOutlet weak var proveedorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleTablewView.delegate = self
        articleTablewView.dataSource = self
        
        // Mostramos datos de usuario y proveedor
        self.usuarioLabel.text = self.usuario.nombre
        self.proveedorLabel.text = self.proveedor.razon_social!
    }
    
    // Cuando damos tap en el view se quita el teclado
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func agregarArticulo(_ sender: Any) {
        self.performSegue(withIdentifier: "returnToArticle", sender: self)
    }
    
    func actualizarDeposito(){
        // Actualizar el inventario de los articulos recibidos
        for article in self.articulos {
            // Get the default deposit of article
            var auto_deposito: String?
            for deposito in article.auto_deposito! {
                if (deposito["default"] as! Bool == true){
                    auto_deposito = deposito["auto_deposito"] as! String?
                }
            }
            
            if (auto_deposito == nil && (article.auto_deposito?.count)! > 0) {
                auto_deposito = article.auto_deposito?[0]["auto_deposito"] as! String?
            }
            
            // Calculate the cant of article
            let cantidad = Double(article.cantidad_recibida!)! * Double(article.contenido_compras!)
            
            let params = [
                "auto_producto": "\(article.auto!)",
                "auto_deposito": "\(auto_deposito ?? "0000000001")",
                "cantidad": "\(cantidad)",
                "signo": "+"
            ]
            
            ToolsPaseo().consultPOST(path: "/UpdateDeposit", params: params){ data in
                if(data[0]["error"] == true){
                    self.dismiss(animated: false){
                        // create the alert
                        let alert = UIAlertController(title: "¡MENSAJE!", message: "\(data[0]["description"])", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "ACEPTAR", style: .cancel, handler: nil))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    self.dismiss(animated: false){
                        // create the alert
                        let alert = UIAlertController(title: "¡MENSAJE!", message: "¡Datos guardados exitosamente!", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { action in
                            
                            self.performSegue(withIdentifier: "backToProveedor", sender: self)
                        }))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    func procesoGuardado(){
        ToolsPaseo().loadingView(vc: self, msg: "Registrando en la base de datos")
        
        let device_name = UIDevice.current.name
        
        // Transform article object list to a article JSON array
        var object_array = "["
        var cont = 0
        
        for article in self.articulos {
            let json = JSON(article.toDict)
            
            if (cont == self.articulos.count - 1){
                object_array = "\(object_array)\(json)]"
            } else {
                object_array = "\(object_array)\(json),"
            }
            
            cont += 1
        }
        // done transform
        
        var obj: JSON = [
            "document_number": self.numero_factura,
            "razon_social": self.proveedor.razon_social!,
            "dir_fiscal":self.proveedor.dir_fiscal!,
            "ci_rif":self.proveedor.ci_rif!,
            "auto_proveedor":self.proveedor.auto!,
            "codigo_usuario":self.usuario.codigo!,
            "usuario":self.usuario.nombre!,
            "device":device_name,
            "articles": JSON.init(parseJSON: object_array)
        ]
        
        let full_json = JSON(obj.object)
        
        let params = [
            "json": "\(full_json)"
        ]
        
        ToolsPaseo().consultPOST(path: "/AddDocumentAndProdcuts", params: params){ data in
            if (data[0]["error"] == true){
                self.dismiss(animated: false){
                    // create the alert
                    let alert = UIAlertController(title: "¡MENSAJE!", message: "\(data[0]["description"])", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "ACEPTAR", style: .cancel, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                // Actualizar cantidades en el deposito
                self.actualizarDeposito()
            }
        
        }
    }
    
    @IBAction func guardarRecepcion(_ sender: Any) {
        self.numero_factura = "\(self.numeroFacturaText.text!)"
        
        if (self.numero_factura != "" && self.numero_factura.characters.count > 2) {
            self.procesoGuardado()
            
            //Eliminar locales
            Article().deleteArticles()
            Proveedor().deleteProvider()
        } else {
            // create the alert
            let alert = UIAlertController(title: "¡ERROR!", message: "¡NUMERO FACTURA VACIO!", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        
        }
        
    }
    
    @IBAction func editarArticulo(_ sender: Any) {
        if(self.articulo != nil){
            
            self.articulos.remove(at:self.selectedArticle)
            
            self.isEdit = true
            self.performSegue(withIdentifier: "returnToArticle", sender: self)
        }
    }
    
    
    // Tabla
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articulos.count
    }
    
    
    
    // Asignamos valores a las celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let articleCell = tableView.dequeueReusableCell(withIdentifier: "articleCell") as! ArticleItemCell
        let article = self.articulos[indexPath.row]
        articleCell.nombre = article.nombre
        articleCell.cantidad = article.cantidad_recibida
        articleCell.codigo = article.codigo
        return articleCell
    }
    
    
    // Asigamos el valor a la variable Proveedor con el selecionado
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.articulo = self.articulos[indexPath.row]
        self.selectedArticle = indexPath.row
    }
    
    // return to article
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "returnToArticle" {
            if let destination = segue.destination as? ArticuloController {
                destination.usuario = self.usuario
                destination.proveedor = self.proveedor
                destination.articulos = self.articulos
                
                if self.isEdit {
                    destination.articulo = self.articulo
                    destination.cantidad = self.articulo.cantidad_recibida!
                }
            }
        }
        if segue.identifier == "backToProveedor" {
            if let destination = segue.destination as? EscogerProveedor {
                destination.usuario = self.usuario
            }
        }
    }
}
