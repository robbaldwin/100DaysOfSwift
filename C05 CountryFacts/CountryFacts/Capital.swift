//
//  Capital.swift
//  CountryFacts
//
//  Created by Rob Baldwin on 05/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import MapKit
import UIKit

class Capital: NSObject, MKAnnotation {
    
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
