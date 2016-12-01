//
//  Person.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 4/17/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit


class Person: PathFollower {
    
    init(level: LevelNode, pathIndex: Int, speed: CGFloat) {
        let physicsPath = UIBezierPath(ovalIn: CGRect(x: -30, y: -30, width: 60, height: 60))
        let categoryBitMask = CollisionTypePerson
        let contactTestBitMask = CollisionTypeLevelBorder | CollisionTypeCar | CollisionTypePerson
        
        super.init(level: level, pathIndex: pathIndex, speed: speed, image: ImageManager.imageForPerson(), physicsPath: physicsPath, categoryBitMask: categoryBitMask, contactTestBitMask: contactTestBitMask)
        self.xScale = 0.3
        self.yScale = 0.3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(_ time: CFTimeInterval) {
        super.update(time)
    }
}
