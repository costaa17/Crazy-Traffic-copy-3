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
}

enum CollisionTypes: UInt32 {
    case None = 1
    case LevelGround = 2
    case LevelBackground = 4
    case LevelBorder = 8
    case Car = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var currentScreen: Screen = .LevelSelect
    var levelScreen: Level!
    var gameOverScreen: GameOver!
    
    var touchedNode: SKNode!
    
    var lastUpdateTime: CFTimeInterval = 0.0
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        self.view!.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(GameScene.handlePanFrom(_:))))
        
        self.backgroundColor = LEVEL_SELECT_COLOR
        
        self.gameOverScreen = GameOver()
        self.addChild(self.gameOverScreen)
        
        // Generate images for level selection
        let levelColors = [UIColor.salmonColor(), UIColor.pastelBlueColor(), UIColor.tomatoColor(), UIColor.skyBlueColor()]
        for i in 0 ..< levelColors.count {
            if let levelNode = self.childNodeWithName("level-\(i+1)") as? SKSpriteNode {
                levelNode.texture = SKTexture(image: ImageManager.imageForLevel(i+1, fillColor: levelColors[i], strokeColor: UIColor.ivoryColor()));
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody!
        var secondBody: SKPhysicsBody!
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == CollisionTypes.LevelBorder.rawValue && secondBody.categoryBitMask == CollisionTypes.Car.rawValue {
            // Car hit the edge of the level
            let car = secondBody.node as! Car
            car.edgeHitCount += 1
            if car.edgeHitCount > 1 {
                self.levelScreen.score += 1
                self.levelScreen.updateScore()
                car.removeFromParent()
            }
        } else if firstBody.categoryBitMask == CollisionTypes.Car.rawValue && secondBody.categoryBitMask == CollisionTypes.Car.rawValue {
            // Car hit a car
            let car1 = firstBody.node as! Car
            let car2 = secondBody.node as! Car
            
            if car1.pathIndex != car2.pathIndex {
                print("first: \(car1.id), second: \(car2.id)")
                self.gameOverScreen.show(car1.id, id2: car2.id)
            }
        }
    }
    
    func setBackgroundImage() {
        let backgroundImage = ImageManager.backgroundImageForSize(self.size)
        let backgroundTexture = SKTexture(image: backgroundImage)
        let backgroundTiles = SKSpriteNode(texture: backgroundTexture)
        backgroundTiles.yScale = -1 //upon closer inspection, I noticed my source tile was flipped vertically, so this just flipped it back.
        backgroundTiles.position = CGPointMake(self.size.width/2, self.size.height/2)
        backgroundTiles.zPosition = -1
        self.addChild(backgroundTiles)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.currentScreen == .LevelSelect {
            // Check if tap on level
            for touch in touches {
                let location = touch.locationInNode(self)
                if let nodeName = self.nodeAtPoint(location).name {
                    let levelNum: Int = Int(nodeName.componentsSeparatedByString("-")[1])!
                    if let level = LevelManager.loadLevel(levelNum) {
                        self.levelScreen = level
                        self.addChild(level)
                        level.setup()
                    }
                }
            }
        } else if self.currentScreen == .LevelIntro {
            // Tap on the intro screen immediately goes to play screen
            self.levelScreen.removeActionForKey("intro_transition")
            self.levelScreen.transitionToPlay()
        } else if self.currentScreen == .LevelPlay {
            self.touchedNode = nil
            if let initialTouchLocation = touches.first?.locationInNode(self) {
                self.touchedNode = self.nodeAtPoint(initialTouchLocation)
               
            }
        } else if self.currentScreen == .GameOver {
            // Go back to the level select screen
            self.levelScreen.removeFromParent()
            self.levelScreen = nil
            
            self.gameOverScreen.hide()
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
                car.highlight()
                
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
            self.levelScreen.update(timeSinceLastUpdate)
   
            
        }
    }
}