//
//  GameScene.swift
//  ExplodingMonkeys
//
//  Created by Rob Baldwin on 06/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import SpriteKit

enum CollisionType: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    
    var windSpeed: CGFloat = 0
    let earthsGravity: CGFloat = -9.8
    
    var buildings = [BuildingNode]()
    weak var viewController: GameViewController!

    override func didMove(to view: SKView) {

        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        createBuildings()
        createPlayers()
        physicsWorld.contactDelegate = self
        setWind()
    }
    
    func createBuildings() {
        var currentX: CGFloat = -15
        
        while currentX < 1024 {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            currentX += size.width + 2
            
            let building = BuildingNode(color: UIColor.red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup()
            addChild(building)
            
            buildings.append(building)
        }
    }
    
    func createPlayers() {
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionType.banana.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
        player1.physicsBody?.isDynamic = false
        
        let player1Building = buildings[1]
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        addChild(player1)
        
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionType.banana.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
        player2.physicsBody?.isDynamic = false
        
        let player2Building = buildings[buildings.count - 2]
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        addChild(player2)
    }
    
    func setWind() {
        
        // Challenge 3: Use the physics world’s gravity to add random wind to each level, making sure to add a label telling players the direction and strength.

        windSpeed = CGFloat.random(in: -2...2)
        physicsWorld.gravity = CGVector(dx: windSpeed, dy: earthsGravity)

        let displayedSpeed = Int(abs(windSpeed) * 15)
        
        switch windSpeed {
        case _ where windSpeed < 0:
            viewController.windLabel.text = "<<< Wind \(displayedSpeed)"
        case _ where windSpeed > 0:
            viewController.windLabel.text = "Wind \(displayedSpeed) >>>"
        default:
            viewController.windLabel.text = "Wind calm"
        }
    }
    
    func launch(angle: Int, velocity: Int) {
        let speed = Double(velocity) / 10.0
        let radians = deg2rad(degrees: angle)
 
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionType.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionType.building.rawValue | CollisionType.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionType.building.rawValue | CollisionType.player.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)
        
        if currentPlayer == 1 {
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20

            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player1.run(sequence)

            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        } else {
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player2.run(sequence)
            
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
    }
    
    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * Double.pi / 180
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }
        
        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode as! BuildingNode, atPoint: contact.contactPoint)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player1" {
            destroy(player: player1)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player2" {
            destroy(player: player2)
        }
    }
    
    func destroy(player: SKSpriteNode) {

        // Challenge 1: Add code and UI to track the player scores across levels, then make the game end after one player has won three times.
        
        var resetScores = false
        
        if currentPlayer == 1 {
            viewController.player1Score += 1
        } else {
            viewController.player2Score += 1
        }
        
        if viewController.player1Score == 3 || viewController.player2Score == 3 {
            viewController.playerNumber.text = "Game Over! Player \(currentPlayer) wins!"
            resetScores = true
        }
        
        let explosion = SKEmitterNode(fileNamed: "hitPlayer")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        banana?.removeFromParent()

        restartGame(resetScores: resetScores)
    }
    
    func restartGame(resetScores: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            
            guard let self = self else { return }
            
            if resetScores {
                self.viewController.player1Score = 0
                self.viewController.player2Score = 0
            }
            
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController.currentGame = newGame
            
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        
        viewController.activatePlayer(number: currentPlayer)
    }

    func bananaHit(building: BuildingNode, atPoint contactPoint: CGPoint) {
        let buildingLocation = convert(contactPoint, to: building)
        building.hit(at: buildingLocation)
        
        let explosion = SKEmitterNode(fileNamed: "hitBuilding")!
        explosion.position = contactPoint
        addChild(explosion)
        
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        
        if banana.position.y < -1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }

}
