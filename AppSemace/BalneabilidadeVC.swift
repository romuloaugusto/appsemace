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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewTentarNovamente.isHidden = true
        
        print("didLoad BalneabilidadeVC")
        
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
        
        fetchLastBoletins { (result: Result) in
            do {

                if result == Result.Failure {

                    self.viewTentarNovamente.isHidden = false
                }
                
                if result == Result.Success {
                
                    let estadosPontos = self.lastBoletins.estado.points
                    let fortalezaPontos = self.lastBoletins.fortaleza.points
                    let rmfPontos = self.lastBoletins.rmf.points
            
                    for ponto in estadosPontos {
                        self.criarMarcadorNoMapa(ponto: ponto)
                    }
            
                    for ponto in fortalezaPontos {
                        self.criarMarcadorNoMapa(ponto: ponto)
                    }
            
                    for ponto in rmfPontos {
                        self.criarMarcadorNoMapa(ponto: ponto)
                    }
            
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
    }
    
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
        
        let latStr = ponto.lat
        let longStr = ponto.lng
//        let coordenadas = CLLocationCoordinate2DMake(ponto.lat.toDouble()!, ponto.lng.toDouble()!)
        let latDouble = (latStr as NSString).doubleValue
        let longDouble = (longStr as NSString).doubleValue
        let coordenadas = CLLocationCoordinate2DMake(latDouble, longDouble)
        let annotation = PontoAnnotation(title: titulo, status: ponto.status, local: local, coordinate: coordenadas)
       
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        if let annotation = annotation as? PontoAnnotation {
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            } else {
                annotationView?.annotation = annotation
            }
            
            if annotation.status == 0 {
                annotationView?.image = UIImage(named: "swimming")
            } else {
                annotationView?.image = UIImage(named: "caution")
            }
            
            annotationView?.canShowCallout = false
            annotationView?.autoresizesSubviews = true
            
            return annotationView
            
        }
        
        return nil
        
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {
            return
        }
        
        let pontoAnnotation = view.annotation as! PontoAnnotation
        
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        
        let calloutView = views?[0] as! CustomCalloutView
        
        if pontoAnnotation.status == 0 {
            calloutView.pontoDescricaoSituacao.text = SITUACAO_PROPRIA_DESCRICAO
            calloutView.barraTitulo.backgroundColor = COR_PROPRIA
        } else {
            calloutView.pontoDescricaoSituacao.text = SITUACAO_IMPROPRIA_DESCRICAO
            calloutView.barraTitulo.backgroundColor = COR_IMPROPRIA
        }
        
        calloutView.pontoTitulo.text = pontoAnnotation.title
        calloutView.pontoDescricaoLocal.text = pontoAnnotation.local
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: MKAnnotationView.self) {
            for subview in view.subviews {
                subview.removeFromSuperview()
            }
        }
    }
    
}

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}

extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 10.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

enum Result {
    case Success
    case Failure
}



