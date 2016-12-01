//
//  Train.swift
//  Crazy Traffic
//
//  Created by Ana Vitoria do Valle Costa on 11/17/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation

class Train {
    let numOfCars: Int
    let levelNode: LevelNode
    var cars = [TrainCar]()
    let pathIndex: Int
    var speed: CGFloat
    init(numOfCars: Int, levelNode: LevelNode, pathIndex: Int, speed: CGFloat) {
        self.numOfCars = numOfCars
        self.levelNode = levelNode
        self.pathIndex = pathIndex
        self.speed = speed
    }
    
    func createCars() {
        for i in 0..<numOfCars {
            cars.append(TrainCar(level: levelNode, pathIndex: pathIndex, speed: speed, carNum: i))
        }
    }
}
