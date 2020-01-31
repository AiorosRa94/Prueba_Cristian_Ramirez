//
//  corporacion.swift
//  Prueba_Cristian_Ramirez
//
//  Created by Cristian Ramirez Sanchez on 30/01/20.
//  Copyright © 2020 CristianRamirezSanchez. All rights reserved.
//

import UIKit
import CoreData
class corporacion: UIViewController {

    
    @IBOutlet var descripcion: UITextView!
    
    @IBOutlet var contenedorNoticias: UIScrollView!
    @IBOutlet var tituloCorporacion: UINavigationItem!
    @IBOutlet var imgLogo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        let idCorpDef = defaults.integer(forKey: "idCorp")

        print(idCorpDef)
        mostrarDatosCorp(idCorp: idCorpDef)
        mostrarDatosEmerg(idCorp: idCorpDef)
        // Do any additional setup after loading the view.
    }
    
    func mostrarDatosCorp(idCorp:Int){
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Corporacion")
    do{
        fetchRequest.predicate = NSPredicate(format: "idCorp = '\(idCorp)'")
        let result = try? managedContext.fetch(fetchRequest)
        for data in result as! [NSManagedObject]{
            tituloCorporacion.title = data.value(forKey: "nombre") as! String
            descripcion.text!  = data.value(forKey: "descripcion") as! String
            let logo  = URL(string:data.value(forKey: "logo") as! String)
            let data = try? Data(contentsOf: logo!)
            imgLogo.image = UIImage(data: data!)
        }
    }
    }
    
    func mostrarDatosEmerg(idCorp:Int){
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Emergencia")
        var salto = 0

    do{
        fetchRequest.predicate = NSPredicate(format: "idCorp = '\(idCorp)'")
        let result = try? managedContext.fetch(fetchRequest)
        for data in result as! [NSManagedObject]{
            let fecha = data.value(forKey: "fecha") as! String
            let lugar = data.value(forKey: "lugar") as! String
            let descripcion = data.value(forKey: "descripcion") as! String
            
            self.contenedorNoticias.contentSize = CGSize(width: self.contenedorNoticias.contentSize.width, height: self.contenedorNoticias.contentSize.height + 100)

            
            print(fecha,lugar,descripcion)
          /* stackview del contenido de los botones de llamada y mapas */
            let lblLugar = UILabel()
            let lblFecha = UILabel()
            let txtDescripcion = UITextView()
           
            lblLugar.text = lugar
            lblLugar.textColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
            lblLugar.font = lblLugar.font.withSize(10)
            lblFecha.text = fecha
            lblFecha.textColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
            lblFecha.font = lblFecha.font.withSize(10)
            txtDescripcion.text = descripcion
            txtDescripcion.font = txtDescripcion.font!.withSize(12)
            txtDescripcion.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

            

            /*Contenedor de fecha y lugar*/
          let header = UIStackView(arrangedSubviews: [lblLugar,lblFecha])
          header.axis = .horizontal
            
          header.frame = CGRect(x:0, y:CGFloat(salto * 100), width: self.contenedorNoticias.frame.size.width, height:75)
          self.contenedorNoticias.addSubview(header)
            
            /*Contenedor de noticia*/
            let noticias = UIStackView(arrangedSubviews: [txtDescripcion])
            noticias.axis = .horizontal
              noticias.frame = CGRect(x:0, y:CGFloat(salto * 100)+50, width: self.contenedorNoticias.frame.size.width, height:100)
            self.contenedorNoticias.addSubview(noticias)
            
            
            salto += 1

        }
    }
    }
}
