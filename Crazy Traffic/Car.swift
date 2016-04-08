//
//  Car.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/23/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit


enum CarStatus {
    case Normal
    case Speeding
    case Stopped
}

class Car: SKSpriteNode {
    let id: Int
    
    // Used to keep track of how many times a car hits the border around the screen.
    // It will hit once when it enters and hit a second time when it leaves, which
    // is when we want to remove the car
    var edgeHitCount: Int = 0
    
    
    let pathIndex: Int
    let pathLength: CGFloat
    let bezierPath: UIBezierPath
    
    // Reference to level in which this car exists. Used to check for other cars on the path
    weak var level: Level!
    
    let mySpeed: CGFloat
    var currentSpeed: CGFloat = 0
    var pos: CGFloat = 0
    
    
    init(level: Level, pathIndex: Int) {
        // Assign a unique id. Cars that have a lower id (added earlier) are in front of cars
        // that have a higher id (added later).
        self.id = level.nextCarID
        level.nextCarID += 1
        
        self.level = level
        self.pathIndex = pathIndex
        let cgPath = level.paths[pathIndex].CGPath(level)
        self.bezierPath = UIBezierPath(CGPath: cgPath)
        self.pathLength = self.bezierPath.length()
        
        
        if VARIABLE_CAR_SPEED {
            switch Useful.random(min: 1, max: 5) {
            case 1:
                self.mySpeed = CAR_1_SPEED
            case 2:
                self.mySpeed = CAR_2_SPEED
            case 3:
                self.mySpeed = CAR_3_SPEED
            case 4:
                self.mySpeed = CAR_4_SPEED
            case 5:
                self.mySpeed = CAR_5_SPEED
            default:
                self.mySpeed = CAR_SPEED
            }
        } else {
            self.mySpeed = CAR_SPEED
        }
        self.currentSpeed = CAR_SPEED
        
        let carImage = ImageManager.imageForCar()
        let texture = SKTexture(image: carImage)
        super.init(texture: texture, color: UIColor.blackColor(), size: carImage.size)
        
        self.name = "car"
        self.zPosition = 21
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.categoryBitMask = CollisionTypes.Car.rawValue
        self.physicsBody?.collisionBitMask = CollisionTypes.None.rawValue
        self.physicsBody?.contactTestBitMask = CollisionTypes.LevelBorder.rawValue | CollisionTypes.Car.rawValue
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addToLevel(level)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addToLevel(level: Level) {
        level.addChild(self)
        self.updateLocation()
    }
    
    func update(time: CFTimeInterval) {
        self.level.enumerateChildNodesWithName("car") { node, stop in
            let car = node as! Car
            
            if car.pathIndex == self.pathIndex {
                if car.id < self.id {
                    // car is in front of me
                    if abs(car.pos - self.pos) < (max(self.size.width, self.size.height) + 10) {
                        // Check if car in front is stopped
                        if car.currentSpeed == 0 {
                            // It's stopped, so we should stop for a while
                            self.currentSpeed = 0
                            
                            // Go back to normal speed in a second
                            self.goBackToNormalSpeedAfterDelay(2.0)
                        } else {
                            // TODO: This could probably be made better.
                            
                            // The car in front is not stopped, so we should just slow down
                            self.currentSpeed = car.currentSpeed - 10
                            
                            // Go back to normal speed
                            self.goBackToNormalSpeedAfterDelay(2.0)
                        }
                    }
                }
            }
        }
        
        let posDelta = self.currentSpeed * CGFloat(time)
        self.pos += posDelta
        self.updateLocation()
    }
    
    private func updateLocation() {
        let percent = self.pos / self.pathLength
        var slope: CGFloat = 0
        self.position = self.bezierPath.pointAtPercentOfLength(percent, tangent: &slope)
        self.zRotation = slope
    }
    
    func speedUp() {
        self.currentSpeed = self.mySpeed * FAST_CAR_MULT
        self.goBackToNormalSpeedAfterDelay(2.0)
    }
    
    func slowDown() {
        self.currentSpeed = self.mySpeed * SLOW_CAR_MULT
        self.goBackToNormalSpeedAfterDelay(2.0)
    }
    
    private func goBackToNormalSpeedAfterDelay(delay: NSTimeInterval) {
        let wait = SKAction.waitForDuration(delay)
        let normalSpeed = SKAction.runBlock({
            self.currentSpeed = self.mySpeed
        })
        let sequence = SKAction.sequence([wait, normalSpeed])
        self.runAction(sequence)
    }
}