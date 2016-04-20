//
//  Person.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 4/17/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit


class Person: PathFollower {
    
    init(level: LevelNode, pathIndex: Int) {
        let physicsPath = UIBezierPath(ovalInRect: CGRect(x: -12.5, y: -12.5, width: 25, height: 25))
        let categoryBitMask = CollisionTypePerson
        let contactTestBitMask = CollisionTypeLevelBorder | CollisionTypeCar | CollisionTypePerson
        
        super.init(level: level, pathIndex: pathIndex, speed: PERSON_SPEED, image: ImageManager.imageForPerson(), physicsPath: physicsPath, categoryBitMask: categoryBitMask, contactTestBitMask: contactTestBitMask)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(time: CFTimeInterval) {
        super.update(time)
    }
}