//
//  Person.swift
//  Crazy Traffic
//
//  Created by Ana Vitoria do Valle Costa on 9/11/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit


class Garbage: PathFollower {
    
    init(level: LevelNode, pathIndex: Int, speed: CGFloat) {
        let physicsPath = UIBezierPath(ovalIn: CGRect(x: -30, y: -30, width: 60, height: 60))
        super.init(level: level, pathIndex: pathIndex, speed: speed, image: UIImage(named: "PlasticBag")!, physicsPath: physicsPath)
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
