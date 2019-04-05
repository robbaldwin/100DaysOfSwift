//
//  GameScene.swift
//  SpaceRace
//
//  Created by Rob Baldwin on 04/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var possibleEnemies = ["android", "apple", "linux", "windows"]
    var gameTimer: Timer?
    var enemyTimeInterval: Double = 1.0
    var enemiesGenerated: Int = 0
    var isGameOver = false

    override func didMove(to view: SKView) {
        backgroundColor = .black
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        
        startGame()
    }
    
    func startGame() {
        
        isGameOver = false
        score = 0
        enemyTimeInterval = 1.0
        enemiesGenerated = 0
        
        player = SKSpriteNode(imageNamed: "swift")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        startTimer()
    }
    
    func startTimer() {
        
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: enemyTimeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc
    func createEnemy() {
        
        // Challenge 3 - Added guard !isGameOver to stop creating space debris after the player has died.
        
        guard
            !isGameOver,
            let enemy = possibleEnemies.randomElement()
            else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.name = "enemy"
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        
        // Apply force in the left direction
        sprite.physicsBody?.velocity = CGVector(dx: -150, dy: 0)
        
        // Apply spin
        sprite.physicsBody?.angularVelocity = 5
        
        // How fast things slow down over time: 0 never
        sprite.physicsBody?.linearDamping = 0
        
        // How fast things stop rotating over time: 0 never
        sprite.physicsBody?.angularDamping = 0
        
        // Challenge 2 - Every 20 ememies subtract 0.1 from the timer
        enemiesGenerated += 1
        if enemiesGenerated.isMultiple(of: 20) {
            enemyTimeInterval -= 0.1
            startTimer()
        }
    }
    
    func gameOver() {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
        
        // Method to restart the game after 2 seconds
        // Removes all enemy nodes with a 0.5 second fade out
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            
            guard let children = self?.children else { return }
  
            for node in children {
                if node.name == "enemy" {
                    let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                    let sequence = SKAction.sequence([fadeOut, .removeFromParent()])
                    node.run(sequence)
                }
            }
            self?.startGame()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Challenge 1 - Stop the player from cheating by lifing their finger and tapping elsewhere
        if !isGameOver {
            gameOver()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if !isGameOver {
           gameOver()
        }
    }
}
