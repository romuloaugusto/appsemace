//
//  Legenda.swift
//  AppSemace
//
//  Created by Romulo Augusto on 13/08/17.
//  Copyright © 2017 Romulo. All rights reserved.
//

import UIKit

class LegendaVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
self.tabBarController?.tabBar.isHidden = false
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "legendaSegue" {
//
//        }
//    
//    }
    
    
    

}
