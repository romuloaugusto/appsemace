//
//  Structs.swift
//  AppSemace
//
//  Created by Romulo Augusto on 30/08/17.
//  Copyright © 2017 Romulo. All rights reserved.
//

import Foundation

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
