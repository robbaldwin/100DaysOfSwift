//
//  WhackSlot.swift
//  Whack-A-Penguin
//
//  Created by Rob Baldwin on 28/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import SpriteKit
import UIKit

class WhackSlot: SKNode {
    
    var charNode: SKSpriteNode!
    var isVisible: Bool = false
    var isHit: Bool = false
    
    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)
        addChild(cropNode)
    }
    
    func show(hideTime: Double) {
        if isVisible { return }
        
        runMudParticleEmitter(isShowingChar: true)
        
        charNode.xScale = 1
        charNode.yScale = 1
        
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        if !isVisible { return }
        
        runMudParticleEmitter(isShowingChar: false)
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        isVisible = false
    }
    
    func hit() {
        isHit = true
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [weak self] in
            self?.isVisible = false
        }
        let sequence = SKAction.sequence([delay, hide, notVisible])
        charNode.run(sequence)
        
        
        guard let smoke = SKEmitterNode(fileNamed: "Smoke") else { return }
        smoke.position = charNode.position
        
        let smokeAction = SKAction.sequence([
            SKAction.run { [weak self] in self?.addChild(smoke) },
            SKAction.wait(forDuration: 3.0),
            SKAction.run { smoke.removeFromParent() }])
        
        run(smokeAction)
        
    }
    
    func runMudParticleEmitter(isShowingChar: Bool) {
        
        let xPosition = charNode.position.x
        var yPosition: CGFloat
        
        if isShowingChar {
            yPosition = charNode.position.y + 80
        } else {
            yPosition = charNode.position.y
        }
        
        guard let mud = SKEmitterNode(fileNamed: "Mud") else { return }
        mud.position = CGPoint(x: xPosition, y: yPosition)
        
        let mudAction = SKAction.sequence([
            SKAction.run { [weak self] in self?.addChild(mud) },
            SKAction.wait(forDuration: 1.0),
            SKAction.run { mud.removeFromParent() }])
        
        run(mudAction)
    }
}
