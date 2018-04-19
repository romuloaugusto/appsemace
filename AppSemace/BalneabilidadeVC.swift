//
//  ViewController.swift
//  semace-mobile
//
//  Created by Romulo Augusto on 14/07/17.
//  Copyright © 2017 Semace. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import QuartzCore

class BalneabilidadeVC: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var tenteNovamenteBt: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var viewTentarNovamente: UIView!
    
    let COR_IMPROPRIA = UIColor(red: 255/255, green: 53/255, blue: 52/255, alpha: 1) //"FF3534"
    let COR_PROPRIA = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1) //"009688"
    
    let SITUACAO_PROPRIA_DESCRICAO = "Própria para banho"
    let SITUACAO_IMPROPRIA_DESCRICAO = "Imprópria para banho"
    
    let FORTALEZA_LATITUDE = -3.7319
    let FORTALEZA_LONGITUDE = -38.5267
    let URL_SERVICE_LAST_BOLETINS = "http://localhost:8080/SemaceMobileWS/webService/balneabilidade/boletim/lastBoletins?id_fortaleza=1&id_estado=1&id_rmf=1"
    
    var lastBoletins: LastBoletins!
    
    func showInfoScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuViewController = storyboard.instantiateViewController(withIdentifier: "balneabilidadeModalMenu") as! BalneabilidadeModalMenuVC
        self.present(menuViewController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        
        let button = UIButton(type: .infoDark)
        button.addTarget(self, action: #selector(self.showInfoScreen), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        super.viewDidLoad()
        self.viewTentarNovamente.isHidden = true
        
        if let tipoMapaIndex: AnyObject = UserDefaults.standard.object(forKey: "tipoMapaIndex") as AnyObject? {
            
            let index = tipoMapaIndex as! Int
            
            self.alterarTipoMapa(index: index)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.configurarMapa(_:)), name: NSNotification.Name(rawValue: "configurarMapa"), object: nil)

        self.mapView.delegate = self
        self.mapView.showsUserLocation = true

        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let location = CLLocationCoordinate2DMake(self.FORTALEZA_LATITUDE, self.FORTALEZA_LONGITUDE)
        let region = MKCoordinateRegion(center: location, span: span)
        
//        inserirPontosNoMapa()
        
        fetchLastBoletins { (result: Result) in
            do {

                if result == Result.Failure {
                    self.viewTentarNovamente.isHidden = false
                }
                
                if result == Result.Success {
                    
                    if let lastBoletins = self.lastBoletins {
                
                        let estadosPontos = lastBoletins.estado.points
                        let fortalezaPontos = lastBoletins.fortaleza.points
                        let rmfPontos = lastBoletins.rmf.points
                
                        for ponto in estadosPontos {
                            self.criarMarcadorNoMapa(ponto: ponto)
                        }
                
                        for ponto in fortalezaPontos {
                            self.criarMarcadorNoMapa(ponto: ponto)
                        }
                
                        for ponto in rmfPontos {
                            self.criarMarcadorNoMapa(ponto: ponto)
                        }
                    }
            
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
    }
    
    
    
//    func inserirPontosNoMapa() {
//        let pino1 = PontoAnnotation(title: "Caça e Pesca", status: 1, local: "", coordinate: CLLocationCoordinate2D(latitude: -3.76332039620585768, longitude: -38.438932797815219))
//
//        let pino2 = PontoAnnotation(title: "Posto 2 - Entre os Postos dos Bombeiros 07 e 08", status: 1, local: "", coordinate: CLLocationCoordinate2D(latitude: -3.75789435769027902, longitude: -38.4418180441826394))
//
//        let pino3 = PontoAnnotation(title: "Posto 3 - Entre os Postos dos Bombeiros 06 e 07", status: 0, local: "", coordinate: CLLocationCoordinate2D(latitude: -3.75789435769027902, longitude: -38.4418180441826394))
//
//        let pino4 = PontoAnnotation(title: "Posto 4 - Entre o  Posto dos Bombeiros 06 até a Praça 31 de Março", status: 0, local: "", coordinate: CLLocationCoordinate2D(latitude: -3.75288420133663658, longitude: -38.4443247573645266))
//
//        let pino5 = PontoAnnotation(title: "Posto 5 - Entre a Praça 31 de Março até Posto dos Bombeiros 04", status: 0, local: "", coordinate: CLLocationCoordinate2D(latitude: -3.74621013236985556, longitude: -38.4478681100133457))
//
//        let pino6 = PontoAnnotation(title: "Posto 6 - Entre os Postos dos Bombeiros 03 e 04", status: 0, local: "", coordinate: CLLocationCoordinate2D(latitude: -3.74170641570244689, longitude: -38.450158302958414))
//
//        let pino7 = PontoAnnotation(title: "Posto 7 - Entre os Postos dos Bombeiros 02 e 03", status: 0, local: "", coordinate: CLLocationCoordinate2D(latitude: -3.73503213392262534, longitude: -38.4534223921194851))
//
//        let pino8 = PontoAnnotation(title: "Posto 8 - Entre os Postos dos Bombeiros 01 e 02", status: 0, local: "", coordinate: CLLocationCoordinate2D(latitude: -3.72862937788683313, longitude: -38.4569294022229755))
//
//        let pino9 = PontoAnnotation(title: "Posto 9 - Entre a rua Ismael Pordeus até  Posto dos Bombeiros 01", status: 1, local: "", coordinate: CLLocationCoordinate2D(latitude: -3.72213581878156496, longitude: -38.4599231147001532))
//
//        let pino10 = PontoAnnotation(title: "Posto 10 - Entre o Farol até a rua Ismael Pordeus", status: 1, local: "", coordinate: CLLocationCoordinate2D(latitude: -3.71859040891775727, longitude: -38.4612760507510814))
//
//        let pino11 = PontoAnnotation(title: "Posto 11 - Farol", status: 1, local: "", coordinate: CLLocationCoordinate2D(latitude: -3.70847998317649497, longitude: -38.4671985210422989))
//
//        let pino12 = PontoAnnotation(title: "Posto 12 - entre a Praia dos Botes e o Farol", status: 1, local: "", coordinate: CLLocationCoordinate2D(latitude: -3.7180382424365348, longitude: -38.4757026981670123))
//
//        mapView.addAnnotation(pino1)
//        mapView.addAnnotation(pino2)
//        mapView.addAnnotation(pino3)
//        mapView.addAnnotation(pino4)
//        mapView.addAnnotation(pino5)
//        mapView.addAnnotation(pino6)
//        mapView.addAnnotation(pino7)
//        mapView.addAnnotation(pino8)
//        mapView.addAnnotation(pino9)
//        mapView.addAnnotation(pino10)
//        mapView.addAnnotation(pino11)
//        mapView.addAnnotation(pino12)
//
//    }
    
    // handle notification
    func configurarMapa(_ notification: NSNotification) {
        if let segmentedControlTipoMapa = notification.userInfo?["tipoMapaSegmentedControl"] as? UISegmentedControl {
            let index = segmentedControlTipoMapa.selectedSegmentIndex
            self.alterarTipoMapa(index: index)
        }
    }
    
    func alterarTipoMapa(index: Int) {
        if index == 0 {
            mapView.mapType = .standard
        }
        
        if index == 1 {
            mapView.mapType = .hybridFlyover
        }
        
        if index == 2 {
            mapView.mapType = .satelliteFlyover
        }
    }
    
    func criarMarcadorNoMapa(ponto: Point) {
        var local: String
        let arrayPalavrasDescricaoPonto = ponto.name.components(separatedBy: "-")
        let titulo = arrayPalavrasDescricaoPonto[0].trimmingCharacters(in: .whitespacesAndNewlines)
        
        if arrayPalavrasDescricaoPonto.count > 1 {
            local = arrayPalavrasDescricaoPonto[1]
        } else {
            local = arrayPalavrasDescricaoPonto[0]
        }
        
        local = local.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //TESTE ----
        local = ponto.name
        //---------
        let latStr = ponto.lat
        let longStr = ponto.lng
        let latDouble = (latStr as NSString).doubleValue
        let longDouble = (longStr as NSString).doubleValue
        let coordenadas = CLLocationCoordinate2DMake(latDouble, longDouble)
        
        let annotation = PontoAnnotation(title: "", status: ponto.status, local: local, coordinate: coordenadas)
       
        if ponto.status == 0 {
            annotation.image = UIImage(named: "swimming")
        } else {
            annotation.image = UIImage(named: "caution")
        }
        
        self.mapView.addAnnotation(annotation)
    }
    
    @IBAction func onClickTryAgain(_ sender: UIButton) {
        self.viewDidLoad()
    }

    func fetchLastBoletins(complete: @escaping (Result) -> Void) {
        
        guard let url = URL(string: URL_SERVICE_LAST_BOLETINS) else {
            //TODO: Return Result.Failure
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, responde, err) -> Void in

            guard let data = data else {
                return complete( Result.Failure )
            }
            
            do {

                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                
                self.lastBoletins = LastBoletins(json: json)
                
            } catch let jsonErr {
                print("Erro ao serializar o json: ", jsonErr)
            }
            
            complete(Result.Success)
            
            }.resume()

    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard let annotation = annotation as? PontoAnnotation else {return nil }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.image = annotation.image
            annotationView?.canShowCallout = true
            annotationView?.autoresizesSubviews = true
            
            let mapAppButton = UIButton(type: .custom)
            //mapAppButton.setTitle("Rota", for: .normal)
            
            let mapsIcon = UIImage(named: "alert")
            mapAppButton.setImage(mapsIcon, for: .normal)
            //annotationView?.rightCalloutAccessoryView = mapAppButton
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            button.setImage(UIImage(named: "maps_icon"), for: .normal)
            annotationView!.rightCalloutAccessoryView = button
            
            
            let x = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 200))
            
            annotationView?.leftCalloutAccessoryView = x
            
            var situacao = ""
            if annotation.status == 0 {
                situacao = "Própria"
                x.backgroundColor = COR_PROPRIA
            } else {
                situacao = "Imprópria"
                x.backgroundColor = COR_IMPROPRIA
            }
            
            
            let label1 = UILabel()
            label1.text = "\(annotation.local!)\n\nSituação: \(situacao)"
            label1.numberOfLines = 0

            let width = NSLayoutConstraint(item: label1, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.lessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 300)
            label1.addConstraint(width)

            let height = NSLayoutConstraint(item: label1, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 130)
            label1.addConstraint(height)
            annotationView?.detailCalloutAccessoryView = label1
            
            //configureDetailView(annotationView: annotationView!)
            
            
            
           
        } else {
            annotationView?.annotation = annotation
        }
        
        
        //annotationView?.tintColor = .black
        //annotationView?.detailCalloutAccessoryView = self.configureDetailView(annotationView: (annotationView)!)

        return annotationView

    }
    
    func configureDetailView(annotationView: MKAnnotationView) -> UIView {
        let snapshotView = UIView()
        let views = ["snapshotView": snapshotView]
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[snapshotView(50)]", options: [], metrics: nil, views: views))
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[snapshotView(500)]", options: [], metrics: nil, views: views))
        //do your work
        return snapshotView
    }
    
    func configureDetailView2(annotationView: MKAnnotationView) {
        let width = 300
        let height = 200
        
        let snapshotView = UIView()
        let views = ["snapshotView": snapshotView]
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[snapshotView(300)]", options: [], metrics: nil, views: views))
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[snapshotView(200)]", options: [], metrics: nil, views: views))
        
        let options = MKMapSnapshotOptions()
        options.size = CGSize(width: width, height: height)
        options.mapType = .satelliteFlyover
//        options.camera = MKMapCamera(lookingAtCenterCoordinate: annotationView.annotation!.coordinate, fromDistance: 250, pitch: 65, heading: 0)
        options.camera = MKMapCamera(lookingAtCenter: annotationView.annotation!.coordinate, fromDistance: 250, pitch: 65, heading: 0)
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
                if snapshot != nil {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
                    imageView.image = snapshot!.image
                    snapshotView.addSubview(imageView)
            }
        }
        
        annotationView.detailCalloutAccessoryView = snapshotView
    }

    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        guard let annotation = annotation as? PontoAnnotation else { return nil }
//
//        let identifier = "Pin"
//        if #available(iOS 11.0, *) {
//            var view: MKMarkerAnnotationView
//
//            if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
//                dequeueView.annotation = annotation
//                view = dequeueView
//            } else {
//                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                view.canShowCallout = true
//                view.calloutOffset = CGPoint(x: -5, y: -5)
//                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            }
//
//            if annotation.status == 0 { // propria
//                view.markerTintColor = COR_PROPRIA
//            } else {
//                view.markerTintColor = COR_IMPROPRIA
//            }
//
//            return view
//        } else {
//           return nil
//        }
//    }
    
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//
//        if view.annotation is MKUserLocation {
//            return
//        }
//
//        let pontoAnnotation = view.annotation as! PontoAnnotation
//
//        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
//
//        let calloutView = views?[0] as! CustomCalloutView
//
//        if pontoAnnotation.status == 0 {
//            calloutView.pontoDescricaoSituacao.text = SITUACAO_PROPRIA_DESCRICAO
//            calloutView.barraTitulo.backgroundColor = COR_PROPRIA
//        } else {
//            calloutView.pontoDescricaoSituacao.text = SITUACAO_IMPROPRIA_DESCRICAO
//            calloutView.barraTitulo.backgroundColor = COR_IMPROPRIA
//        }
//
//        calloutView.pontoTitulo.text = pontoAnnotation.title
//        calloutView.pontoDescricaoLocal.text = pontoAnnotation.local
//        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
//        view.addSubview(calloutView)
//        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
//    }

//    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//        if view.isKind(of: MKAnnotationView.self) {
//            for subview in view.subviews {
//                subview.removeFromSuperview()
//            }
//        }
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if UIApplication.shared.canOpenURL(URL(string: "maps://")!) {
            let location = view.annotation as! PontoAnnotation
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location.mapItem().openInMaps(launchOptions: launchOptions)
        } else {
            let alertController = UIAlertController(title: "Aplicativo não disponível", message: "Para utilizar o recurso de traçar rota é necessário ter o aplicativo Mapa instalado.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okButton)
            present(alertController, animated: true, completion: nil)
        }
    }
    
}

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}

enum Result {
    case Success
    case Failure
}



