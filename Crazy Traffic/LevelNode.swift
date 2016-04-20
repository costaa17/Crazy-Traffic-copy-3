//
//  Level.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/22/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit


class LevelNode: SKSpriteNode {
    let rows: Int
    let cols: Int
    let levelNum: Int
    let carGoal: Int
    let pedGoal: Int
    let backgroundColor: UIColor
    let hasTutorial: Bool
    let tutorialText: String
    let paths: [Path]
    
    var backgroundNode: SKSpriteNode! = nil
    var groundNode: SKSpriteNode! = nil
    var scoreNode: SKLabelNode! = nil
    var helpNode: SKSpriteNode! = nil
    
    var score: Int = 0 {
        didSet {
            self.scoreNode.text = "Cars: \(score) – Peds: \(self.pedScore)"
        }
    }
    
    var pedScore: Int = 0 {
        didSet {
            self.scoreNode.text = "Cars: \(self.score) – Peds: \(pedScore)"
        }
    }
    
    var nextCarID: Int = 1
    
    init(data: [String:AnyObject]) {
        self.rows = data["rows"] as! Int
        self.cols = data["cols"] as! Int
        self.levelNum = data["levelNum"] as! Int
        self.carGoal = data["carGoal"] as! Int
        self.pedGoal = data["pedGoal"] as! Int
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
    
    // MARK: - Setup code
    
    func setup() {
        if let scene = self.parent as? GameScene {
            scene.currentScreen = Screen.LevelIntro
            self.setupGroundNode()
            self.setupBackgroundNode()
            self.setupScoreNode()
            self.setupHelpNode()
            self.activatePhysics()
            self.transitionToPlayWithDelay(4.0)
        }
        
    }
    
    private func setupScoreNode() {
        self.scoreNode = SKLabelNode()
        self.scoreNode.fontName = FONT_NAME
        self.scoreNode.fontSize = FONT_SIZE_M
        self.score = 0
        self.scoreNode.position = CGPoint(x: CGRectGetMaxX(self.frame)-CGRectGetWidth(self.scoreNode.frame), y: CGRectGetMaxY(self.frame)-CGRectGetHeight(self.scoreNode.frame)-5)
        self.scoreNode.zPosition = 20
        self.addChild(self.scoreNode)
    }
    
    private func setupHelpNode(){
        if self.hasTutorial {
            self.helpNode = SKSpriteNode(texture: SKTexture(image: ImageManager.imageForHelpSymbol()))
            self.helpNode.position = CGPointMake(25, 25)
            self.helpNode.zPosition = 20
            self.helpNode.alpha = 0.0
            self.helpNode.name = "help"
            self.addChild(helpNode)
        }
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
        levelNumNode.name = "level_info"
        levelNumNode.fontName = FONT_NAME
        levelNumNode.fontSize = FONT_SIZE_XL
        levelNumNode.text = "Level \(self.levelNum)"
        levelNumNode.position = CGPoint(x: center.x, y: center.y + 40)
        self.backgroundNode.addChild(levelNumNode)
        
        let levelGoalNode = SKLabelNode()
        levelGoalNode.name = "level_info"
        levelGoalNode.fontName = FONT_NAME
        levelGoalNode.fontSize = FONT_SIZE_L
        levelGoalNode.text = "Goal:  \(self.carGoal) cars"
        if self.pedGoal > 0 {
            levelGoalNode.text = levelGoalNode.text! + " and \(self.pedGoal) pedestrians"
        }
        levelGoalNode.position = CGPoint(x: center.x, y: center.y)
        self.backgroundNode.addChild(levelGoalNode)
        
        var tutorialTextNode: SKLabelNode
        tutorialTextNode = SKLabelNode()
        tutorialTextNode.name = "level_info"
        tutorialTextNode.fontName = FONT_NAME
        tutorialTextNode.fontSize = FONT_SIZE_M
        tutorialTextNode.text = self.tutorialText
        tutorialTextNode.position = CGPoint(x: center.x, y: center.y - 30)
        self.backgroundNode.addChild(tutorialTextNode)
        
        // First pass add all paths that are not walking paths
        for path in self.paths {
            if path.type == Path.PathType.Walk {
                continue
            }
            let shapeNode = SKShapeNode(path: path.CGPath(self))
            shapeNode.name = "path"
            shapeNode.strokeColor = ROAD_COLOR
            shapeNode.lineWidth = calculatePathWidth()
            shapeNode.alpha = 0.0
            self.backgroundNode.addChild(shapeNode)
        }
        // Second pass add all walking paths and crosswalks
        for path in self.paths {
            if path.type != Path.PathType.Walk {
                continue
            }
            let shapeNode = SKShapeNode(path: path.CGPath(self))
            shapeNode.name = "path"
            shapeNode.strokeColor = WALK_COLOR
            shapeNode.lineWidth = 20
            shapeNode.alpha = 0.0
            self.backgroundNode.addChild(shapeNode)
            
            self.addCrossWalkToPath(path)
        }
    }
    
    private func addCrossWalkToPath(path: Path) {
        // Check if this walk path intersects with any roads
        for path2 in self.paths {
            if path2.type == Path.PathType.Road {
                let walkPath = UIBezierPath(CGPath: path.CGPath(self))
                let roadPath = CGPathCreateCopyByStrokingPath(path2.CGPath(self), nil, calculatePathWidth(), CGLineCap.Butt, CGLineJoin.Miter, 0.0)
                
                var startPoint: CGPoint!
                var endPoint: CGPoint!
                var prevPoint: CGPoint!
                
                // Check for intersections every 1 percent
                for p in 0.0.stride(through: 1.0, by: 0.01) {
                    let point = walkPath.pointAtPercentOfLength(CGFloat(p))
                    
                    if CGPathContainsPoint(roadPath, nil, point, true) {
                        // The road path contains this point from the walk path
                        if startPoint == nil {
                            startPoint = point
                        }
                    } else {
                        if startPoint != nil && endPoint == nil {
                            endPoint = prevPoint
                        }
                    }
                    
                    prevPoint = point
                }
                
                if startPoint != nil && endPoint != nil {
                    let crossWalk = UIBezierPath()
                    crossWalk.moveToPoint(startPoint)
                    crossWalk.addLineToPoint(endPoint)
                    
                    let pattern: [CGFloat] = [7.0, 7.0]
                    let dashed = CGPathCreateCopyByDashingPath(crossWalk.CGPath, nil, 0, pattern, 2)
                    let shapeNode = SKShapeNode(path: dashed!)
                    shapeNode.name = "path"
                    shapeNode.strokeColor = ROAD_COLOR
                    shapeNode.lineWidth = 30
                    shapeNode.alpha = 0.0
                    self.backgroundNode.addChild(shapeNode)
                    
                }
            }
        }
    }
    
    func activatePhysics() {
        // Borders
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = CollisionTypeLevelBorder
        self.physicsBody?.contactTestBitMask = CollisionTypeCar
        self.physicsBody?.collisionBitMask = CollisionTypeNone
        self.physicsBody?.usesPreciseCollisionDetection = true
        
        // Ground physics to stop the falling background
        self.groundNode.physicsBody = SKPhysicsBody(rectangleOfSize: self.groundNode.size, center: CGPoint(x: self.groundNode.size.width/2, y: self.groundNode.size.height/2))
        self.groundNode.physicsBody?.categoryBitMask = CollisionTypeLevelGround
        self.groundNode.physicsBody?.collisionBitMask = CollisionTypeLevelBackground
        self.groundNode.physicsBody?.dynamic = false
        
        // The background is where all of the paths are stored. It starts above the screen and will start to fall when the physics are activated, stopping at the ground.
        self.backgroundNode.physicsBody = SKPhysicsBody(rectangleOfSize: self.backgroundNode.size, center: CGPoint(x: self.backgroundNode.size.width/2, y: self.backgroundNode.size.height/2))
        self.backgroundNode.physicsBody?.categoryBitMask = CollisionTypeLevelBackground
        self.backgroundNode.physicsBody?.collisionBitMask = CollisionTypeLevelGround
        self.backgroundNode.physicsBody?.allowsRotation = false
        self.backgroundNode.physicsBody?.restitution = 0.5
    }
    
    // MARK: - Show level
    
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
        // Remove any existing transition
        self.removeActionForKey("intro_transition")
        
        // Transition to play immediately
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
                // Fade in paths
                self.backgroundNode.enumerateChildNodesWithName("path", usingBlock: { node, stop in
                    node.runAction(SKAction.fadeInWithDuration(duration))
                })
                // Fade in car nodes
                self.enumerateChildNodesWithName("car") { node, stop in
                    node.runAction(SKAction.fadeInWithDuration(duration))
                }
                // Fade in help node
                self.childNodeWithName("help")?.runAction(SKAction.fadeInWithDuration(duration))
            },
            SKAction.runBlock { () -> Void in
                self.backgroundNode.enumerateChildNodesWithName("level_info", usingBlock: { node, stop in
                    node.runAction(SKAction.fadeOutWithDuration(duration))
                })
            }])
        return transition
    }
    
    private func finishedTransitionToPlay() {
        // Level intro has either finished delay or the user tapped the screen
        self.backgroundNode.physicsBody?.restitution = 0
        self.backgroundNode.physicsBody?.dynamic = false
        self.backgroundNode.position = CGPointZero
        
        self.startSpawningCars()
    }
    
    private func startSpawningCars() {
        if let scene = self.parent as? GameScene {
            scene.currentScreen = Screen.LevelPlay
            
            if DEBUG_MODE {
                let pathIndex = 0
                let wait = SKAction.waitForDuration(2)
                let spawn = SKAction.runBlock {
                    let _ = Car(level: self, pathIndex: pathIndex)
                }
                let sequence = SKAction.sequence([wait, spawn])
                self.runAction(SKAction.repeatActionForever(sequence))
            } else {
                for i in 0 ..< self.paths.count {
                    let wait = SKAction.waitForDuration(5, withRange: 5)
                    let spawn = SKAction.runBlock {
                        if self.paths[i].type == Path.PathType.Road {
                            let _ = Car(level: self, pathIndex: i)
                        } else if self.paths[i].type == Path.PathType.Walk {
                            let _ = Person(level: self, pathIndex: i)
                        }
                        self.nextCarID += 1
                    }
                    let sequence = SKAction.sequence([wait, spawn])
                    self.runAction(SKAction.repeatActionForever(sequence))
                }
            }
        }
    }
    
    // MARK: - Help
    
    func showHelpScreen(){
        if let scene = self.parent as? GameScene {
            // Hide paths and cars
            self.backgroundNode.enumerateChildNodesWithName("path") { node, stop in
                node.alpha = 0
            }
            self.enumerateChildNodesWithName("path_follower") { node, stop in
                node.alpha = 0
            }
            // Show level help
            self.backgroundNode.enumerateChildNodesWithName("level_info") { node, stop in
                node.alpha = 1
            }
            
            scene.paused = true
            scene.currentScreen = Screen.Help
        }
    }
    
    func hideHelpScreen() {
        if let scene = self.parent as? GameScene {
            // Hide paths and cars
            self.backgroundNode.enumerateChildNodesWithName("path") { node, stop in
                node.alpha = 1
            }
            self.enumerateChildNodesWithName("path_follower") { node, stop in
                node.alpha = 1
            }
            // Hide level help
            self.backgroundNode.enumerateChildNodesWithName("level_info") { node, stop in
                node.alpha = 0
            }
            
            scene.paused = false
            scene.currentScreen = Screen.LevelPlay
        }
    }
    
    // MARK: -
    
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
        self.enumerateChildNodesWithName("path_follower") { node, stop in
            let pathFollower = node as! PathFollower
            pathFollower.update(timeSinceLastUpdate)
        }
    }
}