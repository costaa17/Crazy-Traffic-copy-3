//
//  NoLifeNode.swift
//  Crazy Traffic
//
//  Created by Ana Vitoria do Valle Costa on 9/11/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import SpriteKit


class NoLifeNode: SKSpriteNode {
    var buyButton: AGSpriteButton?
    var askFriendsButton: AGSpriteButton?
    required init?(coder aDecoder: NSCoder) {
        // Swift requires this initializer to exist
        fatalError("init(coder:) has not been implemented")
    }
    let timerLabel = SKLabelNode(text: "")
    
    init(size: CGSize) {
        // Outset screen size slightly to prevent seeing what's underneath
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let bounds = rect.insetBy(dx: -1, dy: -1)
        super.init(texture: nil, color: UIColor.black, size: bounds.size)
        self.anchorPoint = CGPoint.zero
        self.position = CGPoint(x: -1, y: -1)
        self.zPosition = Z_GAMEOVER_VIEW
        self.isHidden = true
        
        let textNode = SKLabelNode(text: "Sory, you have no lives.")
        textNode.name = "text"
        textNode.fontName = FONT_NAME
        textNode.fontSize = FONT_SIZE_L
        textNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 40)
        self.addChild(textNode)
        
        timerLabel.fontName = "Lane - Narrow"
        timerLabel.fontSize = FONT_SIZE_XL
        timerLabel.fontColor = LIFE_COLOR
        timerLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 40)
        updateTimerText()
        self.addChild(timerLabel)
        self.hide()
        
        self.buyButton = AGSpriteButton(color: LEVEL_SELECT_COLOR, andSize: CGSize(width: 170, height: 40))
        self.buyButton!.position = CGPoint(x: self.frame.width/4, y: 70)
        self.buyButton!.name = "Buy"
        self.buyButton!.addTarget(self, selector:#selector(NoLifeNode.goToStore), with: nil, for:AGButtonControlEvent.touchUpInside)
        self.buyButton!.setLabelWithText("Buy more lives now", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
        self.addChild(buyButton!)
        
        self.askFriendsButton = AGSpriteButton(color: LEVEL_SELECT_COLOR, andSize: CGSize(width: 170, height: 40))
        self.askFriendsButton!.position = CGPoint(x: 3 * self.frame.width/4, y: 70)
        self.askFriendsButton!.name = "Buy"
        self.askFriendsButton!.addTarget(self, selector:#selector(NoLifeNode.askFriends), with: nil, for:AGButtonControlEvent.touchUpInside)
        self.askFriendsButton!.setLabelWithText("Ask Facebook friends", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
        self.addChild(askFriendsButton!)
        
    }
    
    func show() {
        if let scene = self.parent as? GameScene {
            if !scene.loggedIn{
                self.askFriendsButton!.setLabelWithText("Log in with Facebook", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
                self.askFriendsButton!.addTarget(self, selector:#selector(NoLifeNode.goToIntroScene), with: nil, for:AGButtonControlEvent.touchUpInside)
            }
            scene.currentScreen = Screen.noLife
            self.isHidden = false
        }
    }
    
    func goToIntroScene(){
        if let gs = self.parent as? GameScene {
            let scene = IntroScene()
            let skView = gs.view!
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .resizeFill
            scene.size = (size: skView.bounds.size)
            scene.gvc = gs.gvc
            skView.presentScene(scene)
        }
    }
    
    func hide() {
        self.isHidden = true
    }
    
    func updateTimerText(){
        if let scene = self.parent as? GameScene {
            var first0 = ""
            var second0 = ""
            if scene.minutesLeft < 10{
                first0 = "0"
            }
            if scene.secondsLeft < 10{
                second0 = "0"
            }
            timerLabel.text = first0 + String(scene.minutesLeft) + ":" + second0 + String(scene.secondsLeft)
        }
    }
    
    func goToStore(){
        if let scene = self.parent as? GameScene {
            scene.playSound(scene.buttonSound)
            scene.store.show()
            self.hide()
        }
    }
    
    func askFriends(){
        if let scene = self.parent as? GameScene {
            scene.playSound(scene.buttonSound)
            scene.askFriendsNode.show()
            self.hide()
        }
    }
}
