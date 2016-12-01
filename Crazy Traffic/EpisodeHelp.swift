//
//  NoLifeNode.swift
//  Crazy Traffic
//
//  Created by Ana Vitoria do Valle Costa on 9/11/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import SpriteKit


class EpisodeHelp: SKSpriteNode {
    var textNode: SKMultilineLabel!
    required init?(coder aDecoder: NSCoder) {
        // Swift requires this initializer to exist
        fatalError("init(coder:) has not been implemented")
    }
    init(size: CGSize) {
        // Outset screen size slightly to prevent seeing what's underneath
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let bounds = rect.insetBy(dx: -1, dy: -1)
        super.init(texture: nil, color: UIColor.black, size: bounds.size)
        self.anchorPoint = CGPoint.zero
        self.position = CGPoint(x: -1, y: -1)
        self.zPosition = Z_GAMEOVER_VIEW
        self.isHidden = true
        let labelWidth = 400
        let pos = CGPoint(x: self.frame.midX, y: self.frame.midY + 100)
        let fontName = FONT_NAME
        let fontSize = FONT_SIZE_M
        let fontColor = UIColor.white
        textNode = SKMultilineLabel(text: "", labelWidth: labelWidth, pos: pos, fontName: fontName, fontSize: fontSize, fontColor: fontColor,leading: 28)
        textNode.name = "text"
        textNode.fontName = FONT_NAME
        textNode.fontSize = FONT_SIZE_L
        //textNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 40)
        self.addChild(textNode)
    }
    
    func show(_ text: String) {
        textNode.text = text
        if let scene = self.parent as? GameScene {
            scene.currentScreen = Screen.episodeHelp
        }
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
    
}
