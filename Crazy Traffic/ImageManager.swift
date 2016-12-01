//
//  ImageManager.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/3/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import UIKit

class ImageManager {
    
    class func imageForLevel(_ level: Int, fillColor: UIColor, strokeColor: UIColor) -> UIImage {
        // Setup our context
        let size:CGSize = CGSize(width: 44, height: 44);
        let bounds = CGRect(origin: CGPoint.zero, size: size).insetBy(dx: 5, dy: 5)
        let opaque = false
        let scale: CGFloat = 0
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()
        
        context?.translateBy(x: 0.0, y: size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        context?.setFillColor(fillColor.cgColor)
        context?.setStrokeColor(strokeColor.cgColor)
        context?.setLineWidth(2.0)
        context?.fillEllipse(in: bounds)
        context?.strokeEllipse(in: bounds)
        
        let aFont = UIFont(name: "Lane - Narrow", size: 24)
        let attr = [NSFontAttributeName:aFont!, NSForegroundColorAttributeName: strokeColor]
        let text = CFAttributedStringCreate(nil, String(level) as CFString!, attr as CFDictionary!)
        let line = CTLineCreateWithAttributedString(text!)
        let textBounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.useOpticalBounds)
        context!.textPosition = CGPoint(x: bounds.midX - textBounds.midX, y: bounds.midY - textBounds.midY + 1)
        CTLineDraw(line, context!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /*class func backgroundImageForSize(_ size: CGSize) -> UIImage {
     let bkg = UIImage(named: "Background")
     let backgroundCGImage = bkg!.cgImage
     let coverageSize = size
     let textureSize = CGRect(x: 0, y: 0, width: bkg!.size.width, height: bkg!.size.height); // the size of the tile.
     
     UIGraphicsBeginImageContextWithOptions(coverageSize, false, UIScreen.main.scale);
     let context = UIGraphicsGetCurrentContext()
     CGContextDrawTiledImage(context, textureSize, backgroundCGImage)
     let tiledBackground = UIGraphicsGetImageFromCurrentImageContext()
     UIGraphicsEndImageContext()
     return tiledBackground!
     }*/
    
    class func imageForCar() -> UIImage {
        let size: CGSize = CGSize(width: 65, height: 90);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
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
        
        //UIColor.redColor().set()
        //UIBezierPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height)).fill()
        
        //// Car Body Drawing
        let carBodyPath = UIBezierPath(roundedRect: CGRect(x: 17, y: 16, width: 31, height: 58), cornerRadius: 12)
        carColor.setFill()
        carBodyPath.fill()
        carStrokeColor.setStroke()
        carBodyPath.lineWidth = 2
        carBodyPath.stroke()
        
        
        //// Car Window Drawing
        let carWindowPath = UIBezierPath(ovalIn: CGRect(x: 23, y: 39, width: 19, height: 10))
        carWindowColor.setFill()
        carWindowPath.fill()
        
        
        //// topRightWheel Drawing
        let topRightWheelPath = UIBezierPath(roundedRect: CGRect(x: 45, y: 27, width: 6, height: 10), cornerRadius: 3)
        carWheelColor.setFill()
        topRightWheelPath.fill()
        
        
        //// Car Top Drawing
        let carTopPath = UIBezierPath(roundedRect: CGRect(x: 23, y: 45, width: 19, height: 20), cornerRadius: 5)
        carTopColor.setFill()
        carTopPath.fill()
        
        
        //// topLeftWheel Drawing
        let topLeftWheelPath = UIBezierPath(roundedRect: CGRect(x: 14, y: 27, width: 6, height: 10), cornerRadius: 3)
        carWheelColor.setFill()
        topLeftWheelPath.fill()
        
        
        //// bottomRightWheel Drawing
        let bottomRightWheelPath = UIBezierPath(roundedRect: CGRect(x: 45, y: 55, width: 6, height: 10), cornerRadius: 3)
        carWheelColor.setFill()
        bottomRightWheelPath.fill()
        
        
        //// bottomLeftWheel Drawing
        let bottomLeftWheelPath = UIBezierPath(roundedRect: CGRect(x: 14, y: 55, width: 6, height: 10), cornerRadius: 3)
        carWheelColor.setFill()
        bottomLeftWheelPath.fill()
        
        
        
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    class func imageForArrow(_ fill: UIColor, stroke: UIColor) -> UIImage {
        let size: CGSize = CGSize(width: 65, height: 90);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(rect: CGRect(x: 23.5, y: 39.5, width: 17, height: 43))
        fill.setFill()
        rectanglePath.fill()
        stroke.setStroke()
        rectanglePath.lineWidth = 2
        rectanglePath.stroke()
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 32.38, y: 5.5))
        bezierPath.addLine(to: CGPoint(x: 59, y: 39))
        bezierPath.addLine(to: CGPoint(x: 5, y: 39))
        bezierPath.addLine(to: CGPoint(x: 32.38, y: 5.5))
        bezierPath.close()
        fill.setFill()
        bezierPath.fill()
        stroke.setStroke()
        bezierPath.lineWidth = 2
        bezierPath.stroke()
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 25, y: 39))
        bezier2Path.addLine(to: CGPoint(x: 39, y: 39))
        fill.setFill()
        bezier2Path.fill()
        fill.setStroke()
        bezier2Path.lineWidth = 4
        bezier2Path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    class func imageForPerson() -> UIImage {
        let size: CGSize = CGSize(width: 67, height: 39);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        //// Color Declarations
        let color2 = UIColor(red: 0.181, green: 0.157, blue: 0.157, alpha: 1.000)
        
        //// Shirt Drawing
        let shirtPath = UIBezierPath(ovalIn: CGRect(x: 1, y: 6, width: 66, height: 27))
        PEDESTRIAN_COLOR.setFill()
        shirtPath.fill()
        UIColor.black.setStroke()
        shirtPath.lineWidth = 2
        shirtPath.stroke()
        
        //// head Drawing
        let headPath = UIBezierPath(ovalIn: CGRect(x: 15, y: 0, width: 39, height: 39))
        UIColor.black.setFill()
        headPath.fill()
        
        //// Left arm Drawing
        let leftArmPath = UIBezierPath()
        leftArmPath.move(to: CGPoint(x: 0.21, y: 19))
        leftArmPath.addCurve(to: CGPoint(x: 8, y: 8), controlPoint1: CGPoint(x: 0.21, y: 19), controlPoint2: CGPoint(x: -2.01, y: 8))
        color2.setFill()
        leftArmPath.fill()
        
        //// Rigth arm Drawing
        let rigthArmPath = UIBezierPath()
        rigthArmPath.move(to: CGPoint(x: 66.79, y: 17))
        rigthArmPath.addCurve(to: CGPoint(x: 59, y: 6), controlPoint1: CGPoint(x: 66.79, y: 17), controlPoint2: CGPoint(x: 69.01, y: 6))
        color2.setFill()
        rigthArmPath.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    class func imageForHelpSymbol() -> UIImage {
        let size: CGSize = CGSize(width: 38, height: 38);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        //// Color Declarations
        let helpSymbolColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.000)
        
        //// HelpSymbol Drawing
        let helpSymbolRect = CGRect(x: 1, y: 1, width: 35, height: 35)
        let helpSymbolPath = UIBezierPath(ovalIn: helpSymbolRect)
        helpSymbolColor.setStroke()
        helpSymbolPath.lineWidth = 2.5
        helpSymbolPath.stroke()
        let helpSymbolStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        helpSymbolStyle.alignment = .center
        
        let helpSymbolFontAttributes = [NSFontAttributeName: UIFont(name: "DINAlternate-Bold", size: 30)!, NSForegroundColorAttributeName: helpSymbolColor, NSParagraphStyleAttributeName: helpSymbolStyle]
        
        "?".draw(in: helpSymbolRect, withAttributes: helpSymbolFontAttributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    class func imageForLife() -> UIImage {
        let size: CGSize = CGSize(width: 34, height: 29);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        //// Color Declarations
        let color = LIFE_COLOR
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 4.5, y: 15.35))
        bezierPath.addLine(to: CGPoint(x: 11.76, y: 25.5))
        bezierPath.addLine(to: CGPoint(x: 32.5, y: 5.5))
        color.setStroke()
        bezierPath.lineWidth = 5
        bezierPath.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    class func imageForNoLife() -> UIImage {
        let size: CGSize = CGSize(width: 34, height: 29);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        //// Color Declarations
        let color = UIColor(red: 1.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0.5, y: -0.5))
        bezierPath.addCurve(to: CGPoint(x: 32.5, y: 27.5), controlPoint1: CGPoint(x: 32.5, y: 27.5), controlPoint2: CGPoint(x: 32.5, y: 27.5))
        color.setStroke()
        bezierPath.lineWidth = 5
        bezierPath.stroke()
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 33.5, y: -0.5))
        bezier2Path.addLine(to: CGPoint(x: 0.5, y: 28.5))
        color.setStroke()
        bezier2Path.lineWidth = 5
        bezier2Path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    class func imageForSoundIcon(soundOn: Bool) -> UIImage {
        let size: CGSize = CGSize(width: 48, height: 52);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        //// Color Declarations
        let color = UIColor.white
        
        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(rect: CGRect(x: 1, y: 16, width: 12, height: 25))
        color.setFill()
        rectanglePath.fill()
        
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 12.5, y: 15.5))
        bezierPath.addLine(to: CGPoint(x: 28, y: 3))
        bezierPath.addLine(to: CGPoint(x: 28, y: 52))
        bezierPath.addLine(to: CGPoint(x: 12.5, y: 41.5))
        bezierPath.addLine(to: CGPoint(x: 12.5, y: 15.5))
        bezierPath.close()
        color.setFill()
        bezierPath.fill()
        
        
        //// Wave 1 Drawing
        let wavePath = UIBezierPath()
        wavePath.move(to: CGPoint(x: 33, y: 16))
        wavePath.addCurve(to: CGPoint(x: 37.45, y: 21.83), controlPoint1: CGPoint(x: 33, y: 16), controlPoint2: CGPoint(x: 36.15, y: 18.39))
        wavePath.addCurve(to: CGPoint(x: 33, y: 39), controlPoint1: CGPoint(x: 39.31, y: 26.75), controlPoint2: CGPoint(x: 38.89, y: 33.8))
        color.setStroke()
        wavePath.lineWidth = 2
        wavePath.stroke()
        
        
        //// Wave 2 Drawing
        let wave2Path = UIBezierPath()
        wave2Path.move(to: CGPoint(x: 38.5, y: 10))
        wave2Path.addCurve(to: CGPoint(x: 45, y: 19), controlPoint1: CGPoint(x: 38.5, y: 10), controlPoint2: CGPoint(x: 43.1, y: 13.69))
        wave2Path.addCurve(to: CGPoint(x: 38.5, y: 45.5), controlPoint1: CGPoint(x: 47.71, y: 26.59), controlPoint2: CGPoint(x: 47.1, y: 37.47))
        color.setStroke()
        wave2Path.lineWidth = 2
        wave2Path.stroke()
        
        
        if !soundOn{
            //// NoSound Drawing
            let noSoundPath = UIBezierPath()
            noSoundPath.move(to: CGPoint(x: 0, y: 50))
            noSoundPath.addLine(to: CGPoint(x: 36, y: -0))
            UIColor.black.setStroke()
            noSoundPath.lineWidth = 4
            noSoundPath.stroke()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    class func imageForPlayButton() -> UIImage {
        let size: CGSize = CGSize(width: 67, height: 67);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        //// Color Declarations
        let stroke = UIColor.white
        
        //// Circle Drawing
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: 6,y :6), size: CGSize(width: 56, height: 56)) )
        stroke.setStroke()
        circlePath.lineWidth = 3.5
        circlePath.stroke()
        
        
        //// Arrow Drawing
        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: 26.5, y: 57.5))
        arrowPath.addLine(to: CGPoint(x: 26.5, y: 11))
        arrowPath.addLine(to: CGPoint(x: 52.5, y: 34.67))
        arrowPath.addLine(to: CGPoint(x: 26.5, y: 57.5))
        stroke.setStroke()
        arrowPath.lineWidth = 2.5
        arrowPath.stroke()
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}
