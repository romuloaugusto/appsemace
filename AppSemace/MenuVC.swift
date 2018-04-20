//
//  BalneabilidadeModalMenuVC.swift
//  AppSemace
//
//  Created by Romulo Augusto on 15/08/17.
//  Copyright © 2017 Romulo. All rights reserved.
//

import UIKit

class MenuVC: UIViewController {

    @IBOutlet weak var tipoMapaSegmentedControl: UISegmentedControl!
    @IBOutlet weak var modalView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let tipoMapaIndex: AnyObject = UserDefaults.standard.object(forKey: "tipoMapaIndex") as AnyObject? {
            self.tipoMapaSegmentedControl.selectedSegmentIndex = tipoMapaIndex as! Int
        }

        self.modalView.layer.cornerRadius = 10
        self.modalView.layer.masksToBounds = true
    }

    @IBAction func onClickFecharBt(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onChangeedTipoMapaSegmenteControl(_ sender: UISegmentedControl) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(tipoMapaSegmentedControl.selectedSegmentIndex, forKey: "tipoMapaIndex")
        userDefaults.synchronize()
        
        let data: [String: UISegmentedControl] = ["tipoMapaSegmentedControl": tipoMapaSegmentedControl]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "configurarMapa"), object: nil, userInfo: data)
    }
    
    @IBAction func voltarBalneabilidadeVC(segue:UIStoryboardSegue) {
        self.dismiss(animated: false, completion: nil)
    }

}
