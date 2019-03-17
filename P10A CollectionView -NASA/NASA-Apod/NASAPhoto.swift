//
//  NASAPhoto.swift
//  NASA-Apod
//
//  Created by Rob Baldwin on 17/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import Foundation

struct NASAPhoto: Codable {
    
    var date: String
    var title: String
    var explanation: String
    var url: String

    var imageData: Data?
}
