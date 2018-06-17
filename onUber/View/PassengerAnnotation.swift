//
//  PassengerAnnotation.swift
//  onUber
//
//  Created by Arif Onur Şen on 8.03.2018.
//  Copyright © 2018 LiniaTech. All rights reserved.
//

import Foundation
import MapKit


class PassangerAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var key: String
    
    init(coordinate: CLLocationCoordinate2D, key: String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
}
