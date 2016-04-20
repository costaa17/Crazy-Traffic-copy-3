//
//  PathFollower.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 4/18/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit


class PathFollower: SKSpriteNode {
    // A unique id -- objects with lower ids were added earlier (and therefore are ahead)
    // of objects with higher ids
    let id: Int
    
    // The index of the path I'm on -- this is used to make sure I can't collide with
    // other sprites on my path
    let pathIndex: Int
    // Cache the UIBezierPath version of the path I'm on -- paths are stored in levels as
    // Path objects, which generate CGPaths from an array of vertices
    let bezierPath: UIBezierPath
    // Cache the length of the path I'm on
    let pathLength: CGFloat
    
    // My default speed
    let mySpeed: CGFloat
    // My current speed, which can be faster or slower than my default speed, if the
    // player swipes or taps me
    var currentSpeed: CGFloat = 0
    // Current position along path -- some fraction of path.length
    var positionAlongPath: CGFloat = 0
    
    // Used to keep track of how many times a car hits the border around the screen.
    // It will hit once when it enters and hit a second time when it leaves, which
    // is when we want to remove the car
    var edgeHitCount: Int = 0
    
    // Reference to level in which this car exists -- used to check for other cars on the path
    weak var level: LevelNode!

    init(level: LevelNode, pathIndex: Int, speed: CGFloat, image: UIImage, physicsPath: UIBezierPath, categoryBitMask: UInt32, contactTestBitMask: UInt32) {
        self.id = level.nextCarID
        
        self.pathIndex = pathIndex
        let cgPath = level.paths[pathIndex].CGPath(level)
        self.bezierPath = UIBezierPath(CGPath: cgPath)
        self.pathLength = self.bezierPath.length()
        
        // Set speed
        self.mySpeed = speed
        self.currentSpeed = self.mySpeed
        
        // Set sprite and physics body
        super.init(texture: SKTexture(image: image), color: UIColor.blackColor(), size: image.size)
        
        self.name = "path_follower"
        self.zPosition = 21
        
        self.physicsBody = SKPhysicsBody(polygonFromPath: physicsPath.CGPath)
        self.physicsBody?.categoryBitMask = categoryBitMask
        self.physicsBody?.collisionBitMask = CollisionTypeNone
        self.physicsBody?.contactTestBitMask = contactTestBitMask
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.usesPreciseCollisionDetection = true
        
        // Add to level
        self.level = level
        self.level.addChild(self)
        
        // Set initial position/rotation
        self.updateLocation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLocation() {
        let percent = self.positionAlongPath / self.pathLength
        var slope: CGFloat = 0
        self.position = self.bezierPath.pointAtPercentOfLength(percent, tangent: &slope)
        self.zRotation = slope
    }
    
    func update(time: CFTimeInterval) {
        let posDelta = self.currentSpeed * CGFloat(time)
        self.positionAlongPath += posDelta
        self.updateLocation()
    }
    
    func speedUp() {
        self.currentSpeed = self.mySpeed * FAST_CAR_MULT
        self.goBackToNormalSpeedAfterDelay(2.0)
    }
    
    func slowDown() {
        self.currentSpeed = self.mySpeed * SLOW_CAR_MULT
        self.goBackToNormalSpeedAfterDelay(2.0)
    }
    
    func goBackToNormalSpeedAfterDelay(delay: NSTimeInterval) {
        let wait = SKAction.waitForDuration(delay)
        let normalSpeed = SKAction.runBlock({
            self.currentSpeed = self.mySpeed
        })
        let sequence = SKAction.sequence([wait, normalSpeed])
        self.runAction(sequence)
    }
}