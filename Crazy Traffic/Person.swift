//
//  Car.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/23/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit


class Person: PathFollower {
    
    init(level: LevelNode, pathIndex: Int) {
        let personImage = ImageManager.imageForCar()
        let texture = SKTexture(image: personImage)
        super.init(level: level, pathIndex: pathIndex, texture: texture, color: UIColor.blackColor(), size: personImage.size, speed: PERSON_SPEED)
        self.name = "person"
        self.physicsBody = SKPhysicsBody(rectangleOfSize: personImage.size)
        self.physicsBody?.categoryBitMask = CollisionTypes.Person.rawValue
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