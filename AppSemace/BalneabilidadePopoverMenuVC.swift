//
//  BalneabilidadePopoverMenuVC.swift
//  AppSemace
//
//  Created by Romulo Augusto on 09/08/17.
//  Copyright © 2017 Romulo. All rights reserved.
//

import UIKit

class BalneabilidadePopoverMenuVC: UIViewController, UIPopoverPresentationControllerDelegate {

    override func viewDidLoad() {
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        super.viewDidLoad()

    }

    
    @IBAction func showLegenda(_ sender: UIButton) {

        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let legendaVC = storyboard.instantiateViewController(withIdentifier: "legendaVC")
        
//        legendaVC.modalPresentationStyle = .popover
//        legendaVC.preferredContentSize = CGSize(width: 300, height: 550)
//        legendaVC.popoverPresentationController?.delegate = self
//        legendaVC.popoverPresentationController?.sourceView = sender
//        legendaVC.popoverPresentationController?.sourceRect = sender.frame
        
        self.present(legendaVC, animated: true, completion: nil)
        
        //self.dismiss(animated: true, completion: nil)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "popoverLegenda" {
            //let legendaVC = segue.destination
            
            //legendaVC.modalPresentationStyle = .popover
            //legendaVC.popoverPresentationController?.delegate = self
            //legendaVC.preferredContentSize = CGSize(width: 300, height: 550)
            //self.present(legendaVC, animated: false, completion: nil)
            //self.dismiss(animated: true, completion: nil)
            
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    

    
}
