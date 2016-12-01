//
//  LevelManager.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/4/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class LevelManager {
    
    class func loadLevel(_ levelNum: Int, gs: GameScene) -> LevelNode? {
        let path = Bundle.main.path(forResource: "Level\(levelNum)", ofType: "json")
        
        var dataString = ""
        
        do {
            dataString = try String(contentsOfFile: path!)
        } catch {
            print("Error reading file for level \(levelNum)")
        }
        
        if let levelDict = convertJSONStringToDictionary(dataString) {
            return LevelNode(data: levelDict, size: gs.frame.size)
        } else {
            print("Error loading level \(levelNum)")
        }
        
        return nil
    }
    
    /* The level data dictionary is in the following format:  // this is not updated
     * cols  : # of cols
     * rows  : # of rows
     * paths : [pathObj]
     *
     * where pathObj is a dictionary containing:
     *
     * type     : path type (road, rail, etc)
     * segments : [["(x,y)", "(x,y)"], ["(x,y)", "(x,y)"], etc.]
     */
    fileprivate class func convertJSONStringToDictionary(_ dataString: String) -> [String:AnyObject]? {
        if let data = dataString.data(using: String.Encoding.utf8) {
            do {
                let dict = try JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
                var paths: [Path] = []
                let pathArray: [[String:AnyObject]] = dict["paths"]! as! [[String : AnyObject]]
                var garbArray: [Garbage] = [Garbage]()
                var garbPath1: [PathSegment]? = nil
                for i in 0 ..< pathArray.count {
                    let pathDict: [String:AnyObject] = pathArray[i]
                    
                    let pathTypeString = pathDict["type"] as! String
                    var pathType: Path.PathType
                    switch pathTypeString {
                    case "Rail":
                        pathType = Path.PathType.Rail
                    case "Walk":
                        pathType = Path.PathType.Walk
                    case "CrazyPed":
                        pathType = Path.PathType.CrazyPed
                    case "CrossWalk":
                        pathType = Path.PathType.CrossWalk
                    case "Garbage":
                        pathType = Path.PathType.Garbage
                    default:
                        pathType = Path.PathType.Road
                    }
                    
                    let segmentsArray: [[String]] = pathDict["segments"] as! [[String]]
                    var segments: [PathSegment] = []
                    for j in 0 ..< segmentsArray.count {
                        let segmentArray: [String] = segmentsArray[j]
                        var vertices: [PathVertex] = []
                        for k in 0 ..< segmentArray.count {
                            let pointString = segmentArray[k]
                            let point = CGPointFromString(pointString)
                            vertices.append(PathVertex(row: Int(point.x), col: Int(point.y)))
                        }
                        segments.append(PathSegment(vertices: vertices))
                    }
                    
                    let initMinInterval = pathDict["initMinInterval"] as! String
                    let initMaxInterval = pathDict["initMaxInterval"] as! String
                    let maxIntervalLimit = pathDict["maxIntervalLimit"] as! String
                    let minIntervalLimit = pathDict["minIntervalLimit"] as! String
                    let initSpeed = pathDict["initSpeed"] as! String
                    let maxSpeed = pathDict["maxSpeed"] as! String
                    paths.append(Path(type: pathType, segments: segments, initMaxInterval: Float(initMaxInterval)!, initMinInterval: Float(initMinInterval)!, maxIntervalLimit: UInt32(maxIntervalLimit)!, minIntervalLimit: UInt32(minIntervalLimit)!, initSpeed: CGFloat(Float(initSpeed)!), maxSpeed: CGFloat(Float(maxSpeed)!)))
                    
                }
                
                return [
                    "rows": dict["rows"] as! Int as AnyObject,
                    "cols": dict["cols"] as! Int as AnyObject,
                    "backgroundColor": dict["backgroundColor"] as! String as AnyObject,
                    "levelNum": dict["levelNum"] as! Int as AnyObject,
                    "goal": dict["goal"] as! Int as AnyObject,
                    "pedGoal": dict["pedGoal"] as! Int as AnyObject,
                    "carGoal": dict["carGoal"] as! Int as AnyObject,
                    "tutorialText": dict["tutorialText"] as! String as AnyObject,
                    "intervalMult": dict["intervalMult"] as! Float as AnyObject,
                    "speedMult": dict["speedMult"] as! CGFloat as AnyObject,
                    "paths": paths as AnyObject,
                    "garbage": garbArray as AnyObject
                ]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}
