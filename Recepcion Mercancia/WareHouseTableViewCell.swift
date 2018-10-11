//
//  WareHouseTableViewCell.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 10/10/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit

class WareHouseTableViewCell: UITableViewCell {
    @IBOutlet weak var wareHouseNameLabel: UILabel!

    @IBOutlet weak var wareHouseQuantityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wareHouseNameLabel.text = ""
        wareHouseQuantityLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var name: String? {
        didSet {
            wareHouseNameLabel.text = name
        }
    }
    
    var quantity: String? {
        didSet {
            wareHouseQuantityLabel.text = quantity
        }
    }
}
