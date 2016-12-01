//
//  PathFollower.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 4/18/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit


class PathFollower: SKSpriteNode {
    // A unique id -- objects with lower ids were added earlier (and therefore are ahead)
    // of objects with higher ids
    let id: Int
    
    // The index of the path I'm on -- this is used to make sure I can't collide with
    // other sprites on my path
    let pathIndex: Int
    // Cache the UIBezierPath version of the path I'm on -- paths are stored in levels as
    // Path objects, which generate CGPaths from an array of vertices
    let bezierPath: UIBezierPath
    // Cache the length of the path I'm on
    let pathLength: CGFloat
    
    // My default speed
    let mySpeed: CGFloat
    // My current speed, which can be faster or slower than my default speed, if the
    // player swipes or taps me
    var currentSpeed: CGFloat = 0
    // Current position along path -- some fraction of path.length
    var positionAlongPath: CGFloat = 0
    
    // Used to keep track of how many times a car hits the border around the screen.
    // It will hit once when it enters and hit a second time when it leaves, which
    // is when we want to remove the car
    var edgeHitCount: Int = 0
    // Keep track of time since car hit edge - cars entering by the corners might colide multiple times - only remove car when hit an edge if this is > 30
    var lastEdgeHit: Int = 0
    // make sure accelarated cars count even if they hit the other edge in less than 30
    var slided = false
    
    // Reference to level in which this car exists -- used to check for other cars on the path
    weak var level: LevelNode!

    init(level: LevelNode, pathIndex: Int, speed: CGFloat, image: UIImage, physicsPath: UIBezierPath, categoryBitMask: UInt32, contactTestBitMask: UInt32) {
        self.id = level.nextCarID
        
        self.pathIndex = pathIndex
        let cgPath = level.paths[pathIndex].CGPath(level)
        self.bezierPath = UIBezierPath(cgPath: cgPath)
        self.pathLength = self.bezierPath.length()
        
        // Set speed
        self.mySpeed = speed
        self.currentSpeed = self.mySpeed
        
        // Set sprite and physics body
        super.init(texture: SKTexture(image: image), color: UIColor.red, size: image.size)
        
        self.name = "path_follower"
        self.zPosition = Z_PATH_FOLLOWER
        
        self.physicsBody = SKPhysicsBody(polygonFrom: physicsPath.cgPath)
        self.physicsBody?.categoryBitMask = categoryBitMask
        self.physicsBody?.collisionBitMask = CollisionTypeNone
        self.physicsBody?.contactTestBitMask = contactTestBitMask
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.usesPreciseCollisionDetection = true
        
        // Add to level
        self.level = level
        self.level.addChild(self)
        
        // Set initial position/rotation
        //self.updateLocation()
    }
    
    init(level: LevelNode, pathIndex: Int, speed: CGFloat, image: UIImage, physicsPath: UIBezierPath) {
        self.id = level.nextCarID
        
        self.pathIndex = pathIndex
        let cgPath = level.paths[pathIndex].CGPath(level)
        self.bezierPath = UIBezierPath(cgPath: cgPath)
        self.pathLength = self.bezierPath.length()
        
        // Set speed
        self.mySpeed = speed
        self.currentSpeed = self.mySpeed
        
        // Set sprite and physics body
        
        super.init(texture: SKTexture(image: image), color: UIColor.red, size: image.size)
        
        self.name = "path_follower"
        self.zPosition = Z_PATH_FOLLOWER
        
        // Add to level
        self.level = level
        self.level.addChild(self)
        
        // Set initial position/rotation
        //self.updateLocation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLocation(_ time: CFTimeInterval) {
        let percent = self.positionAlongPath / self.pathLength
        var slope: CGFloat = 0
        let posDelta = self.currentSpeed * CGFloat(time)
        let path = self.bezierPath.path(atPercentOfLength: percent, tangent: &slope)
        let subpath = self.bezierPath.path(atPercentOfLength: percent, tangent: &slope)
        if(subpath.type == .addCurveToPoint){
            let t = Float(percent) + (Float(posDelta)/self.bezierPath.quadTan(percent, a: subpath.startPoint, b: subpath.controlPoint1, c: subpath.endPoint))
        }
        self.position = self.bezierPath.point(atPercentOfLength: percent, tangent: &slope)
        self.zRotation = slope
    }
    
    func update(_ time: CFTimeInterval) {
        let posDelta = self.currentSpeed * CGFloat(time)
       // self.positionAlongPath += posDelta
        self.updateLocation(time)
        self.lastEdgeHit += 1
    }
    
    func speedUp() {
        self.currentSpeed = self.mySpeed * FAST_CAR_MULT
        //self.goBackToNormalSpeedAfterDelay(2.0)
        slided = true
        self.createTireTracksAtCurrentPosition()
    }
    
    func slowDown() {
        self.currentSpeed = self.mySpeed * SLOW_CAR_MULT
        self.goBackToNormalSpeedAfterDelay(4.0)
    }
    
    func goBackToNormalSpeedAfterDelay(_ delay: TimeInterval) {
        let wait = SKAction.wait(forDuration: delay)
        let normalSpeed = SKAction.run({
            self.currentSpeed = self.mySpeed
        })
        let sequence = SKAction.sequence([wait, normalSpeed])
        self.run(sequence)
    }
    
    fileprivate func createTireTracksAtCurrentPosition() {
        // Start by approximating the current percent of the length of the path we are at.
        // Then, we can generate more points at subsequent percents of the path until we
        // have a certain distance.
        let tolerance: CGFloat = 5.0
        
        for p in stride(from: 0.0, through: 1.0, by: 0.01) {
            let point = self.bezierPath.point(atPercentOfLength: CGFloat(p))
            
            if point.x > self.position.x - tolerance && point.x < self.position.x + tolerance && point.y > self.position.y - tolerance && point.y < self.position.y + tolerance {
                
                // Found approximate current point at p% of length of path
                let startPoint = point
                var endPoint = point
                
                var totalDistance: CGFloat = 0.0
                var prevPoint = point
                for q in stride(from: p, through: 1.0, by: 0.01) {
                    let nextPoint = self.bezierPath.point(atPercentOfLength: CGFloat(q))
                    totalDistance += hypot(nextPoint.x - prevPoint.x, nextPoint.y - prevPoint.y)
                    prevPoint = nextPoint
                    if totalDistance > 40 {
                        endPoint = nextPoint
                        break
                    }
                }
                
                self.addTireTrackShapeNode(startPoint, endPoint: endPoint, offsetBy: 12.0)
                self.addTireTrackShapeNode(startPoint, endPoint: endPoint, offsetBy: -12.0)

                break
            }
        }
    }
    
    fileprivate func addTireTrackShapeNode(_ startPoint: CGPoint, endPoint: CGPoint, offsetBy: CGFloat) {
        let points = lineSegment((startPoint, endPoint), offsetBy: offsetBy)
        let track = UIBezierPath()
        track.move(to: points.0)
        track.addLine(to: points.1)
        let trackShapeNode = SKShapeNode(path: track.cgPath)
        trackShapeNode.zPosition = Z_TIRE_TRACKS
        trackShapeNode.lineWidth = 3.0
        trackShapeNode.strokeColor = TIRE_TRACKS_COLOR
        
        self.level.view.addChild(trackShapeNode)
        
        let fade = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        trackShapeNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), fade, remove]))
    }
    
    fileprivate func lineSegment(_ segment: (CGPoint, CGPoint), offsetBy offset: CGFloat) -> (CGPoint, CGPoint) {
        let p0 = segment.0
        let p1 = segment.1
        
        // Compute (dx, dy) as a vector in the direction from p0 to p1, with length `offset`.
        var dx = p1.x - p0.x
        var dy = p1.y - p0.y
        let length = hypot(dx, dy)
        dx *= offset / length
        dy *= offset / length
        
        // Rotate the vector one quarter turn in the direction from the x axis to the y axis, so it's perpendicular to the line segment from p0 to p1.
        (dx, dy) = (-dy, dx)
        
        let p0Out = CGPoint(x: p0.x + dx, y: p0.y + dy)
        let p1Out = CGPoint(x: p1.x + dx, y: p1.y + dy)
        return (p0Out, p1Out)
    }
}
