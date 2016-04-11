//
//  PathComponent.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/16/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import UIKit


class PathSegment {
    var vertices: [PathVertex]
    
    init(vertices: [PathVertex]) {
        self.vertices = vertices
    }
    
    func addToPath(path: CGMutablePathRef, index: Int, level: LevelNode) {
        let p0 = level.pointForVertex(self.vertices[0])
        if index == 0 {
            CGPathMoveToPoint(path, nil, p0.x, p0.y)
        } else {
            CGPathAddLineToPoint(path, nil, p0.x, p0.y)
        }
        
        if self.vertices.count == 2 {
            let p1 = level.pointForVertex(self.vertices[1])
            CGPathAddLineToPoint(path, nil, p1.x, p1.y)
            
        } else if self.vertices.count == 3 {
            let p1 = level.pointForVertex(self.vertices[1])
            let p2 = level.pointForVertex(self.vertices[2])
            CGPathAddQuadCurveToPoint(path, nil, p1.x, p1.y, p2.x, p2.y)
            
        } else if self.vertices.count == 4 {
            let p1 = level.pointForVertex(self.vertices[1])
            let p2 = level.pointForVertex(self.vertices[2])
            let p3 = level.pointForVertex(self.vertices[3])
            CGPathAddCurveToPoint(path, nil, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)
        }
    }
    
    // Builds a path from the vertices based on the properties of the
    // passed game level
    func CGPath(level: LevelNode) -> CGPathRef {
        
        // A segment is either 2, 3, or 4 vertices
        let cgPath = CGPathCreateMutable()
        
        return cgPath
    }
}