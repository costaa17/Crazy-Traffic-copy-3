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
    
    class func loadLevel(levelNum: Int) -> Level? {
        let path = NSBundle.mainBundle().pathForResource("Level\(levelNum)", ofType: "json")
        
        var dataString = ""
        
        do {
            dataString = try String(contentsOfFile: path!)
        } catch {
            print("Error reading file for level \(levelNum)")
        }
        
        if let levelDict = convertJSONStringToDictionary(dataString) {
            return Level(data: levelDict)
        } else {
            print("Error loading level \(levelNum)")
        }
        
        return nil
    }
    
    /* The level data dictionary is in the following format:
    * cols  : # of cols
    * rows  : # of rows
    * paths : [pathObj]
    *
    * where pathObj is a dictionary containing:
    *
    * type     : path type (road, rail, etc)
    * segments : [["(x,y)", "(x,y)"], ["(x,y)", "(x,y)"], etc.]
    */
    private class func convertJSONStringToDictionary(dataString: String) -> [String:AnyObject]? {
        if let data = dataString.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let dict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String:AnyObject]
                var paths: [Path] = []
                let pathArray: [[String:AnyObject]] = dict["paths"]! as! [[String : AnyObject]]
                for i in 0 ..< pathArray.count {
                    let pathDict: [String:AnyObject] = pathArray[i]
                    
                    let pathTypeString = pathDict["type"] as! String
                    var pathType: Path.PathType
                    switch pathTypeString {
                    case "Rail":
                        pathType = Path.PathType.Rail
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
                    paths.append(Path(type: pathType, segments: segments))
                }
                
                return [
                    "rows": dict["rows"] as! Int,
                    "cols": dict["cols"] as! Int,
                    "backgroundColor": dict["backgroundColor"] as! String,
                    "levelNum": dict["levelNum"] as! Int,
                    "levelGoal": dict["levelGoal"] as! Int,
                    "hasTutorial": dict["hasTutorial"] as! Bool,
                    "tutorialText": dict["tutorialText"] as! String,
                    "paths": paths
                ]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}