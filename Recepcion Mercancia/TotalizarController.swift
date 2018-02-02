//
//  TotalizarController.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 25/1/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit
import SwiftyJSON

class TotalizarController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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
        "row":"0"
    ]
    
    var articulos = [["":""]]
    
    var deposito = "0000000001"
    var numero_factura = ""
    var isEdit = false
    
    @IBOutlet weak var articleTablewView: UITableView!
    @IBOutlet weak var numeroFacturaText: UITextField!
    @IBOutlet weak var usuarioLabel: UILabel!
    @IBOutlet weak var proveedorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleTablewView.delegate = self
        articleTablewView.dataSource = self
        
        // Mostramos datos de usuario y proveedor
        self.usuarioLabel.text = self.usuario["nombre"]
        self.proveedorLabel.text = self.proveedor["razon_social"]
        
        // Eliminar el articulo vacio
        for (index, dict) in self.articulos.enumerated() {
            if (dict[""] != nil) { self.articulos.remove(at:index) }
        }
        
        
    }
    
    // Cuando damos tap en el view se quita el teclado
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func agregarArticulo(_ sender: Any) {
        self.performSegue(withIdentifier: "returnToArticle", sender: self)
    }
    
    func updateAndShowMessage(auto_nuevo: String){
        ToolsPaseo().consultarDB(id: "open", sql: "UPDATE `sistema_contadores` SET `a_compras` = '\(auto_nuevo)' WHERE a_compras != '' LIMIT 1"){(data) in
            
            self.dismiss(animated: false){
                // create the alert
                let alert = UIAlertController(title: "¡MENSAJE!", message: "¡Datos guardados exitosamente!", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "ACEPTAR", style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func procesoGuardado(){
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fecha = formatter.string(from: date)
        formatter.dateFormat = "yyyy"
        let ano = formatter.string(from: date)
        formatter.dateFormat = "MM"
        let mes = formatter.string(from: date)
        let hour = Calendar.current.component(.hour, from: Date())
        let minutes = Calendar.current.component(.minute, from: Date())
        let hora = "\(hour):\(minutes)"
        let device = UIDevice.current.name
        
        
        ToolsPaseo().loadingView(vc: self, msg: "Registrando en la base de datos")
        
        //Obtener el auto
        ToolsPaseo().consultarDB(id: "open", sql: "SELECT a_compras FROM sistema_contadores limit 1"){ data in
            let auto = Int("\(data["data"][0][0])")!
            let auto_nuevo = auto + 1
            let auto_cuentas = String(format: "%010d", auto_nuevo)
            
            let sql = "INSERT INTO `00000001`.`compras` (`auto`, `documento`, `fecha`, `fecha_vencimiento`, `razon_social`, `dir_fiscal`, `ci_rif`, `tipo`, `exento`, `base1`, `base2`, `base3`, `impuesto1`, `impuesto2`, `impuesto3`, `base`, `impuesto`, `total`, `tasa1`, `tasa2`, `tasa3`, `nota`, `tasa_retencion_iva`, `tasa_retencion_islr`, `retencion_iva`, `retencion_islr`, `auto_proveedor`, `codigo_proveedor`, `mes_relacion`, `control`, `fecha_registro`, `orden_compra`, `dias`, `descuento1`, `descuento2`, `cargos`, `descuento1p`, `descuento2p`, `cargosp`, `columna`, `estatus_anulado`, `aplica`, `comprobante_retencion`, `subtotal_neto`, `telefono`, `factor_cambio`, `condicion_pago`, `usuario`, `codigo_usuario`, `codigo_sucursal`, `hora`, `monto_divisa`, `estacion`, `renglones`, `saldo_pendiente`, `ano_relacion`, `comprobante_retencion_islr`, `dias_validez`, `auto_usuario`, `situacion`, `signo`, `serie`, `tarifa`, `tipo_remision`, `documento_remision`, `auto_remision`, `documento_nombre`, `subtotal_impuesto`, `subtotal`, `auto_cxp`, `tipo_proveedor`, `planilla`, `expediente`, `anticipo_iva`, `terceros_iva`, `neto`, `costo`, `utilidad`, `utilidadp`, `documento_tipo`, `denominacion_fiscal`) VALUES ('\(auto_cuentas)', '', '\(fecha)', '\(fecha)', '\(self.proveedor["razon_social"]!)', '\(self.proveedor["dir_fiscal"]!)', '\(self.proveedor["ci_rif"]!)', '07', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '', '0.00', '0.00', '0.00', '0.00', '\(self.proveedor["auto"]!)', '\(self.proveedor["ci_rif"]!)', '\(mes)', '', '\(fecha)', '', '0', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '1', '0', '', '', '0.00', '', '0.0000', 'NO APLICA', '\(self.usuario["nombre"]!)', '\(self.usuario["codigo"]!)', '01', '\(hora)', '0.00', '\(device)', '\(self.articulos.count)', '0.00', '\(ano)', '', '0', '0000000001', 'Procesado', '0', 'RCP', '0', '', '', '', 'RECEPCION', '0.00', '0.00', '', '', '', '', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', 'RECEPCION', '');"
            
            // Insertar en la base de datos
            ToolsPaseo().consultarDB(id: "open", sql: sql){ data in
                // Insertar detalle de cada articulo en la base de datos
                var count = 0
                for articulo in self.articulos {
                    let sql = "INSERT INTO `00000001`.`compras_detalle` (`auto_documento`, `auto_producto`, `codigo`, `nombre`, `auto_departamento`, `auto_grupo`, `auto_subgrupo`, `auto_deposito`, `cantidad`, `empaque`, `descuento1p`, `descuento2p`, `descuento3p`, `descuento1`, `descuento2`, `descuento3`, `total_neto`, `tasa`, `impuesto`, `total`, `auto`, `estatus_anulado`, `fecha`, `tipo`, `deposito`, `signo`, `auto_proveedor`, `decimales`, `contenido_empaque`, `cantidad_und`, `costo_und`, `codigo_deposito`, `detalle`, `auto_tasa`, `categoria`, `costo_promedio_und`, `costo_compra`, `codigo_proveedor`, `cantidad_bono`, `costo_bruto`, `estatus_unidad`) VALUES ('\(auto_cuentas)', '\(articulo["auto"]!)', '\(articulo["codigo"]!)', '\(articulo["nombre"]!)', '\(articulo["auto_departamento"]!)', '\(articulo["auto_grupo"]!)', '\(articulo["auto_subgrupo"]!)', '\(self.deposito)', '\(articulo["cantidad_recibida"]!)', '', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0000000001', '0', '\(fecha)', '01', '', '1', '0000000001', '2', '0', '3.000', '0.00', '', '', '0000000001', '', '0.00', '0.00', '', '0.000', '0.00', '0'); INSERT INTO `00000001`.`productos_kardex` (`auto_producto`, `total`, `auto_deposito`, `auto_concepto`, `auto_documento`, `fecha`, `hora`, `documento`, `modulo`, `entidad`, `signo`, `cantidad`, `cantidad_bono`, `cantidad_und`, `costo_und`, `estatus_anulado`, `nota`, `precio_und`, `codigo`, `siglas`) VALUES ('\(articulo["auto"]!)', '0.00', '\(self.deposito)', '0000000002', '\(auto_nuevo)', '\(fecha)', '\(hora)', '\(self.numero_factura)', 'Recepcion', '\(self.proveedor["razon_social"]!)', '1', '\(articulo["cantidad_recibida"]!)', '0.000', '0.000', '0.00', '0', '', '0.00', '05', 'RCP');"
                    
                    ToolsPaseo().consultarDB(id: "open", sql: sql){ data in
                        ToolsPaseo().consultarDB(id: "open", sql: "SELECT fisica FROM `productos_deposito` WHERE auto_producto = '\(articulo["auto"]!)' AND auto_deposito = '\(self.deposito)' LIMIT 1;"){ data in
                            
                            let recibido = NSDecimalNumber(string:articulo["cantidad_recibida"]!)
                            let viejo = "\(data["data"][0][0])"
                            let nuevo = recibido.adding(NSDecimalNumber(string:viejo))
                            
                            // Actualizar depositos
                            
                            let sql4 = "UPDATE productos_deposito SET fisica = '\(nuevo)', disponible = '\(nuevo)' WHERE auto_producto = '\(articulo["auto"]!)' AND auto_deposito = '\(self.deposito)';"
                            print(sql4)
                            ToolsPaseo().consultarDB(id: "open", sql: sql4){ data in
                                
                                count += 1
                                if (count == self.articulos.count){
                                    self.updateAndShowMessage(auto_nuevo: "\(auto_nuevo)")
                                }
                                
                            }
                            
                            
                        }
                    }
                } // Aqui termina el ciclo de articulos
            }
            
        }
    }
    
    @IBAction func guardarRecepcion(_ sender: Any) {
        self.numero_factura = "\(self.numeroFacturaText.text!)"
        
        if (self.numero_factura != "" && self.numero_factura.characters.count > 2) {
            self.procesoGuardado()
        } else {
            // create the alert
            let alert = UIAlertController(title: "¡ERROR!", message: "¡NUMERO FACTURA VACIO!", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        
        }
        
    }
    
    @IBAction func editarArticulo(_ sender: Any) {
        if(self.articulo["nombre"] != "" && self.articulo["auto"] != ""){
            
            self.articulos.remove(at:Int(self.articulo["row"]!)!)
            
            self.isEdit = true
            self.performSegue(withIdentifier: "returnToArticle", sender: self)
        }
    }
    
    
    // Tabla
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articulos.count
    }
    
    
    
    // Asignamos valores a las celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "articleCell") as! ArticleItemCell
        newCell.nombreLabel.text = self.articulos[indexPath.row]["nombre"]
        newCell.cantidadLabel.text = self.articulos[indexPath.row]["cantidad_recibida"]
        newCell.codigoLabel.text = self.articulos[indexPath.row]["codigo"]
        return newCell
    }
    
    
    // Asigamos el valor a la variable Proveedor con el selecionado
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.articulo["auto"] = self.articulos[indexPath.row]["auto"]
        self.articulo["nombre"] = self.articulos[indexPath.row]["nombre"]
        self.articulo["codigo"] = self.articulos[indexPath.row]["codigo"]
        self.articulo["row"] = "\(indexPath.row)"
    }
    
    // return to article
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "returnToArticle" {
            if let destination = segue.destination as? ArticuloController {
                destination.usuario = self.usuario
                destination.proveedor = self.proveedor
                destination.articulos = self.articulos
                
                if self.isEdit {
                    destination.articulo = self.articulo
                    destination.cantidad = self.articulo["cantidad_recibida"]!
                }
                
            }
        }
    }
}
