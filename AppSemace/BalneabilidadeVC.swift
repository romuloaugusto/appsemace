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

class BalneabilidadeVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewTentarNovamente: UIView!
    
    var lastBoletins: LastBoletins!
    
    let COR_IMPROPRIA = UIColor(red: 255/255, green: 53/255, blue: 52/255, alpha: 1) //"FF3534"
    let COR_PROPRIA = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1) //"009688"
    let SITUACAO_PROPRIA_DESCRICAO = "Própria para banho"
    let SITUACAO_IMPROPRIA_DESCRICAO = "Imprópria para banho"
    let FORTALEZA_LATITUDE = -3.7319
    let FORTALEZA_LONGITUDE = -38.5267
    let URL_SERVICE_LAST_BOLETINS = "http://localhost:8080/SemaceMobileWS/webService/balneabilidade/boletim/lastBoletins?id_fortaleza=1&id_estado=1&id_rmf=1"
    
    var buttonInfo: UIButton {
        let button = UIButton(type: .infoDark)
        button.addTarget(self, action: #selector(self.showInfoScreen), for: .touchUpInside)
        return button
    }
    
    func showInfoScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuViewController = storyboard.instantiateViewController(withIdentifier: "menuVC") as! MenuVC
        self.present(menuViewController, animated: true, completion: nil)
    }
    
    @IBAction func onClickTryAgain(_ sender: UIButton) {
        self.viewDidLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonInfo)
        self.viewTentarNovamente.isHidden = true
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        
        if let tipoMapaIndex: AnyObject = UserDefaults.standard.object(forKey: "tipoMapaIndex") as AnyObject? {
            let index = tipoMapaIndex as! Int
            self.alterarTipoMapa(index: index)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.configurarMapa(_:)), name: NSNotification.Name(rawValue: "configurarMapa"), object: nil)

        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let location = CLLocationCoordinate2DMake(self.FORTALEZA_LATITUDE, self.FORTALEZA_LONGITUDE)
        let region = MKCoordinateRegion(center: location, span: span)
        
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
        //let titulo = arrayPalavrasDescricaoPonto[0].trimmingCharacters(in: .whitespacesAndNewlines)
        
        if arrayPalavrasDescricaoPonto.count > 1 {
            local = arrayPalavrasDescricaoPonto[1]
        } else {
            local = arrayPalavrasDescricaoPonto[0]
        }
        
        local = local.trimmingCharacters(in: .whitespacesAndNewlines)
        
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

    func fetchLastBoletins(complete: @escaping (Result) -> Void) {
        
        guard let url = URL(string: URL_SERVICE_LAST_BOLETINS) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) -> Void in

            guard let data = data else { return complete(Result.Failure) }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                
                self.lastBoletins = LastBoletins(json: json)
            } catch let jsonErr {
                print("Erro ao serializar o json: ", jsonErr)
            }
            
            complete(Result.Success)
            
        }.resume()
    }
}

extension BalneabilidadeVC: MKMapViewDelegate {
    
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
            
            let mapsIcon = UIImage(named: "alert")
            mapAppButton.setImage(mapsIcon, for: .normal)
            
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
            
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if UIApplication.shared.canOpenURL(URL(string: "maps://")!) {
            let location = view.annotation as! PontoAnnotation
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location.mapItem().openInMaps(launchOptions: launchOptions)
        } else {
            let alertController = UIAlertController(title: "Aplicativo não está disponível", message: "Para utilizar o recurso de traçar rota é necessário ter o aplicativo Mapa instalado.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okButton)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let ponto = view.annotation as! PontoAnnotation
            let span = MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
            let location = CLLocationCoordinate2DMake(ponto.coordinate.latitude, ponto.coordinate.longitude)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
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



