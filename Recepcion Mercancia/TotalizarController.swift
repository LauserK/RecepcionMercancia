//
//  TotalizarController.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 25/1/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit
import SwiftyJSON

class TotalizarController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var proveedor: Proveedor!
    var usuario: User!
    var articulo: Article!
    
    var articulos = [Article]()
    
    var deposito = "0000000001"
    var numero_factura = ""
    var isEdit = false
    
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
    
    func updateAndShowMessage(auto_nuevo: String){
        ToolsPaseo().consultarDB(id: "open", sql: "UPDATE `sistema_contadores` SET `a_compras` = '\(auto_nuevo)' WHERE a_compras != '' LIMIT 1"){(data) in
            
            self.dismiss(animated: false){
                // create the alert
                let alert = UIAlertController(title: "¡MENSAJE!", message: "¡Datos guardados exitosamente!", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "ACEPTAR", style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func procesoGuardado(){
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fecha = formatter.string(from: date)
        formatter.dateFormat = "yyyy"
        let ano = formatter.string(from: date)
        formatter.dateFormat = "MM"
        let mes = formatter.string(from: date)
        let hour = Calendar.current.component(.hour, from: Date())
        let minutes = Calendar.current.component(.minute, from: Date())
        let hora = "\(hour):\(minutes)"
        let device = UIDevice.current.name
        
        
        // MARK.- HERE IS WHERE HAVE TO BE THE PROCEDURE TO REGISTER THE DOCUMENT

    }
    
    @IBAction func guardarRecepcion(_ sender: Any) {
        self.numero_factura = "\(self.numeroFacturaText.text!)"
        
        if (self.numero_factura != "" && self.numero_factura.characters.count > 2) {
            self.procesoGuardado()
        } else {
            // create the alert
            let alert = UIAlertController(title: "¡ERROR!", message: "¡NUMERO FACTURA VACIO!", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        
        }
        
    }
    
    @IBAction func editarArticulo(_ sender: Any) {
        if(self.articulo.nombre != nil && self.articulo.auto != nil){
            
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
        let newCell = tableView.dequeueReusableCell(withIdentifier: "articleCell") as! ArticleItemCell
        newCell.nombreLabel.text = self.articulos[indexPath.row].nombre
        newCell.cantidadLabel.text = self.articulos[indexPath.row].cantidad_recibida
        newCell.codigoLabel.text = self.articulos[indexPath.row].codigo
        return newCell
    }
    
    
    // Asigamos el valor a la variable Proveedor con el selecionado
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.articulo = Article()
        self.articulo.auto   = self.articulos[indexPath.row].auto
        self.articulo.nombre = self.articulos[indexPath.row].nombre
        self.articulo.codigo = self.articulos[indexPath.row].codigo
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
    }
}
