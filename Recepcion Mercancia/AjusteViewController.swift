//
//  AjusteViewController.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 10/10/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit
import SwiftyJSON

class AjusteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var articleCodeInput: UITextField!
    @IBOutlet weak var articleNameLabel: UILabel!
    @IBOutlet weak var articleQuantityInput: UITextField!    
    @IBOutlet weak var wareHouseTableView: UITableView!
    
    var usuario: User!
    var wareHouses = [Warehouse]()
    var articulo: Article!
    var selected: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userLabel.text = "\(usuario.nombre!)"
        
        wareHouseTableView.delegate = self
        wareHouseTableView.dataSource = self
        
        if articulo != nil {
            buscarProducto(code: articulo.codigo!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchArticle(_ sender: Any) {
        
        if (self.articleCodeInput.text!.characters.count > 0){
            if(self.articleCodeInput.text![0] == "*"){
                self.performSegue(withIdentifier: "irBuscarArticulo", sender: self)
            } else {
                buscarProducto(code: articleCodeInput.text!)
            }
        } else {
            self.performSegue(withIdentifier: "irBuscarArticulo", sender: self)
        }
    }
    
    @IBAction func setQuantity(_ sender: Any) {
        let number = NumberFormatter().number(from: articleQuantityInput.text ?? "0.00")
        if let number = number {
            wareHouses[selected].quantity = Double(number)
            wareHouseTableView.reloadData()
            articleQuantityInput.text = ""
        }
    }

    
    @IBAction func Save(_ sender: Any) {
        ToolsPaseo().loadingView(vc: self, msg: "Registrando en la base de datos")
        
        var cont = 1
        
        for w in wareHouses {            
            let params = [
                "auto_producto": "\(articulo.auto!)",
                "auto_deposito": "\(w.auto!)",
                "cantidad": "\(w.quantity ?? 0.000)",
                "signo": ""
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
                    if cont == self.wareHouses.count {
                        self.dismiss(animated: false){
                            // create the alert
                            let alert = UIAlertController(title: "¡MENSAJE!", message: "¡Datos guardados exitosamente!", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { action in
                                
                                self.performSegue(withIdentifier: "irMenu", sender: self)
                            }))
                            
                            // show the alert
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                cont = cont + 1
            }            
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        // create the alert
        let alert = UIAlertController(title: "¡MENSAJE!", message: "¿Deseas regresar al menu principal?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "ACEPTAR", style: .destructive, handler: { action in
            self.performSegue(withIdentifier: "irMenu", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: "CANCELAR", style: .cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

    func buscarProducto(code: String){
        wareHouses.removeAll()
        // Si todo OK realizamos la consulta para obtener los datos del articulo
        let params = [
            "code": code
        ]
        
        ToolsPaseo().consultPOST(path: "/GetArticle", params: params){ data in
            if (data[0]["error"] != true){
                // Populate the article object
                self.articulo = Article()
                self.articulo.nombre            = data["nombre"].string!
                self.articulo.codigo            = data["codigo"].string!
                self.articulo.auto              = data["auto"].string!
                self.articulo.contenido_compras = Int(data["contenido_compras"].string!)
                self.articulo.auto_deposito     = []
                
                // Agregar todos los depositos asociados al articulo a un array
                for (_,subJson):(String, JSON) in data["auto_deposito"] {
                    let w = Warehouse()
                    w.auto = subJson["auto_deposito"].string!
                    w.name = subJson["name"].string!
                    w.quantity = subJson["cantidad"].double!
                    self.wareHouses.append(w)
                }
                
                // Mostramos los datos
                self.articleNameLabel.text = "\(self.articulo.nombre!)"
                self.articleNameLabel.isHidden = false
                
                self.wareHouseTableView.reloadData()
            } else {
                // Si hubo algun error en la consulta mostramos el error
                
                // create the alert
                let alert = UIAlertController(title: "¡ERROR!", message: "¡El artículo que estás buscando no existe!", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    // Cuando damos tap en el view se quita el teclado
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Tabla
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wareHouses.count
    }
    
    // Asignamos valores a las celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wareHouseCell = tableView.dequeueReusableCell(withIdentifier: "wareHouseCell") as! WareHouseTableViewCell
        
        let w = wareHouses[indexPath.row]
        wareHouseCell.name = w.name!
        wareHouseCell.quantity = "\(w.quantity ?? 0.0)"
        return wareHouseCell
    }
    
    
    // Asigamos el valor a la variable Proveedor con el selecionado
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = indexPath.row
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "irMenu" {
            if let destination = segue.destination as? MenuViewController {
                destination.usuario = self.usuario
            }
        }
        
        if segue.identifier == "irBuscarArticulo" {
            if let destination = segue.destination as? BuscarArticulo {
                destination.usuario = self.usuario
                destination.searchQueryText = self.articleCodeInput.text ?? " "
                destination.tipoPantalla = "3"
            }
        }
    }

}
