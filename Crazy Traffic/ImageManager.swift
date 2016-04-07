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
    
    class func imageForCar(color: UIColor, id: Int) -> UIImage {
        let size:CGSize = CGSize(width: 45, height: 66);
        UIGraphicsBeginImageContext(size)
        //// Color Declarations
        let carColor = UIColor(red: 0.050, green: 0.050, blue: 0.050, alpha: 1.000)
        let carTopColor = UIColor(red: 0.998, green: 0.998, blue: 0.998, alpha: 1.000)
        
        //// Car body Drawing
        let carBodyPath = UIBezierPath(roundedRect: CGRectMake(6, 4, 34, 60), cornerRadius: 12)
        carColor.setFill()
        carBodyPath.fill()
        UIColor.blackColor().setStroke()
        carBodyPath.lineWidth = 2.5
        carBodyPath.stroke()
        
        
        //// wheel1 Drawing
        let wheel1Path = UIBezierPath(roundedRect: CGRectMake(3, 12, 6, 9), cornerRadius: 3)
        UIColor.blackColor().setFill()
        wheel1Path.fill()
        
        
        //// wheel2 Drawing
        let wheel2Path = UIBezierPath(roundedRect: CGRectMake(3, 45, 6, 9), cornerRadius: 3)
        UIColor.blackColor().setFill()
        wheel2Path.fill()
        
        
        //// wheel3 Drawing
        let wheel3Path = UIBezierPath(roundedRect: CGRectMake(37, 12, 6, 9), cornerRadius: 3)
        UIColor.blackColor().setFill()
        wheel3Path.fill()
        
        
        //// wheel4 Drawing
        let wheel4Path = UIBezierPath(roundedRect: CGRectMake(37, 45, 6, 9), cornerRadius: 3)
        UIColor.blackColor().setFill()
        wheel4Path.fill()
        
        
        //// Car window Drawing
        let carWindowPath = UIBezierPath(ovalInRect: CGRectMake(12, 26, 22, 15))
        UIColor.lightGrayColor().setFill()
        carWindowPath.fill()
        
        
        //// Car top Drawing
        let carTopPath = UIBezierPath(roundedRect: CGRectMake(12, 32, 22, 22), cornerRadius: 7)
        carTopColor.setFill()
        carTopPath.fill()


        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}