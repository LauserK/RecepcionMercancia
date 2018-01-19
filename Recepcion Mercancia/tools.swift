//
//  tools.swift
//  Anfitrion Paseo
//
//  Created by Macbook on 26/10/17.
//  Copyright © 2017 Grupo Paseo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ToolsPaseo {
    func consultarDB(id:String, sql:String, completion:@escaping (JSON) -> Void){
        let params = [
            "id":id,
            "sql":sql
        ]
        
        Alamofire.request("http://10.10.2.11:8000/webserver/", method: .post, parameters:params).responseJSON {
            response in
            
            if let json = response.result.value {
                let data = JSON(json)
                completion(data)
            }
        }
    }
    
    func loadingView(vc: UIViewController, msg: String){
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        vc.present(alert, animated: true, completion: nil)
    }
}
