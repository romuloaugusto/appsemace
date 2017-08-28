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

struct LastBoletins {
    let fortaleza: Fortaleza
    let estado: Estado
    let rmf: RMF
    
    init(json: [String: Any]) {
        self.fortaleza = Fortaleza(json: (json["Fortaleza"] as? [String: Any])!)
        self.estado = Estado(json: (json["Estado"] as? [String: Any])!)
        self.rmf = RMF(json: (json["RMF"] as? [String: Any])!)
    }
}

struct Fortaleza {
    let remote_boletim_id: Int
    let is_new: Bool
    let data_publicacao: Date
    var points: [Point]
    
    init(json: [String: Any]) {
        self.remote_boletim_id = json["remote_boletim_id"] as? Int ?? 0
        self.is_new = json["is_new"] as? Bool ?? false
        self.data_publicacao = json["data_publicacao"] as? Date ?? Date()
        self.points = [Point]()
        
        if let pts = json["points"] as? [[String: Any]] {
            for i in 0..<pts.count {
                self.points.append(Point(json: pts[i]))
            }
        }
    }
}

struct Estado {
    let remote_boletim_id: Int
    let is_new: Bool
    let data_publicacao: Date
    var points: [Point]
    
    init(json: [String: Any]) {
        self.remote_boletim_id = json["remote_boletim_id"] as? Int ?? 0
        self.is_new = json["is_new"] as? Bool ?? false
        self.data_publicacao = json["data_publicacao"] as? Date ?? Date()
        self.points = [Point]()
        
        if let pts = json["points"] as? [[String: Any]] {
            for i in 0..<pts.count {
                self.points.append(Point(json: pts[i]))
            }
        }
    }
}

struct RMF {
    let remote_boletim_id: Int
    let is_new: Bool
    let data_publicacao: Date
    var points: [Point]
    
    init(json: [String: Any]) {
        self.remote_boletim_id = json["remote_boletim_id"] as? Int ?? 0
        self.is_new = json["is_new"] as? Bool ?? false
        self.data_publicacao = json["data_publicacao"] as? Date ?? Date()
        self.points = [Point]()
        if let pts = json["points"] as? [[String: Any]] {
            for i in 0..<pts.count {
                self.points.append(Point(json: pts[i]))
            }
        }
    }
}

struct Point {
    let remote_point_id: Int
    let name: String
    let lat: String
    let lng: String
    let status: Int
    
    init(json: [String: Any]) {
        self.remote_point_id = json["remote_point_id"] as? Int ?? 0
        self.name = json["name"] as? String ?? ""
        self.lat = json["lat"] as? String ?? ""
        self.lng = json["lng"] as? String ?? ""
        self.status = json["status"] as? Int ?? 0
    }
}

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
        
        
        //FIX-ME: Tratar quando web service estiver fora do ar.
        
        
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let location = CLLocationCoordinate2DMake(self.FORTALEZA_LATITUDE, self.FORTALEZA_LONGITUDE)
        let region = MKCoordinateRegion(center: location, span: span)
        
        fetchLastBoletins { (result: Result) in
            do {
                print("entrou no fetch")
                if result == Result.Failure {
                    print("retornou falha")

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
            
                print("terminou o fech")

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
        
        let coordenadas = CLLocationCoordinate2DMake(ponto.lat.toDouble()!, ponto.lng.toDouble()!)
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
        print("inicio fetch")
        
        guard let url = URL(string: URL_SERVICE_LAST_BOLETINS) else {
            
            print("erro no servico")
            return
        
        }
        
        print("criou url")
        
        URLSession.shared.dataTask(with: url) { (data, responde, err) -> Void in
            print("inicio carregar dados")
            
//            guard err != nil else {
//                print("error \(err)")
//                return complete( Result.Failure )
//            }
            guard let data = data else {
                print("no data")
                return complete( Result.Failure )
            }
            
//            guard let data = data else {
//                print("erro carregar dados")
//                return
//            }
            
            do {
                print("inicio serializar")
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                
                self.lastBoletins = LastBoletins(json: json)
                
                print("fim serializar")
                
            } catch let jsonErr {
                print("Erro ao serializar o json: ", jsonErr)
            }
            
            print("vai completar")
            complete(Result.Success)
            print("completou")
            
            }.resume()
        print("resumou")
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
    
    //    @IBAction func segmentedControlAction(sender: UISegmentedControl!) {
    //        switch (sender.selectedSegmentIndex) {
    //        case 0:
    //            mapView.mapType = .standard
    //        case 1:
    //            mapView.mapType = .satellite
    //        default:
    //            mapView.mapType = .hybrid
    //        }
    //    }
    //
    //
    //    @IBAction func showMenu(_ sender: UIBarButtonItem) {
    //
    //        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    //        let popoverMenu = storyboard.instantiateViewController(withIdentifier: "BalneabilidadePopover")
    //        popoverMenu.modalPresentationStyle = .popover
    //        popoverMenu.preferredContentSize = CGSize(width: 140, height: 100)
    //
    //
    //        popoverMenu.popoverPresentationController?.delegate = self
    //        popoverMenu.popoverPresentationController!.barButtonItem = sender
    //
    //        self.present(popoverMenu, animated: true, completion: nil)
    //
    //    }
    //
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "popoverLegenda" {
    //            let popoverLegenda = segue.destination
    //
    //            popoverLegenda.popoverPresentationController?.delegate = self
    //            popoverLegenda.modalPresentationStyle = .popover
    //            popoverLegenda.preferredContentSize = CGSize(width: 300, height: 500)
    //        }
    //    }
    //
    //
    //
    // UIPopoverPresentationControllerDelegate method
    //    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    //
    //        return UIModalPresentationStyle.none
    //    }
    //
    //    @IBAction func showMenuActivity(_ sender: UIBarButtonItem) {
    //        let img = UIImage(named: "caution")
    //
    //        var images = [UIImage]()
    //
    //        images.append(img!)
    //
    //        let activity = UIActivityViewController(activityItems: images, applicationActivities: nil)
    //        activity.modalPresentationStyle = .popover
    //        activity.popoverPresentationController?.barButtonItem = sender
    //
    //        self.present(activity, animated: true, completion: nil)
    //    }
    //
    //    @IBAction func showCustoActionSheet(_ sender: UIBarButtonItem) {
    //        self.performSegue(withIdentifier: "instrucoesSegue", sender: nil)
    //
    //    }
    //
    //
    //    @IBAction func showActionSheet(_ sender: UIBarButtonItem) {
    //
    //       let actionSheet = UIAlertController(title: "Escolha", message: nil, preferredStyle: .actionSheet)
    //
    //
    //        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
    //            print("Cancel")
    //        }
    //
    //        let legendaActionButton = UIAlertAction(title: "Instruções", style: .default) { action -> Void in
    //            self.performSegue(withIdentifier: "legendaSegue", sender: nil)
    //        }
    //
    //        let tiposMapa = ["Tipo 1", "Tipo 2", "Tipo 3"]
    //
    //        let segment = UISegmentedControl(items: tiposMapa)
    //
    //
    //        let margin:CGFloat = 10.0
    //        let rect = CGRect(x: margin, y: margin, width: actionSheet.view.bounds.size.width - margin * 4.0, height: 120)
    //        let customView = UIView(frame: rect)
    //        customView.addSubview(segment)
    //
    //        customView.backgroundColor = .green
    //
    //        actionSheet.view.addSubview(segment)
    //        
    //        actionSheet.addAction(cancelActionButton)
    //        actionSheet.addAction(legendaActionButton)
    //        
    //        actionSheet.popoverPresentationController?.barButtonItem = sender
    //        
    //        self.present(actionSheet, animated: true, completion: nil)
    //        
    //    }
    
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



