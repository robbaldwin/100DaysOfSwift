//
//  CountryAnnotation.swift
//  CountryFacts
//
//  Created by Rob Baldwin on 05/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import MapKit
import UIKit

class CountryAnnotation: NSObject, MKAnnotation {
    let name: String
    let coordinate: CLLocationCoordinate2D
    
    init(name: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.coordinate = coordinate
    }
}
