//
//  ArticleMovimientoViewController.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 1/10/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit
import SwiftyJSON
import ExternalAccessory
import AdyenBarcoder

class ArticleMovimientoViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var barcode: UITextField!
    @IBOutlet weak var articleName: UILabel!
    @IBOutlet weak var pickerOrigen: UIPickerView!
    @IBOutlet weak var pickerDestino: UIPickerView!
    
    @IBOutlet weak var packageCant: UILabel!
    @IBOutlet weak var unityCant: UILabel!
    @IBOutlet weak var totalCant: UILabel!
    @IBOutlet weak var packageQuantity: UILabel!
    @IBOutlet weak var quantityOrigen: UILabel!
    @IBOutlet weak var quantityDestino: UILabel!
    
    var selected: UILabel!
    
    var usuario: User!
    var articulo: Article!
    var articuloMov: ArticleMov!
    var cantidad = "0"
    var articulosMov = [ArticleMov]()
    var depositos = [Warehouse]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selected = packageCant
        userLabel.text = usuario.nombre!
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleUnityLabelTap(sender:)))
        unityCant.addGestureRecognizer(tapGesture)
        
        pickerOrigen.delegate = self
        pickerOrigen.dataSource = self
        pickerDestino.delegate = self
        pickerDestino.dataSource = self
        
        if (self.articuloMov != nil){
            self.buscarProducto(code: self.articuloMov.article!.codigo!)
            
            self.packageCant.text = "\(self.articuloMov.cantidad!)"
            self.unityCant.text = "\(self.articuloMov.cantidadUnidad!)"
            self.totalCant.text = "\(self.articuloMov.total!)"
            
            // Mostrar la cantidad inputada en la vista anterior
            if (self.cantidad != "0"){
                
            }
        }
        
        // Si venimos de buscar el articulo
        if self.articulo != nil {
            self.buscarProducto(code: self.articulo!.codigo!)
        }
        
    }
    
    // Cuando damos tap en el view se quita el teclado
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buscarProducto(code: String){
        // Si todo OK realizamos la consulta para obtener los datos del articulo
        let params = [
            "code": code
        ]
        
        ToolsPaseo().consultPOST(path: "/GetArticle", params: params){ data in
            if (data[0]["error"] != true){
                // Populate the article object
                self.articulo = Article()
                self.articulo.nombre            = data["nombre"].string!
                self.articulo.codigo            = data["codigo"].string!
                self.articulo.auto              = data["auto"].string!
                self.articulo.contenido_compras = Int(data["contenido_compras"].string!)
                self.articulo.auto_departamento = data["auto_departamento"].string!
                self.articulo.auto_grupo        = data["auto_grupo"].string!
                self.articulo.auto_subgrupo     = data["auto_subgrupo"].string!
                self.articulo.tasa              = data["tasa"].string!
                self.articulo.auto_deposito     = []
                
                if self.articuloMov == nil {
                    self.articuloMov = ArticleMov()
                    self.articuloMov.article = self.articulo
                }
                
                // Agregar todos los depositos asociados al articulo a un array
                for (_,subJson):(String, JSON) in data["auto_deposito"] {
                    let deposito = [
                        "auto_deposito": subJson["auto_deposito"].string!,
                        "default": subJson["default"].bool ?? false
                        ] as [String : Any]
                    self.articulo.auto_deposito!.append(deposito)
                    let warehouse = Warehouse()
                    warehouse.auto = subJson["auto_deposito"].string!
                    warehouse.name = subJson["name"].string!
                    warehouse.quantity = subJson["cantidad"].double!
                    self.depositos.append(warehouse)
                }
            
                // Mostramos los datos
                self.articleName.text = "\(self.articulo.nombre!)"
                self.articleName.isHidden = false
                self.packageQuantity.text = "\(self.articulo.contenido_compras!) unds"
                
                // Seleccionar el almacen defecto
                do {
                    try self.pickerOrigen.selectRow(0, inComponent: 0, animated: true)
                    try self.pickerView(self.pickerOrigen, didSelectRow: 0, inComponent: 0)
                    try self.pickerDestino.selectRow(0, inComponent: 0, animated: true)
                    try self.pickerView(self.pickerDestino, didSelectRow: 0, inComponent: 0)
                } catch let error as NSError {
                    print(error)
                }
                
                self.pickerOrigen.reloadAllComponents()
                self.pickerDestino.reloadAllComponents()
                
            } else {
                // Si hubo algun error en la consulta mostramos el error
                
                // create the alert
                let alert = UIAlertController(title: "¡ERROR!", message: "¡El artículo que estás buscando no existe!", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    
    @IBAction func nextArticle(_ sender: Any) {        
        if (Double(totalCant.text!)! > (articuloMov.deposito_origen?.quantity!)!){
            // create the alert
            let alert = UIAlertController(title: "¡ERROR!", message: "EXISTENCIA POR DEBAJO DE LO ESPECIFICADO", preferredStyle: UIAlertControllerStyle.alert)
            
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        } else {
            if articulo != nil {
                articuloMov.concepto         = "APP MOVIMIENTO INVENTARIO"
                articuloMov.cantidad         = Double(packageCant.text!) ?? 0.00
                articuloMov.cantidadUnidad   = Int(unityCant.text!) ?? 0
                articuloMov.total            = Double(totalCant.text!) ?? 0.00
                articulosMov.append(articuloMov)
                
                // create the alert
                let alert = UIAlertController(title: "¡ARTICULO AGREGADO EXITOSAMENTE!", message: "¿Existen más artículos por movilizar?", preferredStyle: UIAlertControllerStyle.alert)
                
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "SI", style: UIAlertActionStyle.default, handler: { action in
                    
                    // Agregar siguiente articulo
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticleMov") as? ArticleMovimientoViewController
                    {
                        vc.usuario = self.usuario
                        vc.articulosMov = self.articulosMov
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                }))
                alert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: { action in
                    self.performSegue(withIdentifier: "irTotalizarMovimiento", sender: self)
                }))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func previus(_ sender: Any) {
        self.performSegue(withIdentifier: "irTotalizarMovimiento", sender: self)
    }
    
    
    @IBAction func searchArticle(_ sender: Any) {
        if (self.barcode.text!.characters.count > 0){
            if(self.barcode.text![0] == "*"){
                self.performSegue(withIdentifier: "irBuscarArticulo", sender: self)
            } else {
                buscarProducto(code: barcode.text!)
            }
        } else {
            self.performSegue(withIdentifier: "irBuscarArticulo", sender: self)
        }
    }
    
    @IBAction func minus(_ sender: Any) {
        
        if let cantidad = Int(self.selected!.text!) {
            if (cantidad > 0){
                self.selected.text = String(cantidad - 1)
            }
        } else {
            let cantidad = Double(self.selected.text!)!
            if (cantidad > 0){
                self.selected.text = "\(cantidad - 1.00)"
            }
        }
        
        calculateTotal()
    }
    
    @IBAction func plus(_ sender: Any) {
        let total = Double(totalCant.text!)
        if let cantidad = Int(self.selected.text!) {
            if (Int(total!)+1 <= Int(articuloMov.deposito_origen!.quantity!)){
                self.selected.text = String(cantidad + 1)
            }
        } else {
            let cantidad = Double(self.selected.text!)!
            
            if (total!+1.00 <= articuloMov.deposito_origen!.quantity!){
                self.selected.text = String(cantidad + 1)
            }
            self.selected.text = "\(cantidad + 1.00)"
        }
        calculateTotal()
    }
    
    // PICKER VIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return depositos.count
    }
    
    // Seteamos los arreglos(data) a los picker
    func pickerView(_
        pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
        
        return depositos[row].name!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerOrigen {
            articuloMov.deposito_origen = depositos[row]
            self.quantityOrigen.text = "\(articuloMov.deposito_origen?.quantity ?? 0.00)"
        } else if pickerView == pickerDestino {
            articuloMov.deposito_destino = depositos[row]
            self.quantityDestino.text = "\(articuloMov.deposito_destino?.quantity ?? 0.00)"
        }
    }
    
    func calculateTotal(){
        let packageTotal = Double(packageCant.text!)! * Double(articulo.contenido_compras!)
        let total = packageTotal + Double(unityCant.text!)!
        totalCant.text = "\(total)"
        
    }
    
    @objc func handleUnityLabelTap(sender: UITapGestureRecognizer) {
        
        if (selected == unityCant){
            selected = packageCant
            unityCant.backgroundColor = UIColor.white
        } else {
            selected = unityCant
            unityCant.backgroundColor = UIColor.yellow
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "irTotalizarMovimiento" {
            if let destination = segue.destination as? TotalizarMovViewController {
                destination.usuario = self.usuario
                destination.articulosMov = articulosMov                
            }
        }
        
        if segue.identifier == "irBuscarArticulo" {
            if let destination = segue.destination as? BuscarArticulo {
                destination.usuario = self.usuario
                destination.articulosMov = self.articulosMov
                destination.searchQueryText = self.barcode.text ?? " "
                destination.tipoPantalla = "2"
            }
        }
    }
}
