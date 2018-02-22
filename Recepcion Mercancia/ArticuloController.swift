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
    
    var proveedor: Proveedor!
    
    var usuario: User!
    
    var articulo: Article!
    
    var cantidad = "0"
    
    var articulos = [Article]()
    
    var unidadMedidaData = [["",""]]
    
    // 1 = Ingresar recibido // 2 = ingresar lo que especifica la factura
    var tipoPantalla = 1
    
    // Instancia del visor de codigo
    private let controller = BarcodeScannerController()
    
    @IBAction func cantidadMenos(_ sender: Any) {
        if let cantidad = Int(self.cantidadLabel.text!) {
            if (cantidad > 0){
                self.cantidadLabel.text = String(cantidad - 1)
            }
        }
    }
    
    @IBAction func cantidadMas(_ sender: Any) {
        if let cantidad = Int(self.cantidadLabel.text!) {
            self.cantidadLabel.text = String(cantidad + 1)
        }
    }
    
    @IBAction func scanButtonAction(_ sender: Any) {
        controller.reset(animated: true)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        // Verificar tipo de busqueda
        // Si tiene un '*' en el inicio busca por nombre
        // Si no tiene un '*' busca por el codigo exacto
        if(self.codigoInput.text![0] == "*"){
            self.performSegue(withIdentifier: "irBuscarArticulo", sender: self)
        
        } else {
            buscarProducto(code: self.codigoInput.text!)
        }
    }
    
    @IBAction func editarButtonAction(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToEditCant", sender: self)
        
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
                self.articulo.auto_departamento = data["nombre"].string!
                self.articulo.auto_grupo        = data["auto_grupo"].string!
                self.articulo.auto_subgrupo     = data["auto_subgrupo"].string!
                //self.articulo.auto_deposito     = data[0]["auto_deposito"].string!
                
                // mostrar controles de cantidades y medidas
                self.cantidadLabel.isHidden = false
                self.unidadMedidaPicker.isHidden = false
                self.btnCantidadMas.isHidden = false
                self.btnCantidadMenos.isHidden = false
                self.titulo2Label.isHidden = false
                self.btnEditarCantidad.isHidden = false
                self.unidadLabel.isHidden = false
                
                // Mostramos los datos
                self.articuloLabel.text = self.articulo.nombre!
                self.unidadLabel.text = "\(self.articulo.contenido_compras!) unds"
                // MARK.- Here have to be procedure to change the picker to medida indicated
                
            } else {
                // Si hubo algun error en la consulta mostramos el error
                self.articuloLabel.text = "\(data["erroDescription"])"
                self.articuloLabel.textColor = UIColor.red
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
        
        self.proveedorLabel.text = self.proveedor.razon_social
        self.usuarioLabel.text = self.usuario.nombre
        
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
        /*
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
        }*/
        
        // Si vienes de editar la cantidad
        if (self.articulo != nil){
            self.buscarProducto(code: self.articulo.codigo!)
            // Mostrar la cantidad inputada en la vista anterior
            if (self.cantidad != "0"){
                self.cantidadLabel.text = "\(self.cantidad)"
            }
        }
    }
    
    @IBAction func irVolver(_ sender: Any) {
        self.performSegue(withIdentifier: "irTotalizar", sender: self)
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
        if(self.articulo.nombre != nil && self.cantidadLabel.text != "0" && self.tipoPantalla == 1){
            
            self.articulo.cantidad_recibida = self.cantidadLabel.text!
            
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
        
        if (self.articulo.nombre != nil && self.cantidadLabel.text != "0" && self.tipoPantalla == 2) {
            
            self.articulo.cantidad_factura = self.cantidadLabel.text!
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
        
        if segue.identifier == "irBuscarArticulo" {
            if let destination = segue.destination as? BuscarArticulo {
                destination.usuario = self.usuario
                destination.proveedor = self.proveedor
                destination.articulos_lista = self.articulos
                destination.searchQueryText = self.codigoInput.text!
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


class BuscarArticulo: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Vista para buscar proveedor y selecionar el proveedor
    var searchQueryText = ""
    var articulos = [Article]()
    var articulos_lista = [Article]()
    var articulo: Article!
    var proveedor: Proveedor!
    var usuario: User!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var queryProveedorInput: UITextField!
    
    // Cuando damos tap en el view se quita el teclado
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func buscarProveedor(){
        let params = [
            "nombre":"\(self.searchQueryText)"
        ]
        
        // Ejecutamos el servicio
        ToolsPaseo().consultPOST(path: "/GetArticlesList", params: params) { data in
            print(data)
            // agregamos datos al arreglo de proveedores
            for (_, subJson):(String, JSON) in data {
                let article = Article()
                article.auto = subJson["auto"].string!
                article.nombre = subJson["nombre"].string!
                article.codigo = subJson["codigo"].string!
                self.articulos.append(article)
                
                // Actualizamos la tabla con los nuevos datos
                self.tableView.reloadData()
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mostramos el nombre de usuario
        
        if (self.searchQueryText[0] == "*"){
            self.searchQueryText.remove(at: searchQueryText.startIndex)
            
        }
        
        self.queryProveedorInput.text = self.searchQueryText
        
        // buscamos todos los proveedores
        self.buscarProveedor()
    }
    
    // Tabla
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articulos.count
    }
    
    // Asignamos valores a las celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "proveedorItemCell") as! ProveedorCell
        // Nombre articulo
        newCell.setName(name: "\(self.articulos[indexPath.row].nombre!)")
        // Codigo de articulo
        newCell.setRIF(rif: "\(self.articulos[indexPath.row].codigo!)")
        return newCell
    }
    
    // Asigamos el valor a la variable Proveedor con el selecionado
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.articulo = self.articulos[indexPath.row]
    }
    
    
    @IBAction func buscarArticuloButton(_ sender: Any) {
        self.searchQueryText = self.queryProveedorInput.text!
        
        if (self.searchQueryText != ""){
            //Filtramos los proveedores
            self.buscarProveedor()
        }
    }
    
    @IBAction func elegirButton(_ sender: Any) {
        self.performSegue(withIdentifier: "returnToArticle", sender: self)
    }
    
    // Preprara
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "returnToArticle" {
            if let destination = segue.destination as? ArticuloController {
                destination.usuario = self.usuario
                destination.proveedor = self.proveedor
                destination.articulos = self.articulos_lista
                destination.articulo = self.articulo
            }
        }
    }
}


// SUBSTRING IN ARRAY EXTENSION

extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return self[Range(start ..< end)]
    }
}
