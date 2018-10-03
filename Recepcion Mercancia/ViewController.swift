//
//  ViewController.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 11/1/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var userField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    // Objecto usuario
    var usuario: User!
    var articles = [Article]()
    var provider: Proveedor?
    
    // Verificar si existe una recepcion pendiente
    func verificarDatos(){
        self.articles = Article().getArticlesDevice()
        self.provider = Proveedor().getProvider()
        
        if self.provider?.razon_social != nil {
            let alert = UIAlertController(title: "¡DOCUMENTO PENDIENTE!", message: "Se encontró un documento pendiente del proveedor: \(self.provider!.razon_social!), ¿desea verificarlo?", preferredStyle: UIAlertControllerStyle.alert)
            
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "SI", style: UIAlertActionStyle.default, handler: { action in
                self.performSegue(withIdentifier: "irTotalizar", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.destructive, handler: { action in
                Proveedor().deleteProvider()
                Article().deleteArticles()
                
                // REALIZAR EL SEGUE A LA SIGUIENTE PANTALLA (SELECIONAR PROVEEDOR)
                //self.performSegue(withIdentifier: "irProveedor", sender: self)
                self.performSegue(withIdentifier: "irMenu", sender: self)
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        } else {
            // REALIZAR EL SEGUE A LA SIGUIENTE PANTALLA (SELECIONAR PROVEEDOR)
            //self.performSegue(withIdentifier: "irProveedor", sender: self)
            self.performSegue(withIdentifier: "irMenu", sender: self)
        }
        
        
    }
    
    @IBAction func sendButton(_ sender: Any) {
        // Verificamos que los campos no estan vacios
        if (userField.text == "") {
            messageLabel.text = "¡El campo usuario está vacio!"
        } else if (passwordField.text == ""){
            messageLabel.text = "¡El campo contraseña está vacio!"
        } else {
            // Si todo OK realizamos la consulta para verificar si existe el usuario
            let params = [
                "codigo": self.userField.text!,
                "clave": self.passwordField.text!
            ]
            
            ToolsPaseo().consultPOST(path: "/Login", params: params){ data in
                if (data[0]["error"] == false){
                    // Populate the user object
                    self.usuario = User()
                    self.usuario.nombre = data[0]["nombre"].string!
                    self.usuario.codigo = data[0]["codigo"].string!
                    self.usuario.auto   = data[0]["auto"].string!
                    
                    // Antes verificamos si ya hay alguna recepcion pendiente
                    self.verificarDatos()
                    
                } else {
                    // Si hubo algun error en la consulta mostramos el error
                    self.messageLabel.text = "\(data[0]["erroDescription"])"
                }
            
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "irMenu" {
            if let destination = segue.destination as? MenuViewController {
                destination.usuario = self.usuario
            }
        
        }
        if segue.identifier == "irProveedor" {
            if let destination = segue.destination as? EscogerProveedor {
                destination.usuario = self.usuario
            }
        }
        
        if segue.identifier == "irTotalizar" {
            if let destination = segue.destination as? TotalizarController {
                destination.usuario   = self.usuario
                destination.articulos = self.articles
                destination.proveedor = self.provider
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Cuando se hace TAP en cualquier lugar oculta el keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // Cuando se hace tap quita el keyboard
    func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

