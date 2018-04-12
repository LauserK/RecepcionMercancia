//
//  Proveedor.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 19/2/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Proveedor {
    var auto: String?
    var razon_social: String?
    var ci_rif: String?
    var dir_fiscal: String?
}


extension Proveedor {

    func getProvider() -> Proveedor {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "ProviderCore",in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        var provider = Proveedor()
        
        do {
            var results =
                try managedObjectContext.fetch(request)
            
            if results.count > 0 {
                let match = results[0] as! NSManagedObject
                provider.auto         = "\(match.value(forKey: "auto")!)"
                provider.ci_rif       = "\(match.value(forKey: "ci_rif")!)"
                provider.dir_fiscal   = "\(match.value(forKey: "dir_fiscal")!)"
                provider.razon_social = "\(match.value(forKey: "razon_social")!)"
            }
            
        } catch let error as NSError {
            print("\(error.localizedFailureReason)")
        }
        
        return provider
    }
    
    func saveProvider(proveedor: Proveedor) {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "ProviderCore",in: managedObjectContext)
        let provider = ProviderCore(entity: entityDescription!, insertInto: managedObjectContext)
        
        provider.auto         = "\(proveedor.auto!)"
        provider.ci_rif       = "\(proveedor.ci_rif!)"
        provider.dir_fiscal   = "\(proveedor.dir_fiscal!)"
        provider.razon_social = "\(proveedor.razon_social!)"
       
        
        do {
            self.deleteProvider()
            try managedObjectContext.save()
            print("PROVEEDOR: \(proveedor.razon_social!)")
            
        } catch let error as NSError {
            print("error: \(error.localizedFailureReason)" )
        }
    }
    
    func deleteProvider(){
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "ProviderCore",in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try managedObjectContext.execute(deleteRequest)
        } catch let error as NSError {
            print("\(error.localizedFailureReason)")
        }
        
        
    }


}
