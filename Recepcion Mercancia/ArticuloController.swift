//
//  ArticuloController.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 18/1/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit
import SwiftyJSON
import BarcodeScanner

class ArticuloController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var usuarioLabel: UILabel!
    @IBOutlet weak var proveedorLabel: UILabel!
    @IBOutlet weak var codigoInput: UITextField!
    @IBOutlet weak var articuloLabel: UILabel!
    @IBOutlet weak var cantidadLabel: UILabel!
    @IBOutlet weak var unidadMedidaPicker: UIPickerView!
    @IBOutlet weak var btnCantidadMas: UIButton!
    @IBOutlet weak var btnCantidadMenos: UIButton!
    @IBOutlet weak var btnEditarCantidad: UIButton!
    @IBOutlet weak var titulo2Label: UILabel!
    @IBOutlet weak var unidadLabel: UILabel!
    
    var proveedor = [
        "razon_social":"",
        "ci_rif": "",
        "auto":""
    ]
    var usuario = [
        "nombre": "",
        "codigo": "",
        "auto":""
    ]
    var articulo = [
        "nombre": "",
        "codigo": "",
        "auto":"",
        "cantidad_recibida":"",
        "cantidad_factura":""
    ]
    
    var cantidad = "0"
    
    var articulos = [["":""]]
    
    var unidadMedidaData = [["",""]]
    
    // 1 = Ingresar recibido // 2 = ingresar lo que especifica la factura
    var tipoPantalla = 1
    
    // Instancia del visor de codigo
    private let controller = BarcodeScannerController()
    
    @IBAction func cantidadMenos(_ sender: Any) {
        let cantidad: Int = Int(self.cantidadLabel.text!)!
        
        if (cantidad > 0){
            self.cantidadLabel.text = String(cantidad - 1)
        }
    }
    
    @IBAction func cantidadMas(_ sender: Any) {
        let cantidad: Int = Int(self.cantidadLabel.text!)!
        self.cantidadLabel.text = String(cantidad + 1)
    }
    
    @IBAction func scanButtonAction(_ sender: Any) {
        controller.reset(animated: true)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        buscarProducto(code: self.codigoInput.text!)
    }
    
    @IBAction func editarButtonAction(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToEditCant", sender: self)
        
    }
    
    func buscarProducto(code: String){
        ToolsPaseo().consultarDB(id: "open", sql: "SELECT productos.auto, productos.nombre, productos.codigo, productos_medida.auto AS auto_medida, productos.contenido_compras FROM productos INNER JOIN productos_medida ON productos.auto_empaque_compra = productos_medida.auto WHERE productos.codigo = '\(code)'"){ data in
            
            if (data["data"][0][1] == nil){
                self.articuloLabel.text = "¡ARTÍCULO NO EXISTE!"
                self.articuloLabel.textColor = UIColor.red
            } else {
                self.articulo["nombre"] = data["data"][0][1].string
                self.articulo["codigo"] = data["data"][0][2].string
                self.articulo["auto"] = data["data"][0][0].string
                self.articulo["auto_medida"] = data["data"][0][3].string
                self.articulo["contenido_compras"] = "\(data["data"][0][4])"
                
                // mostrar controles de cantidades y medidas
                self.cantidadLabel.isHidden = false
                self.unidadMedidaPicker.isHidden = false
                self.btnCantidadMas.isHidden = false
                self.btnCantidadMenos.isHidden = false
                self.titulo2Label.isHidden = false
                self.btnEditarCantidad.isHidden = false
                self.unidadLabel.isHidden = false
                
                // Mostramos los datos
                self.articuloLabel.text = self.articulo["nombre"]
                
                // Cambiar selecion del picker al indicado
                var c = 0
                for data in self.unidadMedidaData{
                    if (data[0] == self.articulo["auto_medida"]){
                        let nombre = data[1]
                        let decimales = data[2]
                        
                        if (self.cantidad != "0"){
                            self.cantidadLabel.text = "\(self.cantidad)"
                        }
                        
                        self.unidadLabel.text = "\(nombre): \(self.articulo["contenido_compras"]!) unds"
                        
                        self.unidadMedidaPicker.selectRow(c, inComponent: 0, animated: false)
                    }
                    c += 1
                }
            }
        }
    }
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        self.codigoInput.text = code
        controller.dismiss(animated: true, completion: nil)
        if (code != ""){
            buscarProducto(code: code)
        }
    }
    
    
    // Cuando damos tap en el view se quita el teclado
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        
        unidadMedidaPicker.delegate = self
        unidadMedidaPicker.dataSource = self
        
        self.proveedorLabel.text = self.proveedor["razon_social"]
        self.usuarioLabel.text = self.usuario["nombre"]
        
        // ocultar controles de cantidades y medidas o mostrar datos
        self.cantidadLabel.isHidden = true
        self.unidadMedidaPicker.isHidden = true
        self.btnCantidadMas.isHidden = true
        self.btnCantidadMenos.isHidden = true
        self.titulo2Label.isHidden = true
        self.btnEditarCantidad.isHidden = true
        self.unidadLabel.isHidden = true
        
        // textos español
        BarcodeScanner.Title.text = NSLocalizedString("ESCANER", comment: "")
        BarcodeScanner.CloseButton.text = NSLocalizedString("Cerrar", comment: "")
        BarcodeScanner.SettingsButton.text = NSLocalizedString("Configuraciones", comment: "")
        BarcodeScanner.Info.text = NSLocalizedString(
            "Cuadra el codigo de barra para ser escaneado", comment: "")
        BarcodeScanner.Info.loadingText = NSLocalizedString("Buscando...", comment: "")
        BarcodeScanner.Info.notFoundText = NSLocalizedString("Producto no ecnontrado.", comment: "")
        BarcodeScanner.Info.settingsText = NSLocalizedString(
            "Para escanear debes de habilitar el acceso a la camara.", comment: "")
        
        
        // Buscar unidades de medida
        ToolsPaseo().consultarDB(id: "open", sql: "SELECT auto, nombre, decimales FROM productos_medida"){ data in
            self.unidadMedidaData = []
            for (_,subJson):(String, JSON) in data["data"] {
                var medida: [String] = []
                for (_, medidaItem):(String, JSON) in subJson {
                    medida.append(medidaItem.string!)
                }
                self.unidadMedidaData.append(medida)
            }
            //Actualizamos el picker
            self.unidadMedidaPicker?.reloadAllComponents()
            
            // Si vienes de editar la cantidad
            if (self.articulo["codigo"] != ""){
                self.buscarProducto(code: self.articulo["codigo"]!)
            }
        }
    }
    
    func irSiguiente(){
        // Agregar el articulo al array de recibidos
        self.articulos.append(self.articulo)
        
        // create the alert
        let alert = UIAlertController(title: "¡ARTICULO AGREGADO EXITOSAMENTE!", message: "¿Existen más artículos por recibir?", preferredStyle: UIAlertControllerStyle.alert)
        
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "SI", style: UIAlertActionStyle.default, handler: { action in
            
            // Agregar siguiente articulo
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticuloController") as? ArticuloController
            {
                vc.usuario = self.usuario
                vc.articulos = self.articulos
                vc.proveedor = self.proveedor
                self.present(vc, animated: true, completion: nil)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: { action in
            
            self.performSegue(withIdentifier: "irTotalizar", sender: self)
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    
    }
    
    @IBAction func handleNext(_ sender: Any) {
        if(self.articulo["nombre"] != "" && self.cantidadLabel.text != "0" && self.tipoPantalla == 1){
            
            self.articulo["cantidad_recibida"] = self.cantidadLabel.text!
            
            // create the alert
            let alert = UIAlertController(title: self.articuloLabel.text!, message: "¿La cantidad recibida es la misma que especifica la factura?", preferredStyle: UIAlertControllerStyle.alert)

            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "SI", style: UIAlertActionStyle.default, handler: { action in
                // Preguntar si hay mas articulos o ir a lista de recibidos
                self.irSiguiente()
                
                
            }))
            alert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: { action in
            
                // Muestra pantalla para indicar el
                self.titulo2Label.text = "INDICAR CANTIDAD QUE ESPECIFICA LA FACTURA"
                self.tipoPantalla = 2
                self.cantidadLabel.text = "0"
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        
        if (self.articulo["nombre"] != "" && self.cantidadLabel.text != "0" && self.tipoPantalla == 2) {
            
            self.articulo["cantidad_factura"] = self.cantidadLabel.text!
            self.irSiguiente()
        
        }
        
        
        
    }
    
    
    // PICKER VIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.unidadMedidaData.count
    }
    
    // Seteamos los arreglos(data) a los picker
    func pickerView(_
        pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
        
        return unidadMedidaData[row][1]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    // Move to teclado
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToEditCant" {
            if let destination = segue.destination as? TecladoController {
                destination.usuario = self.usuario
                destination.proveedor = self.proveedor
                destination.articulo = self.articulo
                destination.articulos = self.articulos
            }
        }
        
        if segue.identifier == "irTotalizar" {
            if let destination = segue.destination as? TotalizarController {
                destination.usuario = self.usuario
                destination.proveedor = self.proveedor
                destination.articulos = self.articulos
            }
        }
    }
}

extension ArticuloController: BarcodeScannerCodeDelegate {
}

extension ArticuloController: BarcodeScannerErrorDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        print(error)
    }
}

extension ArticuloController: BarcodeScannerDismissalDelegate {
    
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
