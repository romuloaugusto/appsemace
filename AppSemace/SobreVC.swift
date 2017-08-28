//
//  SecondViewController.swift
//  AppSemace
//
//  Created by Romulo Augusto on 04/08/17.
//  Copyright © 2017 Romulo. All rights reserved.
//

import UIKit

class SobreVC: UIViewController {

    @IBOutlet weak var copyright: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
        let calendar = Calendar.current
        
        let currentYear = calendar.component(.year, from: date)
        self.copyright.text = "Ⓒ \(currentYear) SEMACE"
    }



}

