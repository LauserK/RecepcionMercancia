//
//  Article.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 21/2/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import Foundation

class Article {
    var nombre: String?
    var codigo: String?
    var auto: String?
    var contenido_compras: Int?
    var auto_departamento: String?
    var auto_grupo: String?
    var auto_subgrupo: String?
    var auto_deposito: [[String : Any]]?
    var cantidad_recibida: String?
    var cantidad_factura: String?
    var auto_medida: String?

}

extension Article {
    var toDict: Dictionary<String, Any> {
        return [
            "nombre": self.nombre!,
            "codigo": self.codigo!,
            "auto_producto": self.auto!,
            "contenido_compras": self.contenido_compras!,
            "auto_departamento": self.auto_departamento!,
            "auto_grupo": self.auto_grupo!,
            "auto_subgrupo": self.auto_subgrupo!,
            "auto_deposito": "0000000001",
            "cantidad": Double(self.cantidad_recibida!)!,
            "empaque": "UNIDAD"
        ]
    }
}
