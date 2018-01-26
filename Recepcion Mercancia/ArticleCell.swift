//
//  ArticleCell.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 25/1/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import Foundation
import UIKit
import FontAwesome_swift

class ArticleItemCell: UITableViewCell {
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var codigoLabel: UILabel!
    @IBOutlet weak var cantidadLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.nombreLabel.text = ""
        self.codigoLabel.text = ""
        self.cantidadLabel.text = ""
        
        self.editButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 20)
        self.editButton.setTitle(String.fontAwesomeIcon(name: .pencil), for: .normal)
    }
}
