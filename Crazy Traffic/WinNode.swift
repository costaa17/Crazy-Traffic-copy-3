//
//  NoLifeNode.swift
//  Crazy Traffic
//
//  Created by Ana Vitoria do Valle Costa on 9/11/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import SpriteKit
import Firebase


class WinNode: SKSpriteNode {
    var textNode: SKLabelNode!
    var keepPlayingButton: AGSpriteButton?
    var nextLevelButton: AGSpriteButton?
    var backToMapButton: AGSpriteButton?
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
        self.alpha = 0.9
        
        textNode = SKLabelNode()
        textNode.fontName = FONT_NAME
        textNode.fontSize = FONT_SIZE_L
        textNode.text = "Good Job! You reached the goal!"
        textNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(textNode)
        
        self.keepPlayingButton = AGSpriteButton(color: LEVEL_SELECT_COLOR, andSize: CGSize(width: 110, height: 40))
        self.keepPlayingButton!.position = CGPoint(x: self.frame.width/4, y: 70)
        self.keepPlayingButton!.addTarget(self, selector:#selector(WinNode.keepPlaying), with: nil, for:AGButtonControlEvent.touchUpInside)
        self.keepPlayingButton!.setLabelWithText("Keep Playing", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
        //self.addChild(keepPlayingButton!)
        
        self.nextLevelButton = AGSpriteButton(color: LEVEL_SELECT_COLOR, andSize: CGSize(width: 110, height: 40))
        self.nextLevelButton!.position = CGPoint(x: 1 * self.frame.width/2, y: 70)
        self.nextLevelButton!.addTarget(self, selector:#selector(WinNode.nextLevel), with: nil, for:AGButtonControlEvent.touchUpInside)
        self.nextLevelButton!.setLabelWithText("Next Level", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
        self.addChild(nextLevelButton!)
        
        self.backToMapButton = AGSpriteButton(color: LEVEL_SELECT_COLOR, andSize: CGSize(width: 110, height: 40))
        self.backToMapButton!.position = CGPoint(x: 3 * self.frame.width/4, y: 70)
        self.backToMapButton!.addTarget(self, selector:#selector(WinNode.backToMap), with: nil, for:AGButtonControlEvent.touchUpInside)
        self.backToMapButton!.setLabelWithText("Back to Map", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
        self.addChild(backToMapButton!)
    }
    
    func show() {
        if let scene = self.parent as? GameScene {
            scene.currentScreen = Screen.win
            scene.shouldUpdate = false
            let currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
            if scene.levelNode.levelNum == currentLevel {
                let level = currentLevel + 1
                UserDefaults.standard.set(level, forKey: "currentLevel")
                if UserDefaults.standard.integer(forKey: "me") != 1{
                FIRAnalytics.setUserPropertyString(String(level), forName: "currentLevel")
                FIRAnalytics.logEvent(withName: "LevelUp", parameters: [
                    kFIRParameterContentType: "level" as NSObject,
                    kFIRParameterItemID: level as NSObject
                    ])
                }
            }
            let lev = scene.levelNode.levelNum
            let temp = "level" + String(lev)
            let episode = (lev - 1) / LEVELS_PER_EPISODE
            let temp2 = "episode" + String(episode)
            if UserDefaults.standard.integer(forKey: "me") != 1{
            GameAnalytics.addProgressionEvent(with: GAProgressionStatusComplete, progression01:temp2, progression02: temp, progression03:" ")
            }
        }
        if let scene = self.parent as? GameScene {
            let levelNum = scene.levelNode.levelNum + 1
            if levelNum % 20 == 1{
                nextLevelButton?.isHidden = true
                backToMapButton?.isHidden = false
            } else {
                nextLevelButton?.isHidden = false
                backToMapButton?.isHidden = true
            }
        }
        
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
        if let scene = self.parent as? GameScene {
            scene.currentScreen = Screen.levelPlay
            scene.shouldUpdate = true
        }
    }
    
    func keepPlaying(){
        hide()
        if let scene = self.parent as? GameScene {
            scene.playSound(scene.buttonSound)
        }
    }
    
    func nextLevel(){
        if let scene = self.parent as? GameScene {
            let levelNum = scene.levelNode.levelNum + 1
            let levn = scene.levelNode
            scene.loadLevel(levelNum: levelNum)
            levn?.removeFromParent()
            scene.shouldUpdate = true
            scene.playSound(scene.buttonSound)
        }
        self.isHidden = true
        
    }
    
    func backToMap(){
        if let scene = self.parent as? GameScene {
            scene.levelNode.removeFromParent()
            scene.levelNode = nil
            self.hide()
            scene.playSound(scene.buttonSound)
            scene.currentScreen = .levelSelect
        }
    }
    
}
