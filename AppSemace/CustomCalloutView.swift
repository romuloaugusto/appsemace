//
//  CustomCalloutView.swift
//  CustomCalloutView
//
//  Created by Malek T. on 3/10/16.
//  Copyright © 2016 Medigarage Studios LTD. All rights reserved.
//

import UIKit

class CustomCalloutView: UIView {

    @IBOutlet weak var pontoTitulo: UILabel!
    @IBOutlet weak var pontoDescricaoSituacao: UILabel!
    @IBOutlet weak var pontoDescricaoLocal: UILabel!
    @IBOutlet weak var barraTitulo: UIView!
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
        if var local = pontoDescricaoLocal.text {
            
            //Corrigindo problema de string com 'ç' ou 'Ç' que quebra a formatação
            local = local.replacingOccurrences(of: "ç", with: "c")
            pontoDescricaoLocal.text = local.replacingOccurrences(of: "Ç", with: "C")
            
            pontoDescricaoLocal.sizeToFit()
        
        }
        
        

    }
    
}
