//
//  Level.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/22/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit


class Level: SKSpriteNode {
    let rows: Int
    let cols: Int
    let levelNum: Int
    let levelGoal: Int
    let backgroundColor: UIColor
    let hasTutorial: Bool
    let tutorialText: String
    let paths: [Path]
    
    var backgroundNode: SKSpriteNode! = nil
    var groundNode: SKSpriteNode! = nil
    var scoreNode: SKLabelNode! = nil
    
    var score: Int = 0
    
    var nextCarID: Int = 1
    
    init(data: [String:AnyObject]) {
        self.rows = data["rows"] as! Int
        self.cols = data["cols"] as! Int
        self.levelNum = data["levelNum"] as! Int
        self.levelGoal = data["levelGoal"] as! Int
        self.backgroundColor = UIColor(hex: data["backgroundColor"] as! String)
        self.hasTutorial = data["hasTutorial"] as! Bool
        self.tutorialText = data["tutorialText"] as! String
        self.paths = data["paths"] as! [Path]
        
        // Outset screen size slightly to prevent seeing what's underneath
        let bounds = CGRectInset(UIScreen.mainScreen().bounds, -1, -1)
        super.init(texture: nil, color: UIColor.clearColor(), size: bounds.size)
        self.anchorPoint = CGPointZero
        self.position = CGPoint(x: -1, y: -1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Swift requires this initializer to exist
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        if let scene = self.parent as? GameScene {
            scene.currentScreen = Screen.LevelIntro
            self.setupGroundNode()
            self.setupBackgroundNode()
            self.setupScoreNode()
            self.activatePhysics()
            self.transitionToPlayWithDelay(4.0)
        }
        
    }
    
    private func setupScoreNode() {
        self.scoreNode = SKLabelNode(text: "Score: 9999")
        self.scoreNode.fontName = FONT_NAME
        self.scoreNode.fontSize = FONT_SIZE_M
        self.scoreNode.horizontalAlignmentMode = .Right
        self.updateScore()
        self.scoreNode.position = CGPoint(x: CGRectGetMaxX(self.frame)-CGRectGetWidth(self.scoreNode.frame), y: CGRectGetMaxY(self.frame)-CGRectGetHeight(self.scoreNode.frame)-5)
        self.scoreNode.zPosition = 20
        self.addChild(self.scoreNode)
    }
    
    private func setupGroundNode() {
        let groundSize = CGSize(width: self.size.width, height: 1)
        self.groundNode = SKSpriteNode(color: UIColor.blackColor(), size: groundSize)
        self.addChild(self.groundNode)
        self.groundNode.anchorPoint = CGPoint(x: 0, y: 0)
        self.groundNode.position = CGPoint(x: 0, y: 0) // Position just under the screen
    }
    
    private func setupBackgroundNode() {
        self.backgroundNode = SKSpriteNode(color: self.backgroundColor, size: self.size)
        self.addChild(self.backgroundNode)
        self.backgroundNode.zPosition = 10
        self.backgroundNode.anchorPoint = CGPoint(x: 0, y: 0)
        self.backgroundNode.position = CGPoint(x: 0, y: size.height) // Position just above the screen
        
        let center = CGPoint(x: self.backgroundNode.size.width/2, y: self.backgroundNode.size.height/2)
        
        let levelNumNode = SKLabelNode()
        levelNumNode.name = "levelNum"
        levelNumNode.fontName = FONT_NAME
        levelNumNode.fontSize = FONT_SIZE_XL
        levelNumNode.text = "Level \(self.levelNum)"
        levelNumNode.position = CGPoint(x: center.x, y: center.y + 40)
        self.backgroundNode.addChild(levelNumNode)
        
        let levelGoalNode = SKLabelNode()
        levelGoalNode.name = "levelGoal"
        levelGoalNode.fontName = FONT_NAME
        levelGoalNode.fontSize = FONT_SIZE_L
        levelGoalNode.text = "Required points: \(self.levelGoal)"
        levelGoalNode.position = CGPoint(x: center.x, y: center.y)
        self.backgroundNode.addChild(levelGoalNode)
        
        var tutorialTextNode: SKLabelNode
        tutorialTextNode = SKLabelNode()
        tutorialTextNode.name = "tutorial"
        tutorialTextNode.fontName = FONT_NAME
        tutorialTextNode.fontSize = FONT_SIZE_M
        tutorialTextNode.text = self.tutorialText
        tutorialTextNode.position = CGPoint(x: center.x, y: center.y - 30)
        self.backgroundNode.addChild(tutorialTextNode)
        
        for path in self.paths {
            let shapeNode = SKShapeNode(path: path.CGPath(self))
            shapeNode.name = "path"
            shapeNode.strokeColor = ROAD_COLOR
            shapeNode.lineWidth = calculatePathWidth()
            shapeNode.alpha = 0.0
            self.backgroundNode.addChild(shapeNode)
        }
    }
    
    func activatePhysics() {
        // Borders
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = CollisionTypes.LevelBorder.rawValue
        self.physicsBody?.contactTestBitMask = CollisionTypes.Car.rawValue
        self.physicsBody?.collisionBitMask = CollisionTypes.None.rawValue
        self.physicsBody?.usesPreciseCollisionDetection = true
        
        // Ground physics to stop the falling background
        self.groundNode.physicsBody = SKPhysicsBody(rectangleOfSize: self.groundNode.size, center: CGPoint(x: self.groundNode.size.width/2, y: self.groundNode.size.height/2))
        self.groundNode.physicsBody?.categoryBitMask = CollisionTypes.LevelGround.rawValue
        self.groundNode.physicsBody?.collisionBitMask = CollisionTypes.LevelBackground.rawValue
        self.groundNode.physicsBody?.dynamic = false
        
        // The background is where all of the paths are stored. It starts above the screen and will start to fall when the physics are activated, stopping at the ground.
        self.backgroundNode.physicsBody = SKPhysicsBody(rectangleOfSize: self.backgroundNode.size, center: CGPoint(x: self.backgroundNode.size.width/2, y: self.backgroundNode.size.height/2))
        self.backgroundNode.physicsBody?.categoryBitMask = CollisionTypes.LevelBackground.rawValue
        self.backgroundNode.physicsBody?.collisionBitMask = CollisionTypes.LevelGround.rawValue
        self.backgroundNode.physicsBody?.allowsRotation = false
        self.backgroundNode.physicsBody?.restitution = 0.5
    }
    
    func transitionToPlayWithDelay(delay: NSTimeInterval) {
        let wait = SKAction.waitForDuration(delay)
        
        let transition = getTransitionToPlayActionWithDuration(1.0)
        
        let finished = SKAction.runBlock { () -> Void in
            self.finishedTransitionToPlay()
        }
        
        let sequence = SKAction.sequence([wait, transition, finished])
        self.runAction(sequence, withKey: "intro_transition")
    }
    
    func transitionToPlay() {
        let transition = getTransitionToPlayActionWithDuration(0.0)
        
        let finished = SKAction.runBlock { () -> Void in
            self.finishedTransitionToPlay()
        }
        
        let sequence = SKAction.sequence([transition, finished])
        self.runAction(sequence, withKey: "intro_transition")
    }
    
    private func getTransitionToPlayActionWithDuration(duration: NSTimeInterval) -> SKAction {
        let transition = SKAction.group([
            SKAction.runBlock { () -> Void in
                self.backgroundNode.enumerateChildNodesWithName("path", usingBlock: {
                    node, stop in
                    node.runAction(SKAction.fadeInWithDuration(duration))
                })},
            SKAction.runBlock { () -> Void in
                self.backgroundNode.childNodeWithName("levelNum")?.runAction(SKAction.fadeOutWithDuration(duration))
                self.backgroundNode.childNodeWithName("levelGoal")?.runAction(SKAction.fadeOutWithDuration(duration))
                self.backgroundNode.childNodeWithName("tutorial")?.runAction(SKAction.fadeOutWithDuration(duration))
            }])
        return transition
    }
    
    private func finishedTransitionToPlay() {
        // Level intro has either finished delay or the user tapped the screen
        
        self.physicsBody?.dynamic = false
        self.backgroundNode.position = CGPointZero
        
        if let scene = self.parent as? GameScene {
            scene.currentScreen = Screen.LevelPlay
            
            if DEBUG_MODE {
                // Test car collisions
                let pathIndex = 0
                let wait = SKAction.waitForDuration(2)
                let spawn = SKAction.runBlock {
                    let _ = Car(level: self, pathIndex: pathIndex)
                }
                let sequence = SKAction.sequence([wait, spawn])
                self.runAction(SKAction.repeatActionForever(sequence))
            } else {
                for i in 0 ..< self.paths.count {
                    let wait = SKAction.waitForDuration(10, withRange: 10)
                    let spawn = SKAction.runBlock {
                        let _ = Car(level: self, pathIndex: i)
                    }
                    let sequence = SKAction.sequence([wait, spawn])
                    self.runAction(SKAction.repeatActionForever(sequence))
                }
            }
        }
    }
    
    
    func updateScore() {
        self.scoreNode.text = "Score: \(self.score)"
    }
    
    
    // Convert a vertex to a point in this level -- depends on the screen size
    // and the number of rows and cols from this level
    func pointForVertex(vertex: PathVertex) -> CGPoint {
        let tileWidth = self.size.width / CGFloat(self.cols)
        let tileHeight = self.size.height / CGFloat(self.rows)
        return CGPoint(x: CGFloat(vertex.row) * tileWidth, y: CGFloat(vertex.col) * tileHeight)
    }
    
    func calculatePathWidth() -> CGFloat {
        let tileWidth = self.size.width / CGFloat(self.cols)
        let tileHeight = self.size.height / CGFloat(self.rows)
        return 2 * max(tileWidth, tileHeight) + 1
    }
    
    func update(timeSinceLastUpdate: CFTimeInterval) {
        self.enumerateChildNodesWithName("car") {
            node, stop in
            let car = node as! Car
            car.update(timeSinceLastUpdate)
        }
    }
}