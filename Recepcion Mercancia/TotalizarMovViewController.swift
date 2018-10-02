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
        //Save
        
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
