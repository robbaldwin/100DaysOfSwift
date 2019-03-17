//
//  Petition.swift
//  WhiteHousePetitions
//
//  Created by Rob Baldwin on 13/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import Foundation

struct Petition: Codable {
    var id: String
    var title: String
    var body: String
    var issues: [Issue]
    var signatureThreshold: Int
    var signatureCount: Int
    var signaturesNeeded: Int
    var url: String
    var created: Double
    var deadline: Double
    var status: String
}

struct Issue: Codable {
    var name: String
}


