//
//  Path.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/16/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit


class Path {
    enum PathType: String {
        case Road = "Road"
        case Rail = "Rail"
    }
    
    var type: PathType
    var segments: [PathSegment]
    var interval: Int // remaining units of _ for car to run in this path
    
    init(type: PathType, segments: [PathSegment]) {
        self.type = type
        self.segments = segments
        self.interval = Useful.random(min: 100,max: 450)
    }
    
    func CGPath(level: Level) -> CGPathRef {
        let path = CGPathCreateMutable()
        for i in 0 ..< self.segments.count {
            // index is used to either move to point (beginning of path) or
            // add line to point (index > 0)
            self.segments[i].addToPath(path, index: i, level: level)
        }
        return path
    }
    
    func shouldRunCar() -> Bool{
        self.interval -= 1
        if interval <= 0{
            interval = Useful.random(min: 150,max: 450)
            return true
        }
        return false
    }
}