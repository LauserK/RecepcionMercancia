//
//  TecladoController.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 20/1/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//


import UIKit
import SwiftyJSON

class TecladoController: UIViewController {
    var proveedor = [
        "razon_social":"",
        "ci_rif": "",
        "auto":""
    ]
    var usuario = [
        "nombre": "",
        "codigo": "",
        "auto":""
    ]
    var articulo = [
        "nombre": "",
        "codigo": "",
        "auto":""
    ]
    
    var articulos = [["":""]]
    
    
    @IBOutlet weak var labelText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mete(text: String){
        if (self.labelText.text == "0"){
            self.labelText.text = "\(text)"
        } else {
            self.labelText.text = "\(self.labelText.text!)\(text)"
        }
        
    }
    @IBAction func borrar(_ sender: Any) {
        if (self.labelText.text!.characters.count > 0){
            self.labelText.text = labelText.text!.substring(to: labelText.text!.index(before: labelText.text!.endIndex))
        } else {
            self.labelText.text = "0"
        }
    }
    
    @IBAction func numero1(_ sender: Any) {
        
        self.mete(text: "1")
    }
    
    @IBAction func numero2(_ sender: Any) {
        self.mete(text: "2")
    }
    
    @IBAction func numero3(_ sender: Any) {
        self.mete(text: "3")
    }
    
    @IBAction func numero4(_ sender: Any) {
        self.mete(text: "4")
    }
    
    @IBAction func numero5(_ sender: Any) {
        self.mete(text: "5")
    }
    
    @IBAction func numero6(_ sender: Any) {
        self.mete(text: "6")
    }
    
    @IBAction func numero7(_ sender: Any) {
        self.mete(text: "7")
    }
    
    @IBAction func numero8(_ sender: Any) {
        self.mete(text: "8")
    }
    
    @IBAction func mete9(_ sender: Any) {
        self.mete(text: "9")
    }
   
    @IBAction func numero0(_ sender: Any) {
        self.mete(text: "0")
    }
    
    @IBAction func punto(_ sender: Any) {
        self.mete(text:".")
    }
    
    
    @IBAction func returnToArticle(_ sender: Any) {
        if(self.labelText.text!.characters.count > 0){
            self.performSegue(withIdentifier: "returnToArticle", sender: self)
        }
    }
    
    // return to article
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "returnToArticle" {
            if let destination = segue.destination as? ArticuloController {
                destination.usuario = self.usuario
                destination.proveedor = self.proveedor
                destination.articulo = self.articulo
                destination.cantidad = self.labelText.text!
                destination.articulos = self.articulos
            }
        }
    }
    
}
