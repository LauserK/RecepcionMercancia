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
    
    // Objecto usuario
    var usuario: User!
    // Objecto proveedor
    var proveedor:Proveedor?
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var proveedorQuery: UITextField!
    @IBOutlet weak var searchProveedorBtn: UIButton!
    @IBOutlet weak var headerView: UIView!
    
    @IBAction func searchProveedor(_ sender: Any) {
        // al pulsar BUSCAR vamos a la vista correspondiente
        self.performSegue(withIdentifier: "irBuscarProveedor", sender: self)
        
    }
    
    @IBAction func seguirSinOCButtonAction(_ sender: Any) {
        // Al dar click a Segir sin Orden de Compra vamos a la vista de articulo
        if (self.proveedor != nil){
            Proveedor().saveProvider(proveedor: self.proveedor!)
            self.performSegue(withIdentifier: "moveToArticle", sender: self)
        } else {
            // create the alert
            let alert = UIAlertController(title: "¡ERROR!", message: "¡Debes de seleccionar el proveedor!", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .cancel, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        
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
        
        if segue.identifier == "irMenu" {
            if let destination = segue.destination as? MenuViewController {
                destination.usuario = self.usuario
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos el nombre de usuario en la parte superior
        self.userLabel.text = self.usuario.nombre
        
        // Si existe algun dato en el objeto proveedor lo mostramos
        self.proveedorQuery.text = self.proveedor?.razon_social
        
        // Cuando se hace TAP en cualquier lugar oculta el keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapHeader(sender:)))
        doubleTapGesture.numberOfTapsRequired = 2
        headerView.addGestureRecognizer(doubleTapGesture)
    }
    
    func handleDoubleTapHeader(sender: UITapGestureRecognizer){
        // create the alert
        let alert = UIAlertController(title: "¡ALERTA!", message: "¿DESEAS REGRESAR AL MENU PRINCIPAL?", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "SI", style: UIAlertActionStyle.destructive, handler: { action in
            self.performSegue(withIdentifier: "irMenu", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    // Cuando se hace tap quita el keyboard
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

class BuscarProveedor: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Vista para buscar proveedor y selecionar el proveedor
    var searchQueryText = ""
    // Arreglo con lista de proveedores que usaremos para mostrar en el list view
    var proveedores = [Proveedor]()
    // Objecto proveedor
    var proveedor:Proveedor!
    // Objecto Usuario
    var usuario: User!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var queryProveedorInput: UITextField!
    
    // Cuando damos tap en el view se quita el teclado
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func buscarProveedor(){
        // quitamos los datos anteriores
        self.proveedores.removeAll()
        
        // Pasamos los parametros
        let params = ["razon_social": "\(self.searchQueryText)"]
        // Ejecutamos el servicio
        ToolsPaseo().consultPOST(path: "/GetProveedores", params: params) { data in
            
            // agregamos datos al arreglo de proveedores
            for (_, subJson):(String, JSON) in data {
                let proveedor = Proveedor()
                proveedor.auto = subJson["auto"].string!
                proveedor.razon_social = subJson["razon_social"].string!
                proveedor.ci_rif = subJson["ci_rif"].string!
                proveedor.dir_fiscal = subJson["dir_fiscal"].string!
                self.proveedores.append(proveedor)
                
                // Actualizamos la tabla con los nuevos datos
                self.tableView.reloadData()
            }
        
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos el nombre de usuario
        self.queryProveedorInput.text = self.searchQueryText
        
        // buscamos todos los proveedores de inicio
        self.buscarProveedor()
    }
    
    // Tabla
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.proveedores.count
    }
    
    // Asignamos valores a las celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "proveedorItemCell") as! ProveedorCell
        newCell.setName(name: "\(self.proveedores[indexPath.row].razon_social!)")
        newCell.setRIF(rif: "\(self.proveedores[indexPath.row].ci_rif!)")
        return newCell
    }
    
    // Asigamos el valor a la variable Proveedor con el selecionado
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.proveedor = Proveedor()
        self.proveedor.auto = self.proveedores[indexPath.row].auto!
        self.proveedor.razon_social = self.proveedores[indexPath.row].razon_social!
        self.proveedor.ci_rif = self.proveedores[indexPath.row].ci_rif!
        self.proveedor.dir_fiscal = self.proveedores[indexPath.row].dir_fiscal!
    }
    
    @IBAction func buscarProveedorButton(_ sender: Any) {
        // Cuando damos click en BUSCAR
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

