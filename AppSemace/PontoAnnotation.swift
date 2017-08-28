//
//  ImageAnnotation.swift
//  semace-mobile
//
//  Created by Romulo Augusto on 26/07/17.
//  Copyright © 2017 Semace. All rights reserved.
//

import UIKit
import MapKit


class PontoAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var status: Int?
    var local: String?
    var image: UIImage?
    
    
    init(title: String, status: Int, local: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.local = local
        self.status = status
        self.coordinate = coordinate
        self.subtitle = nil
        
    }
}
