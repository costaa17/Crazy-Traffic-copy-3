//
//  PathFollower.swift
//  Crazy Traffic
//
//  Created by Ana Vitoria do Valle Costa on 4/18/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//


import SpriteKit


class PathFollower: SKSpriteNode {
    let id: Int
    
    // Used to keep track of how many times a car hits the border around the screen.
    // It will hit once when it enters and hit a second time when it leaves, which
    // is when we want to remove the car
    var edgeHitCount: Int = 0
    
    let pathIndex: Int
    let pathLength: CGFloat
    let bezierPath: UIBezierPath
    
    // Reference to level in which this car exists. Used to check for other cars on the path
    weak var level: LevelNode!
    
    let mySpeed: CGFloat
    var currentSpeed: CGFloat = 0
    var pos: CGFloat = 0
    init(level: LevelNode, pathIndex: Int, texture: SKTexture, color: UIColor, size: CGSize, speed: CGFloat) {
        // Assign a unique id. Cars that have a lower id (added earlier) are in front of cars
        // that have a higher id (added later).
        self.id = level.nextCarID
        level.nextCarID += 1
        
        self.level = level
        self.pathIndex = pathIndex
        let cgPath = level.paths[pathIndex].CGPath(level)
        self.bezierPath = UIBezierPath(CGPath: cgPath)
        self.pathLength = self.bezierPath.length()
        self.mySpeed = speed
        super.init(texture: texture, color: UIColor.blackColor(), size: size)
        
        self.zPosition = 21
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(time: CFTimeInterval) {
        self.level.enumerateChildNodesWithName("*") { node, stop in
            
            if let pathFollower = node as? PathFollower {
                
                if pathFollower.pathIndex == self.pathIndex {
                    if pathFollower.id < self.id {
                        // car is in front of me
                        if abs(pathFollower.pos - self.pos) < (max(self.size.width, self.size.height) + 10) {
                            // Check if car in front is stopped
                            if pathFollower.currentSpeed == 0 {
                                // It's stopped, so we should stop for a while
                                self.currentSpeed = 0
                                
                                // Go back to normal speed in a second
                                self.goBackToNormalSpeedAfterDelay(2.0)
                            } else {
                                // TODO: This could probably be made better.
                                
                                // The car in front is not stopped, so we should just slow down
                                self.currentSpeed = pathFollower.currentSpeed - 10
                                
                                // Go back to normal speed
                                self.goBackToNormalSpeedAfterDelay(2.0)
                            }
                        }
                    }
                }
            }
        }
        
        let posDelta = self.currentSpeed * CGFloat(time)
        self.pos += posDelta
        self.updateLocation()
    }

    
    func addToLevel(level: LevelNode) {
        level.addChild(self)
        self.updateLocation()
    }
    
    private func updateLocation() {
        let percent = self.pos / self.pathLength
        var slope: CGFloat = 0
        self.position = self.bezierPath.pointAtPercentOfLength(percent, tangent: &slope)
        self.zRotation = slope
    }
    
    private func goBackToNormalSpeedAfterDelay(delay: NSTimeInterval) {
        let wait = SKAction.waitForDuration(delay)
        let normalSpeed = SKAction.runBlock({
            self.currentSpeed = self.mySpeed
        })
        let sequence = SKAction.sequence([wait, normalSpeed])
        self.runAction(sequence)
    }
    
    func speedUp(mult: CGFloat) {
        self.currentSpeed = self.mySpeed * mult
        self.goBackToNormalSpeedAfterDelay(2.0)
    }
    
    func slowDown(mult: CGFloat) {
        self.currentSpeed = self.mySpeed * mult
        self.goBackToNormalSpeedAfterDelay(2.0)
    }
}


