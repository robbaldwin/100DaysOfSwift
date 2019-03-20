//
//  GameScene.swift
//  Pachinko
//
//  Created by Rob Baldwin on 18/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var scoreLabel: SKLabelNode!
    private var editLabel: SKLabelNode!
    private var scoreForBall: Int = 1
    private var isBallActive: Bool = false
    private var hasBallHitABox: Bool = false
    private let balls: [String] = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
    
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    private var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)

        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)

        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)

        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))

        generateBoxes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        // Retrieve all objects - [SKNode] array - at touch location
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        // EditLabel touched
        if objects.contains(editLabel) {
            editingMode.toggle()
            
        // NewGame touched
        } else if objects.contains(where: { $0.name == "newGame" }){
            for object in objects where object.name == "newGame" {
                object.removeFromParent()
            }
            newGame()

        } else {
            
            // If Editing - remove or add box
            if editingMode {
                if objects.contains(where: { $0.name == "box" }) {
                    for object in objects where object.name == "box" {
                        object.removeFromParent()
                    }
                } else {
                    addBox(at: location)
                }
            
            // Only place a new ball if no other ball is active
            } else if !isBallActive {
                let randomBall = balls.randomElement() ?? "ballRed"
                let ball = SKSpriteNode(imageNamed: randomBall)
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
                ball.physicsBody?.restitution = 0.5
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                ball.position = CGPoint(x: location.x, y: 768)
                ball.name = randomBall
                addChild(ball)
                isBallActive = true
                scoreForBall = 1
            }
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.zPosition = 2
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer .physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.zPosition = 1
        slotGlow.zPosition = 1
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode) {

        if object.name == "good" {
            destroy(ball: ball)
            
            // Prevents user scoring without hitting a box first
            if hasBallHitABox {
                showScore(5, at: object.position, color: .green)
                score += 5
                hasBallHitABox = false
            }
        } else if object.name == "bad" {
            destroy(ball: ball)
            showScore(-5, at: object.position, color: .red)
            score -= 5
            hasBallHitABox = false
        } else if object.name == "box" {
            if let box = object as? SKShapeNode {
                showScore(scoreForBall, at: box.position, color: box.fillColor)
                box.removeFromParent()
                hasBallHitABox = true
                // Particles for destroyed box
                if let boxParticles = SKEmitterNode(fileNamed: "BoxParticles") {
                    boxParticles.particleColorSequence = nil
                    boxParticles.particleColor = box.fillColor
                    boxParticles.position = CGPoint(x: box.frame.midX, y: box.frame.midY)
                    addChild(boxParticles)
                }
            }
            score += scoreForBall
            scoreForBall += 1
        }
    }
    
    func generateBoxes() {
        
        for x in stride(from: 128, to: 896, by: 255) {
            for y in stride(from: 128, to: 750, by: 255) {
                addBox(at: CGPoint(x: x, y: y))
            }
        }
        
        for x in stride(from: 256, to: 768, by: 255) {
            for y in stride(from: 256, to: 750, by: 255) {
                addBox(at: CGPoint(x: x, y: y))
            }
        }
    }
    
    func addBox(at location: CGPoint) {
        
        // Changed from SKSpriteNode to SKShapeNode to allow rounded corners
        let box = SKShapeNode(rect: CGRect(x: 0, y: 0, width: Int.random(in: 64...128), height: 16), cornerRadius: 8)
        let color = SKColor(
            // Min value changed to 0.2 to prevent from being too dark
            red: CGFloat.random(in: 0.2...1),
            green: CGFloat.random(in: 0.2...1),
            blue: CGFloat.random(in: 0.2...1),
            alpha: 1)
        box.fillColor = color
        box.strokeColor = color
        box.zRotation = CGFloat.random(in: 1...3)
        box.name = "box"
        box.position = location
        if let path = box.path {
            box.physicsBody = SKPhysicsBody(edgeChainFrom: path)
        }
        box.physicsBody?.isDynamic = false
        addChild(box)
    }
    
    func showScore(_ amount: Int, at location: CGPoint, color: SKColor) {
        
        // Displays an animated score
        let scoreAlert = SKLabelNode()
        if amount < 0 {
            scoreAlert.text = "\(amount)"
        } else {
            scoreAlert.text = "+\(amount)"
        }
        scoreAlert.fontName = "Chalkduster"
        scoreAlert.fontSize = 75
        scoreAlert.fontColor = color
        scoreAlert.position = location
        scoreAlert.zPosition = 100
        addChild(scoreAlert)
        
        let appear = SKAction.group([
            SKAction.move(by: CGVector(dx: 0, dy: 50), duration: 0.25),
            SKAction.fadeIn(withDuration: 0.25)])
        let disappear = SKAction.group([
            SKAction.move(by: CGVector(dx: 0, dy: 50), duration: 0.25),
            SKAction.fadeOut(withDuration: 0.25)])
        let sequence = SKAction.sequence([appear, disappear, SKAction.removeFromParent()])
        scoreAlert.run(sequence)
    }
    
    func destroy(ball: SKNode) {
        
        guard let name = ball.name else { return }
        
        if let explodeParticles = SKEmitterNode(fileNamed: "ExplodeParticles") {
            
            // This line is required else the particleColor cannot be set
            explodeParticles.particleColorSequence = nil
            
            switch name {
            case "ballBlue":
                explodeParticles.particleColor = BallColor.blue
            case "ballCyan":
                explodeParticles.particleColor = BallColor.cyan
            case "ballGreen":
                explodeParticles.particleColor = BallColor.green
            case "ballGrey":
                explodeParticles.particleColor = BallColor.grey
            case "ballPurple":
                explodeParticles.particleColor = BallColor.purple
            case "ballRed":
                explodeParticles.particleColor = BallColor.red
            case "ballYellow":
                explodeParticles.particleColor = BallColor.yellow
            default:
                explodeParticles.particleColor = BallColor.red
            }
            explodeParticles.position = ball.position
            addChild(explodeParticles)
        }
        
        ball.removeFromParent()
        isBallActive = false
        
        // Check if all boxes are removed from the scene - Game Over
        if let boxes = scene?.children.filter({ $0.name == "box" }) {
            if boxes.isEmpty {
                gameOver()
            }
        }
    }
    
    func gameOver() {
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "Chalkduster"
        gameOverLabel.fontColor = .white
        gameOverLabel.fontSize = 100
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.zPosition = 100
        gameOverLabel.xScale = 0.001
        gameOverLabel.yScale = 0.001
        
        let appear = SKAction.scale(to: 1, duration: 0.5)
        let nextAction = SKAction.run { [weak self] in
            self?.addNewGameLabel()
        }
        let wait = SKAction.wait(forDuration: 1.0)
        let disappear = SKAction.fadeAlpha(to: 0.0, duration: 2.0)
        
        addChild(gameOverLabel)
        gameOverLabel.run(SKAction.sequence([appear, nextAction, wait, disappear]))
    }
    
    func addNewGameLabel() {
   
        let newGameLabel = SKLabelNode(text: "New Game")
        newGameLabel.fontName = "Chalkduster"
        newGameLabel.fontColor = .black
        newGameLabel.fontSize = 40
        newGameLabel.position = CGPoint(x: 512, y: 800)
        newGameLabel.name = "newGame"
        addChild(newGameLabel)
    
        let labelBackground = SKShapeNode(rect: CGRect(x: -150, y: -15, width: 300, height: 60), cornerRadius: 20)
        labelBackground.fillColor = .green
        labelBackground.strokeColor = .green
        newGameLabel.addChild(labelBackground)
        
        let appear = SKAction.move(to: CGPoint(x: 512, y: 700), duration: 0.5)
        newGameLabel.run(appear)
    }
    
    func newGame() {
        score = 0
        generateBoxes()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard
            let nodeA = contact.bodyA.node,
            let nodeB = contact.bodyB.node,
            let nodeAName = nodeA.name,
            let nodeBName = nodeB.name
            else { return }
        
        // Removes physicsBody from the box to prevent multiple collision calls for the same box
        if nodeAName.contains("box") {
            nodeA.physicsBody = nil
        } else if nodeBName.contains("box") {
            nodeB.physicsBody = nil
        }

        if nodeAName.contains("ball") {
            collision(between: nodeA, object: nodeB)
        } else if nodeBName.contains("ball") {
            collision(between: nodeB, object: nodeA)
        }
    }
}
