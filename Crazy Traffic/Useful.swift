//
//  Useful.swift
//  Crazy Traffic
//
//  Created by Ana Vitoria do Valle Costa on 4/7/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation

class Useful {
    static func random(min: Int, max: Int) -> Int {
        let range = UInt32(min)...UInt32(max - 1)
        let a = range.lowerBound + arc4random_uniform(range.upperBound - range.lowerBound + 1)
        return Int(a)
    }
    
    static var randomBool: Bool {
        return random(min: 0, max: 2) == 0
    }
}

extension UIColor {
    convenience init(hex: String) {
        var rgbInt: UInt64 = 0
        let newHex = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: newHex)
        scanner.scanHexInt64(&rgbInt)
        let r: CGFloat = CGFloat((rgbInt & 0xFF0000) >> 16)/255.0
        let g: CGFloat = CGFloat((rgbInt & 0x00FF00) >> 8)/255.0
        let b: CGFloat = CGFloat(rgbInt & 0x0000FF)/255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
