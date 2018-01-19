//
//  ViewController.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 11/1/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var userField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    // Informacion del usuario
    var usuario = [
        "nombre": "",
        "codigo": "",
        "auto":""
    ]
    
    @IBAction func sendButton(_ sender: Any) {
        // Validaciones
        if (userField.text == "") {
            messageLabel.text = "USUARIO VACIO"
        } else if (passwordField.text == ""){
            messageLabel.text = "CONTRASEÑA VACIA"
        } else {
            
            // Realizamos la consulta
            ToolsPaseo().consultarDB(id: "open", sql: "SELECT auto, nombre, codigo FROM usuarios WHERE codigo = '\(self.userField.text!)' AND clave = '\(self.passwordField.text!)'"){ data in
                
                // Si no se encontro
                if (data["data"][0][0] == nil || data["data"][0][0] == "" || data["data"][0][0] == "null"){
                    self.messageLabel.text = "DATOS INCORRECTOS"
                } else {
                    self.usuario["auto"] = String(describing: data["data"][0][0])
                    self.usuario["nombre"] = String(describing: data["data"][0][1])
                    self.usuario["codigo"] = String(describing: data["data"][0][2])
                    
                    // REALIZAR EL SEGUE A LA SIGUIENTE PANTALLA (SELECIONAR PROVEEDOR)
                    self.performSegue(withIdentifier: "irProveedor", sender: self)
                }
            }
        
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "irProveedor" {
            if let destination = segue.destination as? EscogerProveedor {
                destination.usuario = self.usuario
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

