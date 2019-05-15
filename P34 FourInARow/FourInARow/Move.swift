//
//  Move.swift
//  FourInARow
//
//  Created by Rob Baldwin on 15/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import GameplayKit
import UIKit

class Move: NSObject, GKGameModelUpdate {
    
    var value: Int = 0
    var column: Int
    
    init(column: Int) {
        self.column = column
    }
}
