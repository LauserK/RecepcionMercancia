//
//  Article.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 21/2/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import Foundation
import CoreData
import UIKit

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
    var auto_tasa: String?
    var tasa: String?

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
            "cantidad": Double(self.cantidad_factura!)!,
            "cantidad_factura": self.cantidad_recibida!,
            "empaque": "UNIDAD",
            "auto_tasa": self.auto_tasa ?? "0000000002",
            "tasa": self.tasa ?? "12.00"
        ]
    }
    
    func getArticlesDevice() -> Array<Article> {
        var articles = [Article]()
        
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "ArticleCore",in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        do {
            var results =
                try managedObjectContext.fetch(request)
            
            if results.count > 0 {
                let match = results[0] as! NSManagedObject
                
                for result in results {
                    let data = result as! NSManagedObject
                    let article = Article()
                    article.nombre            = "\(data.value(forKey: "nombre")!)"
                    article.codigo            = "\(data.value(forKey: "codigo")!)"
                    article.auto              = "\(data.value(forKey: "auto")!)"
                    article.contenido_compras = Int("\(data.value(forKey: "contenido_compras")!)")
                    article.auto_departamento = "\(data.value(forKey: "auto_departamento")!)"
                    article.auto_grupo        = "\(data.value(forKey: "auto_grupo")!)"
                    article.auto_subgrupo     = "\(data.value(forKey: "auto_subgrupo")!)"
                    article.auto_deposito     = []
                    article.cantidad_recibida = "\(data.value(forKey: "cantidad_recibida")!)"
                    article.cantidad_factura  = "\(data.value(forKey: "cantidad_factura")!)"
                    
                    articles.append(article)
                }
            }
            
        } catch let error as NSError {
            print("\(error.localizedFailureReason)")
        }
        
        
        
        return articles
    }
    
    func saveArticle(articulo: Article) {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "ArticleCore",in: managedObjectContext)
        let article = ArticleCore(entity: entityDescription!, insertInto: managedObjectContext)
        
        article.nombre            = articulo.nombre!
        article.codigo            = articulo.codigo!
        article.auto              = articulo.auto!
        article.contenido_compras = "\(articulo.contenido_compras!)"
        article.auto_departamento = articulo.auto_departamento!
        article.auto_grupo        = articulo.auto_grupo!
        article.auto_subgrupo     = articulo.auto_subgrupo!
        article.cantidad_recibida = articulo.cantidad_recibida!
        article.cantidad_factura  = articulo.cantidad_factura!
        
        do {
            try managedObjectContext.save()
            print("GUARDADO: \(articulo.nombre!)")
            
        } catch let error as NSError {
            print("error: \(error.localizedFailureReason)" )
        }
    }
    
    func deleteArticles(){
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "ArticleCore",in: managedObjectContext)
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
