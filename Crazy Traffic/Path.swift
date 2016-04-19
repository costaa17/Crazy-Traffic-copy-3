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
        case Walk = "Walk"
    }
    
    var type: PathType
    var segments: [PathSegment]
    
    init(type: PathType, segments: [PathSegment]) {
        self.type = type
        self.segments = segments
    }
    
    func CGPath(level: LevelNode) -> CGPathRef {
        let path = CGPathCreateMutable()
        for i in 0 ..< self.segments.count {
            // index is used to either move to point (beginning of path) or
            // add line to point (index > 0)
            self.segments[i].addToPath(path, index: i, level: level)
        }
        return path
    }
    
}