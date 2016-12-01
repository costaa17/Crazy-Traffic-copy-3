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
        case CrossWalk = "CrossWalk"
        case CrazyPed = "CrazyPed"
        case Garbage = "Garbage"
    }
    
    var type: PathType
    var segments: [PathSegment]
    var initMaxInterval: Float
    var initMinInterval: Float
    var maxIntervalLimit: UInt32
    var minIntervalLimit: UInt32
    var initSpeed: CGFloat
    var maxSpeed: CGFloat

    // This will be the initial time until next run, so we want it relatively small
    var timeUntilNextRun: CFTimeInterval = CFTimeInterval(arc4random_uniform(START_TIME_UPPER_BOUND))
    // This will be the next time until next run
    var timeInterval: CFTimeInterval
    
    init(type: PathType, segments: [PathSegment], initMaxInterval: Float, initMinInterval: Float, maxIntervalLimit: UInt32, minIntervalLimit: UInt32, initSpeed: CGFloat, maxSpeed: CGFloat) {
        self.type = type
        self.segments = segments
        self.initMaxInterval = initMaxInterval
        self.initMinInterval = initMinInterval
        self.maxIntervalLimit = maxIntervalLimit
        self.minIntervalLimit = minIntervalLimit
        self.initSpeed = initSpeed
        self.maxSpeed = maxSpeed
        timeUntilNextRun = CFTimeInterval(arc4random_uniform(UInt32(initMaxInterval + initMinInterval) / 2))
        self.timeInterval = CFTimeInterval(arc4random_uniform(UInt32(initMaxInterval - initMinInterval)) + UInt32(initMinInterval))
    }
    
    func CGPath(_ level: LevelNode) -> CGPath {
        let path = CGMutablePath()
        for i in 0 ..< self.segments.count {
            // index is used to either move to point (beginning of path) or
            // add line to point (index > 0)
            self.segments[i].addToPath(path: path, index: i, level: level)
        }
        return path
    }
    
    func pathUpdate(_ intervalMult: Float, speedMult: CGFloat) {

        if(initMaxInterval * intervalMult >= Float(maxIntervalLimit)){
            initMaxInterval = (initMaxInterval) * intervalMult
        }
        if(Float(initMinInterval) * intervalMult >= Float(minIntervalLimit)){
            initMinInterval = (initMinInterval) * intervalMult
        }
        if(initSpeed * speedMult <= maxSpeed){
            initSpeed *= speedMult;
        }
    }
    
    func updateTimeInterval() {
         //CFTimeInterval(arc4random_uniform(UInt32(initMaxInterval - initMinInterval)) + UInt32(initMinInterval))
        let ran =  Float(arc4random()) / Float(UINT32_MAX) * abs(initMaxInterval - initMinInterval) + min(initMaxInterval, initMinInterval)
        self.timeInterval = CFTimeInterval(ran)
        //print (timeInterval)
        
    }
    
}
