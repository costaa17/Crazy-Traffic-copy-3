//
//  Car.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/23/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit


class Car: PathFollower {
    var carSpeed: CGFloat = 0
    
    init(level: LevelNode, pathIndex: Int) {
        if VARIABLE_CAR_SPEED {
            switch Useful.random(min: 1, max: 5) {
            case 1:
                self.carSpeed = CAR_1_SPEED
            case 2:
                self.carSpeed = CAR_2_SPEED
            case 3:
                self.carSpeed = CAR_3_SPEED
            case 4:
                self.carSpeed = CAR_4_SPEED
            case 5:
                self.carSpeed = CAR_5_SPEED
            default:
                self.carSpeed = CAR_SPEED
            }
        } else {
            self.carSpeed = CAR_SPEED
        }
        
        let carImage = ImageManager.imageForCar()
        let texture = SKTexture(image: carImage)
        super.init(level: level, pathIndex: pathIndex, texture: texture, color: UIColor.blackColor(), size: carImage.size, speed: carSpeed)
        self.name = "car"
        self.zPosition = 21
        let physicsBodyOffset = CGPoint(x: -20, y: -29)
        let carBodyPath = UIBezierPath(roundedRect: CGRectMake(physicsBodyOffset.x, physicsBodyOffset.y, 34, 60), cornerRadius: 12)
        self.physicsBody = SKPhysicsBody(polygonFromPath: carBodyPath.CGPath)
        self.physicsBody?.categoryBitMask = CollisionTypes.Car.rawValue
        self.physicsBody?.collisionBitMask = CollisionTypes.None.rawValue
        self.physicsBody?.contactTestBitMask = CollisionTypes.LevelBorder.rawValue | CollisionTypes.Car.rawValue
        
        self.addToLevel(level)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    func speedUp() {
        super.speedUp(FAST_CAR_MULT)
    }
    
    func slowDown() {
        super.slowDown(SLOW_CAR_MULT)
    }
    
}