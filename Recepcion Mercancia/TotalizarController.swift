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
        "auto":""
    ]
    
    var articulos = [["":""]]
    
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
    
    @IBAction func agregarArticulo(_ sender: Any) {
        self.performSegue(withIdentifier: "returnToArticle", sender: self)
    }
    
    @IBAction func guardarRecepcion(_ sender: Any) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fecha = formatter.string(from: date)
        formatter.dateFormat = "yyyy"
        let ano = formatter.string(from: date)
        let hora = Calendar.current.component(.hour, from: Date())
        let device = UIDevice.current.name
        
        //Obtener el auto
        ToolsPaseo().consultarDB(id: "open", sql: "SELECT a_compras FROM sistema_contadores limit 1"){ data in
            let auto = Int("\(data["data"][0][0])")!
            let auto_nuevo = auto + 1
            let auto_cuentas = String(format: "%010d", auto_nuevo)
            
            let sql = "INSERT INTO `00000001`.`compras` (`auto`, `documento`, `fecha`, `fecha_vencimiento`, `razon_social`, `dir_fiscal`, `ci_rif`, `tipo`, `exento`, `base1`, `base2`, `base3`, `impuesto1`, `impuesto2`, `impuesto3`, `base`, `impuesto`, `total`, `tasa1`, `tasa2`, `tasa3`, `nota`, `tasa_retencion_iva`, `tasa_retencion_islr`, `retencion_iva`, `retencion_islr`, `auto_proveedor`, `codigo_proveedor`, `mes_relacion`, `control`, `fecha_registro`, `orden_compra`, `dias`, `descuento1`, `descuento2`, `cargos`, `descuento1p`, `descuento2p`, `cargosp`, `columna`, `estatus_anulado`, `aplica`, `comprobante_retencion`, `subtotal_neto`, `telefono`, `factor_cambio`, `condicion_pago`, `usuario`, `codigo_usuario`, `codigo_sucursal`, `hora`, `monto_divisa`, `estacion`, `renglones`, `saldo_pendiente`, `ano_relacion`, `comprobante_retencion_islr`, `dias_validez`, `auto_usuario`, `situacion`, `signo`, `serie`, `tarifa`, `tipo_remision`, `documento_remision`, `auto_remision`, `documento_nombre`, `subtotal_impuesto`, `subtotal`, `auto_cxp`, `tipo_proveedor`, `planilla`, `expediente`, `anticipo_iva`, `terceros_iva`, `neto`, `costo`, `utilidad`, `utilidadp`, `documento_tipo`, `denominacion_fiscal`) VALUES ('\(auto_cuentas)', '', '\(fecha)', '\(fecha)', '\(self.proveedor["razon_social"]!)', '\(self.proveedor["dir_fiscal"]!)', '\(self.proveedor["ci_rif"]!)', '07', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '', '0.00', '0.00', '0.00', '0.00', '\(self.proveedor["auto"]!)', '\(self.proveedor["ci_rif"]!)', '01', '', '\(fecha)', '', '0', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '1', '0', '', '', '0.00', '', '0.0000', 'NO APLICA', '\(self.usuario["nombre"]!)', '\(self.usuario["codigo"]!)', '01', '\(hora)', '0.00', '\(device)', '0', '0.00', '\(ano)', '', '0', '0000000001', 'Procesado', '0', 'RCP', '0', '', '', '', 'RECEPCION', '0.00', '0.00', '', '', '', '', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', 'RECEPCION', '');"
            
            // Insertar en la base de datos
            ToolsPaseo().consultarDB(id: "open", sql: sql){ data in
                print(data)
            
            
            }
            
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
    
    
    // return to article
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "returnToArticle" {
            if let destination = segue.destination as? ArticuloController {
                destination.usuario = self.usuario
                destination.proveedor = self.proveedor
                destination.articulos = self.articulos
            }
        }
    }
}
