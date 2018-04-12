//
//  ArticleCore+CoreDataProperties.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 12/4/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import Foundation
import CoreData


extension ArticleCore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArticleCore> {
        return NSFetchRequest<ArticleCore>(entityName: "ArticleCore");
    }

    @NSManaged public var nombre: String?
    @NSManaged public var auto_tasa: String?
    @NSManaged public var auto_departamento: String?
    @NSManaged public var contenido_compras: String?
    @NSManaged public var auto: String?
    @NSManaged public var codigo: String?
    @NSManaged public var cantidad_recibida: String?
    @NSManaged public var auto_subgrupo: String?
    @NSManaged public var auto_grupo: String?
    @NSManaged public var auto_medida: String?
    @NSManaged public var cantidad_factura: String?
    @NSManaged public var tasa: String?

}
