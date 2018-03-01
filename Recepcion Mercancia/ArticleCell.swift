//
//  ArticleCell.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 25/1/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import Foundation
import UIKit

class ArticleItemCell: UITableViewCell {
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var codigoLabel: UILabel!
    @IBOutlet weak var cantidadLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.nombreLabel.text = ""
        self.codigoLabel.text = ""
        self.cantidadLabel.text = ""
    }
    
    var nombre: String? {
        didSet {
            nombreLabel.text = nombre
        }
    }
    
    var codigo: String? {
        didSet {
            codigoLabel.text = codigo
        }
    }
    
    var cantidad: String? {
        didSet {
            cantidadLabel.text = cantidad
        }
    }
    
}
