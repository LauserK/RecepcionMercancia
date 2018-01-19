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
    @IBOutlet weak var titulo2Label: UILabel!
    
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
        "auto":""
    ]
    var articulos = [[""]]
    
    var unidadMedidaData = [["",""]]
    
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
    
    func buscarProducto(code: String){
        ToolsPaseo().consultarDB(id: "open", sql: "SELECT productos.auto, productos.nombre, productos.codigo, productos_medida.auto AS auto_medida FROM productos INNER JOIN productos_medida ON productos.auto_empaque_compra = productos_medida.auto WHERE productos.codigo = '\(code)'"){ data in
            
            if (data["data"][0][1] == nil){
                self.articuloLabel.text = "¡ARTÍCULO NO EXISTE!"
                self.articuloLabel.textColor = UIColor.red
            } else {
                self.articulo["nombre"] = data["data"][0][1].string
                self.articulo["codigo"] = data["data"][0][2].string
                self.articulo["auto"] = data["data"][0][0].string
                self.articulo["auto_medida"] = data["data"][0][3].string
                
                // mostrar controles de cantidades y medidas
                self.cantidadLabel.isHidden = false
                self.unidadMedidaPicker.isHidden = false
                self.btnCantidadMas.isHidden = false
                self.btnCantidadMenos.isHidden = false
                self.titulo2Label.isHidden = false
                
                // Mostrar nombre en el label
                self.articuloLabel.text = self.articulo["nombre"]
                
                // Cambiar selecion del picker al indicado
                var c = 0
                for data in self.unidadMedidaData{
                    if (data[0] == self.articulo["auto_medida"]){
                        let nombre = data[1]
                        let decimales = data[2]
                        
                        if (decimales == "2"){
                            self.cantidadLabel.text = "\(0.0)"
                        }
                        
                        if (decimales == "3"){
                            self.cantidadLabel.text = "\(0.000)"
                        }
                        
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
        
        // ocultar controles de cantidades y medidas
        self.cantidadLabel.isHidden = true
        self.unidadMedidaPicker.isHidden = true
        self.btnCantidadMas.isHidden = true
        self.btnCantidadMenos.isHidden = true
        self.titulo2Label.isHidden = true
        
        
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
            self.unidadMedidaPicker?.reloadAllComponents()
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
