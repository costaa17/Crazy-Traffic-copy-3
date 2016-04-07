//
//  Useful.swift
//  Crazy Traffic
//
//  Created by Ana Vitoria do Valle Costa on 4/7/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
class Useful {
    static func random(min min: Int, max: Int) -> Int {
        let range = UInt32(min)...UInt32(max - 1)
        let a = range.startIndex + arc4random_uniform(range.endIndex - range.startIndex + 1)
        return Int(a)
    }
    
    static var randomBool: Bool {
        return random(min: 0, max: 1) == 0
    }
}
