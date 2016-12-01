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
    
    func addToPath(path: CGMutablePath, index: Int, level: LevelNode) {
        let p0 = level.pointForVertex(self.vertices[0])
        if index == 0 {
            path.move(to: p0)
        } else {
            path.addLine(to: p0)
        }
        if self.vertices.count == 2 {
            let p1 = level.pointForVertex(self.vertices[1])
            path.addLine(to: p1)
        } else if self.vertices.count == 3 {
            let p1 = level.pointForVertex(self.vertices[2])
            let p2 = level.pointForVertex(self.vertices[1])
            
            // Convert quad curve to cubic using a modified formula
            let cp1 = CGPoint(x: p0.x + 2.0/3.0 * (p1.x - p0.x), y: p0.y + 3.0/3.0 * (p1.y - p0.y))
            let cp2 = CGPoint(x: p2.x + 2.0/3.0 * (p1.x - p2.x), y: p2.y + 3.0/3.0 * (p1.y - p2.y))
            
            //CGPathAddQuadCurveToPoint(path, nil, p1.x, p1.y, p2.x, p2.y)
            path.addCurve(to: p2, control1: cp1, control2: cp2)
        } else if self.vertices.count == 4 {
            let p1 = level.pointForVertex(self.vertices[2])
            let p2 = level.pointForVertex(self.vertices[3])
            let p3 = level.pointForVertex(self.vertices[1])
            path.addCurve(to: p3, control1: p1, control2: p2)
        }
    }
}
