//
//  BalneabilidadeModalMenuVC.swift
//  AppSemace
//
//  Created by Romulo Augusto on 15/08/17.
//  Copyright © 2017 Romulo. All rights reserved.
//

import UIKit

class BalneabilidadeModalMenuVC: UIViewController {

    
    @IBOutlet weak var tipoMapaSegmentedControl: UISegmentedControl!
    @IBOutlet weak var modalView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("didLoad Menu VC")
        if let tipoMapaIndex: AnyObject = UserDefaults.standard.object(forKey: "tipoMapaIndex") as AnyObject? {
        
            self.tipoMapaSegmentedControl.selectedSegmentIndex = tipoMapaIndex as! Int
        }
        
        
        self.modalView.layer.cornerRadius = 10
        self.modalView.layer.masksToBounds = true

        // Do any additional setup after loading the view.
    }

    @IBAction func onClickFecharBt(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onChangeedTipoMapaSegmenteControl(_ sender: UISegmentedControl) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(tipoMapaSegmentedControl.selectedSegmentIndex, forKey: "tipoMapaIndex")
        userDefaults.synchronize()
        
        let data: [String: UISegmentedControl] = ["tipoMapaSegmentedControl": tipoMapaSegmentedControl]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "configurarMapa"), object: nil, userInfo: data)
    }
    
    
    @IBAction func voltarBalneabilidadeVC(segue:UIStoryboardSegue) {
        print("voltando...")
        self.dismiss(animated: false, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
