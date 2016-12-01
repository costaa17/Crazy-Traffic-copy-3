//
//  Car.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/23/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit


class Car: PathFollower {
    
    init(level: LevelNode, pathIndex: Int, speed: CGFloat) {
        let speed: CGFloat = speed
        let physicsPath = UIBezierPath(roundedRect: CGRect(x: -15.5, y: -29, width: 31, height: 58), cornerRadius: 12)
        let categoryBitMask = CollisionTypeCar
        let contactTestBitMask = CollisionTypeLevelBorder | CollisionTypeCar
        
        super.init(level: level, pathIndex: pathIndex, speed: speed, image: ImageManager.imageForCar(), physicsPath: physicsPath, categoryBitMask: categoryBitMask, contactTestBitMask: contactTestBitMask)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(_ time: CFTimeInterval) {
        self.level.enumerateChildNodes(withName: "path_follower") { node, stop in
            let pathFollower = node as! PathFollower
            if pathFollower.pathIndex == self.pathIndex {
                if pathFollower.id < self.id {
                    // car is in front of me
                    if abs(pathFollower.positionAlongPath - self.positionAlongPath) < (max(self.size.width, self.size.height) + 10) {
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
        
        super.update(time)
    }
    
}
