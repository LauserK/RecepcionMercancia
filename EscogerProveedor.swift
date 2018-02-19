//
//  ViewController.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 11/1/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class EscogerProveedor: UIViewController {
    // Vista en donde escogemos el proveedor y selecionasmos orden de compra
    var usuario: User!
    
    var proveedor = [
        "razon_social":"",
        "ci_rif": "",
        "auto":""
    ]
    
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var proveedorQuery: UITextField!
    
    @IBOutlet weak var searchProveedorBtn: UIButton!
    
    @IBAction func searchProveedor(_ sender: Any) {
        
        self.performSegue(withIdentifier: "irBuscarProveedor", sender: self)
        
    }
    
    @IBAction func seguirSinOCButtonAction(_ sender: Any) {
        
        if (self.proveedor["razon_social"] != ""){
            self.performSegue(withIdentifier: "moveToArticle", sender: self)
        }
        
    }
    
    
    public func setProveedor(text: String){
        self.proveedorQuery.text = text
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "irBuscarProveedor" {
            if let destination = segue.destination as? BuscarProveedor {
                destination.searchQueryText = self.proveedorQuery.text!
                destination.usuario = self.usuario
            }
        }
        
        if segue.identifier == "moveToArticle" {
            if let destination = segue.destination as? ArticuloController {
                destination.proveedor = self.proveedor
                destination.usuario = self.usuario
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userLabel.text = self.usuario.nombre
        
        self.proveedorQuery.text = self.proveedor["razon_social"]
        
        // Cuando se hace TAP en cualquier lugar oculta el keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // Cuando se hace tap quita el keyboard
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

class BuscarProveedor: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Vista para buscar proveedor y selecionar el proveedor
    var searchQueryText = ""
    var proveedores = [["","",""]]
    var proveedor = [
        "razon_social":"",
        "ci_rif": "",
        "auto":""
    ]
    
    var usuario: User!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var queryProveedorInput: UITextField!
    
    // Cuando damos tap en el view se quita el teclado
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func buscarProveedor(){
        var sql = "SELECT auto, razon_social, ci_rif, dir_fiscal FROM proveedores WHERE estatus = 'Activo'"
        
        var filtro = ""
        if (self.searchQueryText != ""){
            
            filtro = "\(filtro) AND razon_social LIKE '%\(self.searchQueryText)%' AND auto_departamento = '0000000008'"
            
        }
        
        // COntruimos el query con la base y el filtro
        sql = "\(sql)\(filtro)"
        
        // Buscamos todos los proveedores
        ToolsPaseo().consultarDB(id: "open", sql: sql){ data in
            
            self.proveedores = []
            // Se le da formato a los datos a un ARRAY
            for (_,subJson):(String, JSON) in data["data"] {
                var proveedor: [String] = []
                for (_, proveedorItem):(String, JSON) in subJson {
                    proveedor.append(proveedorItem.string!)
                }
                self.proveedores.append(proveedor)
            }
            
            // Actualizamos la tabla
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos el nombre de usuario
        
        self.queryProveedorInput.text = self.searchQueryText
        
        // buscamos todos los proveedores
        self.buscarProveedor()
    }
    
    // Tabla
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.proveedores.count
    }
    
    // Asignamos valores a las celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "proveedorItemCell") as! ProveedorCell
        newCell.setName(name: "\(self.proveedores[indexPath.row][1])")
        newCell.setRIF(rif: "\(self.proveedores[indexPath.row][2])")
        return newCell
    }
    
    // Asigamos el valor a la variable Proveedor con el selecionado
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.proveedor["auto"] = self.proveedores[indexPath.row][0]
        self.proveedor["razon_social"] = self.proveedores[indexPath.row][1]
        self.proveedor["ci_rif"] = self.proveedores[indexPath.row][2]
        self.proveedor["dir_fiscal"] = self.proveedores[indexPath.row][3]
    }
    
    @IBAction func buscarProveedorButton(_ sender: Any) {
        self.searchQueryText = self.queryProveedorInput.text!
        
        if (self.searchQueryText != ""){
            //Filtramos los proveedores
            self.buscarProveedor()
        }
    }
    
    @IBAction func elegirButton(_ sender: Any) {
        self.performSegue(withIdentifier: "returnToProveedor", sender: self)
        
    }
    
    // Preprara
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "returnToProveedor" {
            if let destination = segue.destination as? EscogerProveedor {
                destination.usuario = self.usuario
                destination.proveedor = self.proveedor
            }
        }
    }
}

// Clase la celda para elegir el proveedor en la vista de buscqueda
class ProveedorCell: UITableViewCell {
    
    @IBOutlet weak var proveedorName: UILabel!
    @IBOutlet weak var proveedorRIF: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        proveedorName.text = ""
        proveedorRIF.text  = ""
    }
    
    public func setName(name:String){
        self.proveedorName.text = name
    
    }
    
    public func setRIF(rif:String){
        self.proveedorRIF.text = rif
        
    }
    
    
}

