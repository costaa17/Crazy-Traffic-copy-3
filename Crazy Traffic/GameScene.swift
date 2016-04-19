//
//  GameScene.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/3/16.
//  Copyright (c) 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit

enum Screen {
    case LevelSelect
    case LevelIntro
    case LevelPlay
    case GameOver
    case Help
}

let CollisionTypeNone: UInt32            = 1
let CollisionTypeLevelGround: UInt32     = 2
let CollisionTypeLevelBackground: UInt32 = 4
let CollisionTypeLevelBorder: UInt32     = 8
let CollisionTypeCar: UInt32             = 16
let CollisionTypePerson: UInt32          = 32

class GameScene: SKScene, SKPhysicsContactDelegate {
    var currentScreen: Screen = .LevelSelect
    var levelNode: LevelNode!
    var gameOverNode: GameOverNode!
    
    var touchedNode: SKNode!
    
    var lastUpdateTime: CFTimeInterval = 0.0
    
    // MARK: - Move to view
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        self.view!.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(GameScene.handlePanFrom(_:))))
        
        self.backgroundColor = LEVEL_SELECT_COLOR
        
        self.gameOverNode = GameOverNode()
        self.addChild(self.gameOverNode)
        
        // Generate images for level selection
        let numberOfLevels = 4
        for i in 0 ..< numberOfLevels {
            if let levelNode = self.childNodeWithName("level-\(i+1)") as? SKSpriteNode {
                if i % 2 == 0 {
                    levelNode.texture = SKTexture(image: ImageManager.imageForLevel(i+1, fillColor: UIColor.whiteColor(), strokeColor: UIColor.blackColor()))
                } else {
                    levelNode.texture = SKTexture(image: ImageManager.imageForLevel(i+1, fillColor: UIColor.blackColor(), strokeColor: UIColor.whiteColor()))
                }
            }
        }
    }
    
    // MARK: - Contact
    
    private func getOrderedBodies(contact: SKPhysicsContact) -> (firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
        var firstBody: SKPhysicsBody!
        var secondBody: SKPhysicsBody!
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        return (firstBody, secondBody)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let bodies = getOrderedBodies(contact)
        
        if bodies.firstBody.categoryBitMask == CollisionTypeCar && bodies.secondBody.categoryBitMask == CollisionTypeCar {
            // Car hit a car
            let car1 = bodies.firstBody.node as! Car
            let car2 = bodies.secondBody.node as! Car
            
            if car1.pathIndex != car2.pathIndex {
                print("first: \(car1.id), second: \(car2.id)")
                self.gameOverNode.show(car1.id, id2: car2.id)
            }
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        let bodies = getOrderedBodies(contact)
        
        if bodies.firstBody.categoryBitMask == CollisionTypeLevelBorder && bodies.secondBody.categoryBitMask == CollisionTypeCar {
            // Car hit the edge of the level
            let car = bodies.secondBody.node as! Car
            car.edgeHitCount += 1
            if car.edgeHitCount > 1 {
                self.levelNode.score += 1
                car.removeFromParent()
            }
        }
    }
    
    // MARK: - Touches
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.currentScreen == .LevelSelect {
            // Check if tap on level
            for touch in touches {
                let location = touch.locationInNode(self)
                if let nodeName = self.nodeAtPoint(location).name {
                    let levelNum: Int = Int(nodeName.componentsSeparatedByString("-")[1])!
                    if let level = LevelManager.loadLevel(levelNum) {
                        self.levelNode = level
                        self.addChild(level)
                        level.setup()
                    }
                }
            }
        } else if self.currentScreen == .LevelIntro {
            // Tap on the intro screen immediately goes to play screen
            self.levelNode.transitionToPlay()
        } else if self.currentScreen == .LevelPlay {
            self.touchedNode = nil
            if let initialTouchLocation = touches.first?.locationInNode(self) {
                let node = self.nodeAtPoint(initialTouchLocation)
                if node.name == "path_follower" {
                    self.touchedNode = node
                } else if node.name == "help" {
                    self.levelNode.showHelpScreen()
                }
            }
        } else if self.currentScreen == .Help {
            self.levelNode.hideHelpScreen()
        } else if self.currentScreen == .GameOver {
            // Go back to the level select screen
            self.levelNode.removeFromParent()
            self.levelNode = nil
            self.gameOverNode.hide()
        }
    }
        
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.currentScreen == .LevelPlay {
            if let car = self.touchedNode as? Car {
                car.slowDown()
            }
        }
    }
    
    // MARK: - Swipe handling
    
    func handlePanFrom(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            NSObject.cancelPreviousPerformRequestsWithTarget(self)
            break
        case .Changed:
            break
        case .Ended:
            if let car = self.touchedNode as? Car {
                let spriteAngle = self.getSpriteAngle(car)
                let panAngle = self.getPanAngle(gesture)
                if self.isAngleWithinRangeOfAngle(panAngle, spriteAngle: spriteAngle, delta: 30.0) {
                    // Speed up
                    car.speedUp()
                }
                
                let oppAngle = self.getOppositeAngle(spriteAngle)
                
                if self.isAngleWithinRangeOfAngle(panAngle, spriteAngle: oppAngle, delta: 30.0) {
                    // Slow down
                    car.slowDown()
                }
            }
        default:
            break
        }
    }
    
    private func getOppositeAngle(angle: CGFloat) -> CGFloat {
        var oppAngle = angle + 180
        if oppAngle > 359 {
            oppAngle -= 360
        }
        return oppAngle
    }
    
    private func getPanAngle(gesture: UIPanGestureRecognizer) -> CGFloat {
        let velocity = gesture.velocityInView(gesture.view?.superview)
        var panAngle = radToDeg(atan2(velocity.y, velocity.x))
        
        // Rotate cc 90
        panAngle = 270.0 - panAngle
        
        // Make right side negative to match SpriteKit
        if panAngle >= 180 {
            panAngle = panAngle - 360
        }
        
        // Angle goes from 0-359
        if panAngle < 0 {
            panAngle += 360
        }
        
        return panAngle
    }
    
    private func getSpriteAngle(sprite: SKSpriteNode) -> CGFloat {
        // Convert from SpriteKit to 0-359
        var spriteAngle = radToDeg(sprite.zRotation)
        if spriteAngle < 0 {
            spriteAngle += 360
        }
        return spriteAngle
    }
    
    private func isAngleWithinRangeOfAngle(panAngle: CGFloat, spriteAngle: CGFloat, delta: CGFloat) -> Bool {
        var min = spriteAngle - delta
        if min < 0 {
            min += 360
        }
        
        var max = spriteAngle + delta
        if max > 359 {
            max -= 360
        }
        
        var inSameDirection = false
        if min < max {
            inSameDirection = panAngle > min && panAngle < max
        } else {
            // Min overflowed to bigger numbers. For example, if angle is 10,
            // max is 40 and min is 340.
            inSameDirection = panAngle < max || panAngle > min
        }
        return inSameDirection
    }
    
    private func radToDeg(radians: CGFloat) -> CGFloat {
        return radians * CGFloat((180.0 / M_PI))
    }
    
    // MARK: - Update function
    
    override func update(currentTime: CFTimeInterval) {
        if self.currentScreen == .LevelPlay {
            var timeSinceLastUpdate = currentTime - self.lastUpdateTime
            self.lastUpdateTime = currentTime
            if timeSinceLastUpdate > 1 {
                timeSinceLastUpdate = 1.0 / 60.0
                self.lastUpdateTime = currentTime
            }
            
            levelNode.update(timeSinceLastUpdate)
            
        }
    }
}
