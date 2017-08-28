//
//  PontoAnalise.swift
//  semace-mobile
//
//  Created by Romulo Augusto on 17/07/17.
//  Copyright © 2017 Semace. All rights reserved.
//

import Foundation

class PontoAnalise {
    
    private var _id: Int!
    private var _descricao: String!
    private var _latitude: String!
    private var _longitude: String!
    private var _status: Int!
    private var _boletim: Boletim!
    
    var id: Int {
        set {
            _id = newValue
        }
        get {
            return _id
        }
    }
    
    var descricao: String {
        set {
            _descricao = newValue
        }
        get {
            return _descricao
        }
    }
    
    var latitude: String {
        set {
            _latitude = newValue
        }
        get {
            return _latitude
        }
    }
    
    var longitude: String {
        set {
            _longitude = newValue
        }
        get {
            return _longitude
        }
    }
    
    var status: Int {
        set {
            _status = newValue
        }
        get {
            return _status
        }
    }
    
    var boletim: Boletim {
        set {
            _boletim = newValue
        }
        get {
            return _boletim
        }
    }
    
}
