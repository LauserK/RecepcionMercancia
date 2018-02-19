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

class ViewController: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var userField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    // Informacion del usuario
    var usuario: User!
    
    @IBAction func sendButton(_ sender: Any) {
        // Validaciones
        if (userField.text == "") {
            messageLabel.text = "USUARIO VACIO"
        } else if (passwordField.text == ""){
            messageLabel.text = "CONTRASEÑA VACIA"
        } else {
            
            let params = [
                "codigo": self.userField.text!,
                "clave": self.passwordField.text!
            ]
            
            Alamofire.request("http://10.10.0.250/RecepcionMercancia/Service.asmx/Login", method: .post, parameters:params).responseString {
                response in
                
                let data = JSON.init(parseJSON:response.result.value!)
                
                if (data[0]["error"] == false){
                    // Populate the user object
                    self.usuario = User()
                    self.usuario.nombre = data[0]["nombre"].string!
                    self.usuario.codigo = data[0]["codigo"].string!
                    self.usuario.auto   = data[0]["auto"].string!
                    
                    // REALIZAR EL SEGUE A LA SIGUIENTE PANTALLA (SELECIONAR PROVEEDOR)
                    self.performSegue(withIdentifier: "irProveedor", sender: self)
                    
                } else {
                    self.messageLabel.text = "\(data[0]["erroDescription"])"
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

