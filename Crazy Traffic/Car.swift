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
    let myColor: UIColor
    
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
        
        
        // Randomly assign a speed and corresponding color
        switch Int(arc4random_uniform(UInt32(5)) + 1) /* 1-5 */ {
        case 1:
            self.mySpeed = CAR_1_SPEED
            self.myColor = CAR_1_COLOR
        case 2:
            self.mySpeed = CAR_2_SPEED
            self.myColor = CAR_2_COLOR
        case 3:
            self.mySpeed = CAR_3_SPEED
            self.myColor = CAR_3_COLOR
        case 4:
            self.mySpeed = CAR_4_SPEED
            self.myColor = CAR_4_COLOR
        case 5:
            self.mySpeed = CAR_5_SPEED
            self.myColor = CAR_5_COLOR
        default:
            self.mySpeed = 50
            self.myColor = UIColor.whiteColor()
        }
        self.currentSpeed = self.mySpeed
        
        let carImage = ImageManager.imageForCar(self.myColor, id: self.id)
        let texture = SKTexture(image: carImage)
        super.init(texture: texture, color: UIColor.blackColor(), size: carImage.size)
        
        self.name = "car"
        self.zPosition = 21
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 44.0, height: 44.0))
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
                    if abs(car.pos - self.pos) < 60 {
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
            self.resetMyColor()
        })
        let sequence = SKAction.sequence([wait, normalSpeed])
        self.runAction(sequence)
    }
    
    func highlight() {
        let carImage = ImageManager.imageForCar(HIGHLIGHT_COLOR, id: self.id)
        self.texture = SKTexture(image: carImage)
    }
    
    private func resetMyColor() {
        let carImage = ImageManager.imageForCar(self.myColor, id: self.id)
        self.texture = SKTexture(image: carImage)
    }
    
}