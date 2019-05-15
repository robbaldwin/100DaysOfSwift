//
//  Whistle.swift
//  WhatsThatWhistle
//
//  Created by Rob Baldwin on 13/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import CloudKit
import UIKit

class Whistle: NSObject {
    var recordID: CKRecord.ID!
    var genre: String!
    var comments: String!
    var audio: URL!
}
