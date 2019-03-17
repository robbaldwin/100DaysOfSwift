//
//  Person.swift
//  NamesToFaces
//
//  Created by Rob Baldwin on 16/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
