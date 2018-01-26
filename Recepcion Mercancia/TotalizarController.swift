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
    
    @IBOutlet weak var articleTablewView: UITableView!
    @IBOutlet weak var numeroFacturaText: UITextField!
    @IBOutlet weak var usuarioLabel: UILabel!
    @IBOutlet weak var proveedorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleTablewView.delegate = self
        articleTablewView.dataSource = self
        
        // Mostramos datos de usuario y proveedor
        self.usuarioLabel.text = self.usuario["nombre"]
        self.proveedorLabel.text = self.proveedor["razon_social"]
        
        // Eliminar el articulo vacio
        for (index, dict) in self.articulos.enumerated() {
            if (dict[""] != nil) { self.articulos.remove(at:index) }
        }
        
        
    }
    
    @IBAction func agregarArticulo(_ sender: Any) {
        self.performSegue(withIdentifier: "returnToArticle", sender: self)
    }
    
    
    // Tabla
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articulos.count
    }
    
    // Asignamos valores a las celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "articleCell") as! ArticleItemCell
        newCell.nombreLabel.text = self.articulos[indexPath.row]["nombre"]
        newCell.cantidadLabel.text = self.articulos[indexPath.row]["cantidad_recibida"]
        newCell.codigoLabel.text = self.articulos[indexPath.row]["codigo"]
        return newCell
    }
    
    
    // return to article
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "returnToArticle" {
            if let destination = segue.destination as? ArticuloController {
                destination.usuario = self.usuario
                destination.proveedor = self.proveedor
                destination.articulos = self.articulos
            }
        }
    }
}
