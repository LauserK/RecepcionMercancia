//
//  TotalizarMovViewController.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 1/10/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit

class TotalizarMovViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var listTable: UITableView!
    
    var usuario: User!
    var articuloMov: ArticleMov!
    var articulosMov = [ArticleMov]()    
    
    var isEdit = false
    var selectedArticle = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTable.delegate   = self
        listTable.dataSource = self
        
        self.userLabel.text = usuario.nombre!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editBtnAction(_ sender: Any) {
        if articuloMov != nil {
            self.articulosMov.remove(at:self.selectedArticle)
            isEdit = true
            self.performSegue(withIdentifier: "irArticleMov", sender: self)
        }
    }
    @IBAction func finishAction(_ sender: Any) {
        
        ToolsPaseo().loadingView(vc: self, msg: "Registrando en la base de datos")
        var cont = 1
        for article in articulosMov {
            let params = [
                "auto_producto": "\(article.article!.auto!)",
                "auto_deposito": "\(article.deposito_origen!.auto!)",
                "cantidad": "\(article.total!)",
                "signo": "-"
            ]
            
            ToolsPaseo().consultPOST(path: "/UpdateDeposit", params: params){ data in
                if(data[0]["error"] == true){
                    self.dismiss(animated: false){
                        print("Error: \(article.article?.nombre!)")
                    }
                } else {
                    let params = [
                        "auto_producto": "\(article.article!.auto!)",
                        "auto_deposito": "\(article.deposito_destino!.auto!)",
                        "cantidad": "\(article.total!)",
                        "signo": "+"
                    ]
                    
                    ToolsPaseo().consultPOST(path: "/UpdateDeposit", params: params){ data in
                        if(data[0]["error"] == true){
                            self.dismiss(animated:true){
                                print("Error: \(article.article?.nombre!)")
                            }
                        } else {
                            if cont == self.articulosMov.count {
                                self.dismiss(animated:false){
                                    // create the alert
                                    let alert = UIAlertController(title: "¡MENSAJE!", message: "¡Datos guardados exitosamente!", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { action in
                                        
                                        self.performSegue(withIdentifier: "backToMenu", sender: self)
                                    }))
                                    
                                    // show the alert
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                            
                            cont = cont + 1
                        }
                    }
                }
            }
            
        }
    }
    
    @IBAction func addAnotherAction(_ sender: Any) {
        self.performSegue(withIdentifier: "irArticleMov", sender: self)
    }
    

    // Tabla
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articulosMov.count
    }
    
    // Asignamos valores a las celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let articleCell = tableView.dequeueReusableCell(withIdentifier: "articleMovCell") as! ArticleMovItemCell
        
        let article = articulosMov[indexPath.row]
        articleCell.name = article.article!.nombre!
        articleCell.cant = "\(article.total!)"
        articleCell.wareHouseFrom = article.deposito_origen!
        articleCell.wareHouseTo   = article.deposito_destino!
        
        return articleCell
    }
    
    
    // Asigamos el valor a la variable Proveedor con el selecionado
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.articuloMov = self.articulosMov[indexPath.row]
        self.selectedArticle = indexPath.row
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "irArticleMov" {
            if let destination = segue.destination as? ArticleMovimientoViewController {
                destination.usuario = self.usuario
                destination.articulosMov = articulosMov
                
                if isEdit {
                    destination.articuloMov = articuloMov
                }
            }
        }
        
        if segue.identifier == "backToMenu" {
            if let destination = segue.destination as? MenuViewController {
                destination.usuario = self.usuario
            }
        }
    }
}

class ArticleMovItemCell: UITableViewCell {
    @IBOutlet weak var articleName: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var from: UILabel!
    @IBOutlet weak var to: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.articleName.text = ""
        self.quantity.text = ""
        self.from.text = ""
        self.to.text = ""
    }
    
    
    var name: String? {
        didSet {
            articleName.text = name
        }
    }
    
    var cant: String? {
        didSet {
            quantity.text = cant
        }
    }
    
    var wareHouseFrom: Warehouse? {
        didSet {
            from.text = wareHouseFrom!.name!
        }
    }
    
    var wareHouseTo: Warehouse? {
        didSet {
            to.text = wareHouseTo!.name!
        }
    }
    
}
