//
//  GameScene.swift
//  SwiftyNinja
//
//  Created by Rob Baldwin on 19/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import AVFoundation
import SpriteKit

enum ForceBomb {
    case never, always, random
}

enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

class GameScene: SKScene {
    
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var livesImages: [SKSpriteNode] = []
    var lives = 3
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var gameOverLabel: SKLabelNode!
    var newGameLabel: SKLabelNode!
    
    var activeSlicePoints: [CGPoint] = []
    var isSwooshSoundActive = false
    var activeEnemies: [SKSpriteNode] = []
    var bombSoundEffect: AVAudioPlayer!
    
    var popupTime = 0.9
    var sequence: [SequenceType] = []
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    var isGameEnded = false
    
    // Challenge 1: Try removing the magic numbers in the createEnemy() method. Instead, define them as constant properties of your class, giving them useful names.
    
    let sceneWidth: CGFloat = 1024
    let edgeInset: CGFloat = 64
    
    var enemyRandomStartPositionX: CGFloat {
        return CGFloat.random(in: edgeInset...(sceneWidth - edgeInset))
    }
    
    let enemyRandomStartPositionY: CGFloat = -128
    
    var enemyRandomAngularVelocity: CGFloat {
        return CGFloat.random(in: -3...3)
    }
    
    var enemyRandomXVelocityLow: CGFloat {
        return CGFloat.random(in: 3...5) * 40
    }
    
    var enemyRandomXVelocityHigh: CGFloat {
        return CGFloat.random(in: 8...15) * 40
    }
    
    var enemyRandomYVelocity: CGFloat {
        return CGFloat.random(in: 24...32) * 40
    }
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        
        createScore()
        createLives()
        createSlices()
        startGame()
    }
    
    func startGame() {
        
        isGameEnded = false
        score = 0
        lives = 3
        popupTime = 0.9
        sequencePosition = 0
        chainDelay = 3
        physicsWorld.speed = 0.85
        activeEnemies.removeAll(keepingCapacity: true)
        sequence.removeAll(keepingCapacity: true)
        nextSequenceQueued = true
        
        for i in 0..<3 {
            livesImages[i].texture = SKTexture(imageNamed: "sliceLife")
        }
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]

        for _ in 0 ... 1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
        }
    }
    
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }
    
    func createLives() {
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            
            livesImages.append(spriteNode)
        }
    }
    
    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameEnded == false else { return }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            
            switch node.name {
                
            case "enemy":
                // Create particle effect over the penguin
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        emitter.removeFromParent()
                    }
                }
                
                // Clear node name so that it can't be swiped again
                node.name = ""
                
                // Disable physics so it doesn't carry on falling
                node.physicsBody?.isDynamic = false
                
                // Scale and fade out penguin
                let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                // After scale & fade out - remove it from the scene
                let seq = SKAction.sequence([group, .removeFromParent()])
                node.run(seq)
                
                // Increment score
                score += 1
                
                // Find position of node in array and remove it
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                // Play sound
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
            case "star":
                // Create particle effect over the penguin
                if let emitter = SKEmitterNode(fileNamed: "sliceHitStar") {
                    emitter.position = node.position
                    addChild(emitter)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        emitter.removeFromParent()
                    }
                }

                // Add Bonus Label
                let bonusLabel = SKLabelNode(text: "+10")
                bonusLabel.fontName = "Chalkduster"
                bonusLabel.fontSize = 100
                bonusLabel.fontColor = .yellow
                bonusLabel.position = node.position
                bonusLabel.zPosition = 1
                addChild(bonusLabel)
                
                let scaleOutBonus = SKAction.scale(to: 0.001, duration: 1)
                let fadeOutBonus = SKAction.fadeOut(withDuration: 1)
                let bonusGroup = SKAction.group([scaleOutBonus, fadeOutBonus])
                let sequence = SKAction.sequence([bonusGroup, .removeFromParent()])
                bonusLabel.run(sequence)

                // Clear node name so that it can't be swiped again
                node.name = ""
                
                // Disable physics so it doesn't carry on falling
                node.physicsBody?.isDynamic = false
                
                // Scale and fade out penguin
                let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                // After scale & fade out - remove it from the scene
                let seq = SKAction.sequence([group, .removeFromParent()])
                node.run(seq)
                
                // Increment score
                score += 10
                
                // Find position of node in array and remove it
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                // Play sound
                run(SKAction.playSoundFileNamed("smash.wav", waitForCompletion: false))
                
            case "bomb":
                // The node called "bomb" is the bomb image, which is inside the bomb container. So, we need to reference the node's parent when looking up our position,
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                
                // Create particle effect over the bomb
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        emitter.removeFromParent()
                    }
                }
                
                // Clear node name so that it can't be swiped again
                node.name = ""
                
                // Disable physics so it doesn't carry on falling
                bombContainer.physicsBody?.isDynamic = false
                
                
                // Scale, fade out & remove
                let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                let seq = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(seq)
                
                // Find position of node in array and remove it
                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    activeEnemies.remove(at: index)
                }
                
                // Play sound
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
                
            default:
                break
            }
        }
    }
    
    func endGame(triggeredByBomb: Bool) {
        guard isGameEnded == false else { return }
        
        isGameEnded = true
        physicsWorld.speed = 0
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        
        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
        
        for enemy in activeEnemies {
            enemy.removeFromParent()
        }
        
        // Challenge 3: Add a “Game over” sprite node to the game scene when the player loses all their lives.
        
        gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "Chalkduster"
        gameOverLabel.fontSize = 70
        gameOverLabel.fontColor = .white
        gameOverLabel.zPosition = 1
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.xScale = 0.001
        gameOverLabel.yScale = 0.001
        addChild(gameOverLabel)
        
        let gameOverAppear = SKAction.scale(to: 1.0, duration: 0.5)
        gameOverLabel.run(gameOverAppear)
        
        newGameLabel = SKLabelNode(text: "New Game")
        newGameLabel.fontName = "Chalkduster"
        newGameLabel.fontSize = 50
        newGameLabel.fontColor = .white
        newGameLabel.zPosition = 8
        newGameLabel.position = CGPoint(x: 512, y: -50)
        newGameLabel.name = "newGame"
        addChild(newGameLabel)
        
        let newGameAppear = SKAction.move(to: CGPoint(x: 512, y: 185), duration: 0.5)
        
        newGameLabel.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), newGameAppear]))
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let nodesAtPoint = nodes(at: location)
        if nodesAtPoint.contains(where: { $0.name == "newGame" }) {
            gameOverLabel.removeFromParent()
            newGameLabel.removeFromParent()
            startGame()
            return
        }
        
        activeSlicePoints.removeAll(keepingCapacity: true)
        activeSlicePoints.append(location)
        
        redrawActiveSlice()
        
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        activeSliceBG.alpha = 1.0
        activeSliceFG.alpha = 1.0
    }
    
    func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1..<activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    func createEnemy(forceBomb: ForceBomb = .random) {
        let enemy: SKSpriteNode
        
        var enemyType = Int.random(in: 0...7)
        
        if forceBomb == .never {
            enemyType = 1
        } else if forceBomb == .always {
            enemyType = 0
        }
        
        switch enemyType {
            
        case 0:
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }
            
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
            
        case 1...6:
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
            
        case 7:
            // Challange 2: Create a new, fast-moving type of enemy that awards the player bonus points if they hit it.
            enemy = SKSpriteNode(imageNamed: "star")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "star"
            
        default:
            fatalError("enemyType out of range!")
        }

        // Challenge 1: Try removing the magic numbers in the createEnemy() method. Instead, define them as constant properties of your class, giving them useful names.
        
        let randomPosition = CGPoint(x: enemyRandomStartPositionX, y: enemyRandomStartPositionY)
        enemy.position = randomPosition
        
        var randomXVelocity: CGFloat
        var randomYVelocity = enemyRandomYVelocity
        var angularVelocity = enemyRandomAngularVelocity
        
        if randomPosition.x < sceneWidth * 0.25 {
            randomXVelocity = enemyRandomXVelocityHigh
        } else if randomPosition.x < sceneWidth * 0.5 {
            randomXVelocity = enemyRandomXVelocityLow
        } else if randomPosition.x < sceneWidth * 0.75 {
            randomXVelocity = -enemyRandomXVelocityLow
        } else {
            randomXVelocity = -enemyRandomXVelocityHigh
        }
        
        
        if enemy.name == "star" {
            randomXVelocity *= 1.2
            randomYVelocity *= 1.2
            angularVelocity *= 1.5
        }

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity, dy: randomYVelocity)
        enemy.physicsBody?.angularVelocity = enemyRandomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    func subtractLife() {
        lives -= 1
        
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration: 0.1))
    }
    
    override func update(_ currentTime: TimeInterval) {
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            // no bombs - stop the bomb sound
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
        
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    if node.name == "enemy" {
                        // If fail to swipe penguin - lose a life
                        node.name = ""
                        subtractLife()
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "star" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }
                
                nextSequenceQueued = true
            }
        }
    }
    
    func tossEnemies() {
        guard isGameEnded == false else { return }
        
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
            
        case .one:
            createEnemy()
            
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
            
        case .two:
            createEnemy()
            createEnemy()
            
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .chain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) { [weak self] in self?.createEnemy() }
            
        case .fastChain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) { [weak self] in self?.createEnemy() }
        }
        
        sequencePosition += 1
        nextSequenceQueued = false
    }
}
