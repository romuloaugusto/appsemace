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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
}
