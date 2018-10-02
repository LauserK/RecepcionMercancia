//
//  MenuViewController.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 1/10/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var userLabel: UILabel!
    // Objecto usuario
    var usuario: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos el nombre de usuario en la parte superior
        self.userLabel.text = self.usuario.nombre            
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func tapRecepcion(_ sender: Any) {
        self.performSegue(withIdentifier: "irProveedor", sender: self)
        
    }
    
    @IBAction func tapMovimientos(_ sender: Any) {
        self.performSegue(withIdentifier: "irArticleMovimiento", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "irProveedor" {
            if let destination = segue.destination as? EscogerProveedor {
                destination.usuario = self.usuario
            }
        }
        
        if segue.identifier == "irArticleMovimiento" {
            if let destination = segue.destination as? ArticleMovimientoViewController {
                destination.usuario = self.usuario
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
