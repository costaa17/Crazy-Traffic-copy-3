//
//  GameOver.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/30/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit


class GameOverNode: SKSpriteNode {
    let carLabelNode: SKLabelNode
    
    required init?(coder aDecoder: NSCoder) {
        // Swift requires this initializer to exist
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        self.carLabelNode = SKLabelNode(text: "Car 99 and Car 99 collided!")
        
        // Outset screen size slightly to prevent seeing what's underneath
        let bounds = CGRectInset(UIScreen.mainScreen().bounds, -1, -1)
        super.init(texture: nil, color: UIColor.blackColor(), size: bounds.size)
        self.anchorPoint = CGPointZero
        self.position = CGPoint(x: -1, y: -1)
        self.zPosition = 999
        self.hidden = true
        self.alpha = 0.6
        
        let center = CGPoint(x: self.size.width/2, y: self.size.height/2)
        
        let textNode = SKLabelNode(text: "Game Over")
        textNode.fontName = FONT_NAME
        textNode.fontSize = FONT_SIZE_XL
        textNode.position = CGPoint(x: center.x, y: center.y + 15)
        self.addChild(textNode)
        
        self.carLabelNode.fontName = FONT_NAME
        self.carLabelNode.fontSize = FONT_SIZE_M
        self.carLabelNode.position = CGPoint(x: center.x, y: center.y - 15)
        self.addChild(self.carLabelNode)
        
    }
    
    func show(id1: Int, id2: Int) {
        if let scene = self.parent as? GameScene {
            scene.currentScreen = Screen.GameOver
            self.carLabelNode.text = "Car \(id1) and Car \(id2) collided!"
            self.hidden = false
            
        }
    }
    
    func hide() {
        if let scene = self.parent as? GameScene {
            scene.currentScreen = Screen.LevelSelect
            self.hidden = true
        }
    }
    
}