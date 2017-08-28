//
//  Boletim.swift
//  semace-mobile
//
//  Created by Romulo Augusto on 18/07/17.
//  Copyright © 2017 Semace. All rights reserved.
//

import Foundation

class Boletim {
    
    var _id: Int!
    var _isNew: Bool!
    var _dataPublicacao: Date!
    var _regiao: Regiao!
    var _pontos = [PontoAnalise]()
    
    var id: Int {
        set {
            _id = newValue
        }
        get {
            return _id
        }
    }
    
    var isNew: Bool {
        set {
            _isNew = newValue
        }
        get {
            return _isNew
        }
    }
    
    var dataPublicacao: Date {
        set {
            _dataPublicacao = newValue
        }
        get {
            return _dataPublicacao
        }
    }
    
    var regiao: Regiao {
        set {
            _regiao = newValue
        }
        get {
            return _regiao
        }
    }
    
    var pontos: [PontoAnalise] {
        set {
            _pontos = newValue
        }
        get {
            return _pontos
        }
    }
        
    
    
}
