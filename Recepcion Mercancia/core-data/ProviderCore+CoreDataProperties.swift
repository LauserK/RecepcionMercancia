//
//  ProviderCore+CoreDataProperties.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 12/4/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import Foundation
import CoreData


extension ProviderCore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProviderCore> {
        return NSFetchRequest<ProviderCore>(entityName: "ProviderCore");
    }

    @NSManaged public var razon_social: String?
    @NSManaged public var auto: String?
    @NSManaged public var ci_rif: String?
    @NSManaged public var dir_fiscal: String?

}
