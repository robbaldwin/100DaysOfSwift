//
//  Target.swift
//  ShootingGallery
//
//  Created by Rob Baldwin on 08/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import SpriteKit
import UIKit

class Target: SKNode {

    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "duckGood")
        addChild(sprite)
    }
}
