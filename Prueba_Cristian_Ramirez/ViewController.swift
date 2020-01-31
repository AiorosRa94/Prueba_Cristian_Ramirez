//
//  ViewController.swift
//  Prueba_Cristian_Ramirez
//
//  Created by Abraham Figueroa Reyes on 28/01/20.
//  Copyright © 2020 Cristian Ramirez Sanchez. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import MapKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet var tituloApp: UINavigationItem!
    @IBOutlet var mapaGeneral: MKMapView!
    var urlImg = ""
    var corporacion = [NSManagedObject]()
    var emergencies = [NSManagedObject]()
    
    let defaults = UserDefaults.standard

    //Administrador de ubicación (CLLocationManager) global para que podamos usarla en clase fácilmente.
    fileprivate let ubicacionManager: CLLocationManager = {
               let manager = CLLocationManager()
               manager.requestWhenInUseAuthorization()
               return manager
           }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapaGeneral.delegate = self as? MKMapViewDelegate
        
        // Se asigna el nombre de la aplicacion
        tituloApp.title = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String
            
           let auxVerif = defaults.integer(forKey: "auxDatos")

            configuracionMapa()
        
        if(auxVerif == 1){
            
            self.borrarCompleto(entity: "Corporacion")
                   self.borrarCompleto(entity: "Emergencia")
                       getDatosCorp()
                       getDatosEmerg()
        }
        else{
                       getDatosCorp()
                       getDatosEmerg()
        }
       
    }

    // MARK: - obtener datos de los corporativos de un JSON

    func getDatosCorp()
        {
            // URL del servicio/JSON
            let url = "https://api.myjson.com/bins/o0cgl"
            Alamofire.request(url, method: .get)
                    .responseJSON { response in
                        if response.data != nil {
                            
                            let json = try? JSON(data: response.data!)
                                if(json?["corporations"][0]["idCorp"].int == nil){
                                self.muestraMensaje(mensaje: "No existen corporaciones")
                            }
                            
                            else{
                                
                                var i = -1
                                repeat {
                                    i += 1
                                    
                                       
                                  let idCorp = json?["corporations"][i]["idCorp"].int
                                  let nombre = json?["corporations"][i]["name"].string
                                  let descripcion = json?["corporations"][i]["description"].string
                                  let logo = json?["corporations"][i]["logo"].string
                                  let coordenadas = json?["corporations"][i]["coordinates"].string
                                  self.guardarCorporacion(idCorp: idCorp!, nombreCorp: nombre!, descripcion: descripcion!, logo: logo!, coordenadas: coordenadas!)
                                  
                                    
                                    self.mapaGeneral.addAnnotation(self.marcador(titulo: nombre!, coordenadas: coordenadas!, descripcion: descripcion!))
                                    self.urlImg = logo!

                                }
                                    while json?["corporations"][i+1]["idCorp"] != JSON.null
                            }
                                
                                                     
                            
                     }
                    }
            defaults.set("1", forKey: "auxDatos")
         }
    
    
    // MARK: - obtener datos de las "noticias" de un JSON

       func getDatosEmerg()
           {
               // URL del servicio/JSON
               let url = "https://api.myjson.com/bins/o0cgl"
               Alamofire.request(url, method: .get)
                       .responseJSON { response in
                           if response.data != nil {
                               
                               let json = try? JSON(data: response.data!)
                                   if(json?["emergencies"][0]["idCopor"].int == nil){
                                   self.muestraMensaje(mensaje: "No existen noticias")
                               }
                               
                               else{
                                   
                                   var i = -1
                                   repeat {
                                       i += 1
                                       
                                          
                                     let idCorp = json?["emergencies"][i]["idCopor"].int
                                     let descripcion = json?["emergencies"][i]["descripción"].string
                                     let fecha = json?["emergencies"][i]["date"].string
                                     let lugar = json?["emergencies"][i]["place"].string
                                    self.guardarEmergencies(idCorp: idCorp!, descripcion: descripcion!,fecha:fecha!,lugar:lugar!)

                                    
                                   }
                                       while json?["emergencies"][i+1]["idCopor"] != JSON.null
                               }
                                   
                                                        
                               
                        }
                       }
            }
    // MARK: - configuracion del mapa

    func configuracionMapa() {
        mapaGeneral.showsUserLocation = true
        mapaGeneral.showsCompass = true
        mapaGeneral.showsScale = true
        
       ubicacionActual()
    }
    
    // MARK: - Ubicacion actual del usuario

    
    func ubicacionActual() {
        ubicacionManager.delegate = self
       ubicacionManager.desiredAccuracy = kCLLocationAccuracyBest
       if #available(iOS 11.0, *) {
          ubicacionManager.showsBackgroundLocationIndicator = true
       } else {
          // Para versiones Anteriores
       }
       ubicacionManager.startUpdatingLocation()
    }
    
    // MARK: - Persistencia de datos Core Data Corporaciones

    
    func guardarCorporacion(idCorp:Int,nombreCorp:String,descripcion:String,logo:String,coordenadas:String){
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
    
      
      let entidad = NSEntityDescription.entity(forEntityName: "Corporacion", in: managedContext)
      let corp = NSManagedObject(entity: entidad!, insertInto: managedContext)
    
        corp.setValue(idCorp, forKey: "idCorp")
        corp.setValue(nombreCorp, forKey: "nombre")
        corp.setValue(descripcion, forKey: "descripcion")
        corp.setValue(logo, forKey: "logo")
        corp.setValue(coordenadas, forKey: "coordenadas")

    
      do {
        try managedContext.save()
        corporacion.append(corp)
      } catch let error as NSError {
        print("No ha sido posible guardar \(error), \(error.userInfo)")
      }
    }
    
    // MARK: - Persistencia de datos Core Data Emergencies

       
    func guardarEmergencies(idCorp:Int,descripcion:String,fecha:String,lugar:String){
         
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
           let managedContext = appDelegate.persistentContainer.viewContext
       
         
         let entidad = NSEntityDescription.entity(forEntityName: "Emergencia", in: managedContext)
         let Emerg = NSManagedObject(entity: entidad!, insertInto: managedContext)
       
           Emerg.setValue(idCorp, forKey: "idCorp")
           Emerg.setValue(descripcion, forKey: "descripcion")
           Emerg.setValue(fecha, forKey: "fecha")
           Emerg.setValue(lugar, forKey: "lugar")

       
         do {
           try managedContext.save()
           emergencies.append(Emerg)
         } catch let error as NSError {
           print("No ha sido posible guardar \(error), \(error.userInfo)")
         }
       }
    // MARK: - Muestra mensaje en pantalla

    func muestraMensaje(mensaje : String) {
        
        let toast = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height-100, width: 300, height: 40))
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toast.textColor = UIColor.white
        toast.textAlignment = .center;
        toast.font = UIFont(name: "Times-New-Roman", size: 12.0)
        toast.text = mensaje
        toast.alpha = 1.0
        toast.layer.cornerRadius = 10
        toast.clipsToBounds  =  true
        self.view.addSubview(toast)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toast.alpha = 0.0
        }, completion: {(isCompleted) in
            toast.removeFromSuperview()
        })
    }
    
    
    
    // MARK: - Marcador para el mapView de posiciones Corp

    func marcador(titulo:String,coordenadas:String,descripcion:String) -> MKPointAnnotation{
        let annotation = MKPointAnnotation()
        let coordenadasCompl    = coordenadas
        let coordenadasArray    = coordenadasCompl.components(separatedBy: ",")

        let latitud   = Double(coordenadasArray[0])
        let longitud = Double(coordenadasArray[1])
        print(latitud!,longitud!)
        
        annotation.title = titulo
        //You can also add a subtitle that displays under the annotation such as
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitud!,longitude: longitud!)
                
        return annotation
    }
    
    // MARK: - Control del tamaño de la imagen

    func resizeImage(image: UIImage, alto: CGFloat, ancho:CGFloat) -> UIImage {

       
        UIGraphicsBeginImageContext(CGSize(width: alto, height: ancho))
        image.draw(in: CGRect(x: 0, y: 0, width: alto, height: ancho))
        let imagen = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return imagen!
    }
    
    // MARK: - getDatas del Core Data
    
    func obtenerIdCoro(nombre:String,entidad:String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entidad)
        
        
        do{
            fetchRequest.predicate = NSPredicate(format: "nombre = '\(nombre)'")
            let result = try? managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject]{
                let defaults = UserDefaults.standard
                defaults.set(data.value(forKey: "idCorp") as! Int, forKey: "idCorp")
            }
        }
        
    }
    
    func borrarCompleto(entity: String) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
    fetchRequest.returnsObjectsAsFaults = false

    do
    {
        let results = try managedContext.fetch(fetchRequest)
        for managedObject in results
        {
            let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
            managedContext.delete(managedObjectData)
        }
    } catch let error as NSError {
        print("Delete all data in \(entity) error : \(error) \(error.userInfo)")
    }
    }
 
}
// MARK: - Extencion CLLocationManagerDelegate para ubicacion del usuario

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations ubicacion: [CLLocation]) {
      
      let ubicacion = ubicacion.last! as CLLocation
      let ubicacionActual = ubicacion.coordinate
      let regio = MKCoordinateRegion(center: ubicacionActual, latitudinalMeters: 500, longitudinalMeters: 500)
      mapaGeneral.setRegion(regio, animated: true)
      //ubicacionManager.stopUpdatingLocation()
   }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print(" Ocurrio un error: \(error.localizedDescription)")
   }
  
    
    
}

// MARK: - Extencion personalizacion de pin

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        

         if !(annotation is MKPointAnnotation) {
                   return nil
               }
               
               let annotationIdentifier = "AnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
               
               if annotationView == nil {
                   annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                   annotationView!.canShowCallout = true
               }
               else {
                   annotationView!.annotation = annotation
               }
               
                let url = URL(string: urlImg)
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist,
        
               let pinImage = UIImage(data: data!)
        annotationView!.image = resizeImage(image: pinImage!, alto: 30, ancho: 30)
        
              return annotationView

    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
       /* guard let annotation = view.annotation else {
            return
        }

        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem.forCurrentLocation()
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate))
        directionRequest.transportType = .automobile
        let directions = MKDirections(request: directionRequest)

        directions.calculate {
            (response, error) -> Void in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }

            if !response.routes.isEmpty {
                let route = response.routes[0]
                DispatchQueue.main.async { [weak self] in
                    mapView.addOverlay(route.polyline)
                }
            }
        }*/
        obtenerIdCoro(nombre: view.annotation!.title!!, entidad: "Corporacion")

        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let corporacion = storyBoard.instantiateViewController(withIdentifier: "corporacion") as! corporacion
        self.present(corporacion, animated:true, completion:nil)
        
     
    }
    
}


