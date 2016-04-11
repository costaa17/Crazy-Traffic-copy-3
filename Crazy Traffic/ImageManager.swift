//
//  ImageManager.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/3/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import UIKit

class ImageManager {
    
    class func imageForLevel(level: Int, fillColor: UIColor, strokeColor: UIColor) -> UIImage {
        // Setup our context
        let size:CGSize = CGSize(width: 44, height: 44);
        let bounds = CGRectInset(CGRect(origin: CGPoint.zero, size: size), 5, 5)
        let opaque = false
        let scale: CGFloat = 0
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(context, 0.0, size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        CGContextSetFillColorWithColor(context, fillColor.CGColor)
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor)
        CGContextSetLineWidth(context, 2.0)
        CGContextFillEllipseInRect(context, bounds)
        CGContextStrokeEllipseInRect(context, bounds)
        
        let aFont = UIFont(name: "AvenirNextCondensed-Bold", size: 22)
        let attr:CFDictionaryRef = [NSFontAttributeName:aFont!, NSForegroundColorAttributeName: strokeColor]
        let text = CFAttributedStringCreate(nil, String(level), attr)
        let line = CTLineCreateWithAttributedString(text)
        let textBounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.UseOpticalBounds)
        CGContextSetTextPosition(context, CGRectGetMidX(bounds) - textBounds.midX, CGRectGetMidY(bounds) - textBounds.midY)
        CTLineDraw(line, context!)
        
        
        // Drawing complete, retrieve the finished image and cleanup
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    class func backgroundImageForSize(size: CGSize) -> UIImage {
        let bkg = UIImage(named: "Background")
        let backgroundCGImage = bkg!.CGImage
        let coverageSize = size
        let textureSize = CGRectMake(0, 0, bkg!.size.width, bkg!.size.height); // the size of the tile.
        
        UIGraphicsBeginImageContextWithOptions(coverageSize, false, UIScreen.mainScreen().scale);
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawTiledImage(context, textureSize, backgroundCGImage)
        let tiledBackground = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tiledBackground
    }
    
    class func imageForCar() -> UIImage {
        let size: CGSize = CGSize(width: 45, height: 66);
        
        UIGraphicsBeginImageContext(size)
        
        //// Color Declarations
        var carColor: UIColor!
        var carTopColor: UIColor!
        var carWindowColor: UIColor!
        var carWheelColor: UIColor!
        var carStrokeColor: UIColor!
        if Useful.randomBool {
            // Black car
            carColor    = CAR_1_COLOR_BODY
            carTopColor = CAR_1_COLOR_TOP
            carWindowColor = CAR_1_COLOR_WINDOW
            carWheelColor = CAR_1_COLOR_WHEEL
            carStrokeColor = CAR_1_COLOR_STROKE
        } else {
            // White car
            carColor    = CAR_2_COLOR_BODY
            carTopColor = CAR_2_COLOR_TOP
            carWindowColor = CAR_2_COLOR_WINDOW
            carWheelColor = CAR_2_COLOR_WHEEL
            carStrokeColor = CAR_2_COLOR_STROKE
        }
        
        //// Car body Drawing
        let carBodyPath = UIBezierPath(roundedRect: CGRectMake(3, 1, 34, 60), cornerRadius: 12)
        carColor.setFill()
        carBodyPath.fill()
        carStrokeColor.setStroke()
        carBodyPath.lineWidth = 2.5
        carBodyPath.stroke()
        
        
        //// wheel1 Drawing
        let wheel1Path = UIBezierPath(roundedRect: CGRectMake(0, 12, 6, 9), cornerRadius: 3)
        carWheelColor.setFill()
        wheel1Path.fill()
        
        
        //// wheel2 Drawing
        let wheel2Path = UIBezierPath(roundedRect: CGRectMake(0, 40, 6, 9), cornerRadius: 3)
        carWheelColor.setFill()
        wheel2Path.fill()
        
        
        //// wheel3 Drawing
        let wheel3Path = UIBezierPath(roundedRect: CGRectMake(34, 12, 6, 9), cornerRadius: 3)
        carWheelColor.setFill()
        wheel3Path.fill()
        
        
        //// wheel4 Drawing
        let wheel4Path = UIBezierPath(roundedRect: CGRectMake(34, 40, 6, 9), cornerRadius: 3)
        carWheelColor.setFill()
        wheel4Path.fill()
        
        
        //// Car window Drawing
        let carWindowPath = UIBezierPath(ovalInRect: CGRectMake(9, 25, 22, 15))
        carWindowColor.setFill()
        carWindowPath.fill()
        
        
        //// Car top Drawing
        let carTopPath = UIBezierPath(roundedRect: CGRectMake(9, 32, 22, 22), cornerRadius: 7)
        carTopColor.setFill()
        carTopPath.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}