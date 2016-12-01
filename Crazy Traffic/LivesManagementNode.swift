//
//  NoLifeNode.swift
//  Crazy Traffic
//
//  Created by Ana Vitoria do Valle Costa on 9/11/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import SpriteKit
import StoreKit
import Firebase


class LivesManagementNode: SKSpriteNode {
    
    let REQUEST_PER_PAGE = 5
    var exitButton: AGSpriteButton?
    var buyButton: AGSpriteButton?
    var askFriendsButton: AGSpriteButton?
    var arrowRight: SKSpriteNode!
    var arrowLeft: SKSpriteNode!
    var livesLabel: SKLabelNode! = SKLabelNode()
    var pageNum = 0 {
        didSet {
            arrowRight.isHidden = false
            if pageNum == 0 {
                arrowLeft.isHidden = true
            }else{
                arrowLeft.isHidden = false
            }
            self.enumerateChildNodes(withName: "text") { node, stop in
                node.removeFromParent()
            }
            showRequests()
        }
    }
    
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
        
        
        let spacing = self.frame.maxY/CGFloat((REQUEST_PER_PAGE + 1) * 2) - 1
        livesLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - spacing)
        livesLabel.fontName = FONT_NAME
        livesLabel.fontSize = FONT_SIZE_L
        updateLivesNum()
        self.addChild(livesLabel)
        
        
        setUpButtons()
        drawDivisions()
        showRequests()
    }
    
    func setUpButtons() {
        //cancel button
        self.exitButton = AGSpriteButton(color: LEVEL_SELECT_COLOR, andSize: CGSize(width: 50, height: 30))
        self.exitButton!.position = CGPoint(x: self.frame.midX, y: self.frame.maxY/12)
        self.exitButton!.name = "Exit"
        self.exitButton!.addTarget(self, selector:#selector(AskFriendsNode.hide), with: nil, for:AGButtonControlEvent.touchUpInside)
        self.exitButton!.setLabelWithText("Exit", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
        self.addChild(exitButton!)
        
        arrowRight = SKSpriteNode(texture: SKTexture(image: ImageManager.imageForArrow(DARK_COLOR, stroke: LIGHT_COLOR)))
        arrowRight.name = "arrowRight"
        arrowRight.zRotation = 3 * CGFloat(M_PI)/2
        arrowRight.position = CGPoint(x: self.frame.maxX - 50, y: self.frame.maxY/CGFloat((REQUEST_PER_PAGE + 1)*2))
        self.addChild(arrowRight)
        
        arrowLeft = SKSpriteNode(texture: SKTexture(image: ImageManager.imageForArrow(DARK_COLOR, stroke: LIGHT_COLOR)))
        arrowLeft.name = "arrowLeft"
        arrowLeft.zRotation = CGFloat(M_PI)/2
        arrowLeft.position = CGPoint(x: self.frame.minX + 50, y: self.frame.maxY/CGFloat((REQUEST_PER_PAGE + 1)*2))
        self.addChild(arrowLeft)
        arrowLeft.isHidden = true
        
        self.buyButton = AGSpriteButton(color: LEVEL_SELECT_COLOR, andSize: CGSize(width: 100, height: 30))
        self.buyButton!.position = CGPoint(x: self.frame.width/4, y: self.exitButton!.position.y)
        self.buyButton!.name = "Buy"
        self.buyButton!.addTarget(self, selector:#selector(LivesManagementNode.goToStore), with: nil, for:AGButtonControlEvent.touchUpInside)
        self.buyButton!.setLabelWithText("Buy more", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
        self.addChild(buyButton!)
        
        self.askFriendsButton = AGSpriteButton(color: LEVEL_SELECT_COLOR, andSize: CGSize(width: 100, height: 30))
        self.askFriendsButton!.position = CGPoint(x: 3 * self.frame.width/4, y: self.exitButton!.position.y)
        self.askFriendsButton!.name = "Ask friends"
        self.askFriendsButton!.addTarget(self, selector:#selector(LivesManagementNode.askFriends), with: nil, for:AGButtonControlEvent.touchUpInside)
        self.askFriendsButton!.setLabelWithText("Ask friends", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
        self.addChild(askFriendsButton!)

    }
    
    func drawDivisions() {
        for i in 1...REQUEST_PER_PAGE + 1{
            let d1 = CGMutablePath()
            d1.move(to: CGPoint(x: 0, y: CGFloat(i) * self.frame.maxY/CGFloat(REQUEST_PER_PAGE + 2)))
            d1.addLine(to: CGPoint(x: self.frame.maxX, y: CGFloat(i) * self.frame.maxY/CGFloat(REQUEST_PER_PAGE + 2)))
            let s1 = SKShapeNode()
            s1.path = d1
            s1.lineWidth = 1
            s1.strokeColor = UIColor.white
            addChild(s1)
        }
    }
    
    func showRequests() {
        for i in 0...REQUEST_PER_PAGE - 1 {
            if requestsArray.count > (REQUEST_PER_PAGE - 1 - i) + REQUEST_PER_PAGE * pageNum {
                let request = requestsArray[(REQUEST_PER_PAGE * pageNum) + (REQUEST_PER_PAGE - 1 - i)]
                let textNode = SKLabelNode(text: request.text)
                textNode.name = "text"
                textNode.fontName = FONT_NAME
                textNode.fontSize = FONT_SIZE_M
                textNode.horizontalAlignmentMode = .left
                let x = self.frame.minX + 10
                let spacing = self.frame.maxY/CGFloat((REQUEST_PER_PAGE + 2) * 2)
                print((1 + (2 * CGFloat(i))))
                let y = (3 + (2 * CGFloat(i))) * spacing - 5
                textNode.position = CGPoint(x: x, y: y)
                self.addChild(textNode)
                if request.type == .asked{
                    let sendButton = AGSpriteButton(color: LEVEL_SELECT_COLOR, andSize: CGSize(width: 50, height: 30))
                    sendButton!.position = CGPoint(x: self.frame.maxX - 50, y: ((3 + (2 * CGFloat(i))) * spacing))
                    sendButton!.name = "text"
                    //sendButton!.addTarget(self, selector:#selector(LivesManagementNode.sendLives), with: nil, for:AGButtonControlEvent.touchUpInside)
                    sendButton?.perform({ 
                        self.sendLives(index: self.REQUEST_PER_PAGE - 1 - i)
                        }, on: AGButtonControlEvent.touchUpInside)
                    sendButton!.setLabelWithText("Send", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
                    self.addChild(sendButton!)
                }else{
                    let getButton = AGSpriteButton(color: LEVEL_SELECT_COLOR, andSize: CGSize(width: 50, height: 30))
                    getButton!.position = CGPoint(x: self.frame.maxX - 50, y: ((3 + (2 * CGFloat(i))) * spacing))
                    getButton!.name = "text"
                    //getButton!.addTarget(self, selector:#selector(LivesManagementNode.sendLives), with: nil, for:AGButtonControlEvent.touchUpInside)
                    getButton?.perform({
                        self.acceptLives(index: self.REQUEST_PER_PAGE - 1 - i)
                        }, on: AGButtonControlEvent.touchUpInside)
                    getButton!.setLabelWithText("Get", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
                    self.addChild(getButton!)
                }
            } else {
                self.arrowRight.isHidden = true
            }
        }
        /*for i in 0...FRIENDS_PER_PAGE - 1 {
            if facebookFriends.count > (FRIENDS_PER_PAGE - 1 - i) + FRIENDS_PER_PAGE * pageNum {
                let friend = facebookFriends[(FRIENDS_PER_PAGE * pageNum) + (FRIENDS_PER_PAGE - 1 - i)]
                let textNode = SKLabelNode(text: friend.name)
                textNode.name = "text"
                textNode.fontName = FONT_NAME
                textNode.fontSize = FONT_SIZE_L
                textNode.horizontalAlignmentMode = .left
                let x = self.frame.minX + 80
                let spacing = self.frame.maxY/CGFloat((FRIENDS_PER_PAGE + 1) * 2)
                let y = (3 + (2 * CGFloat(i))) * spacing - 10
                textNode.position = CGPoint(x: x, y: y)
                self.addChild(textNode)
                let url = NSURL(string: friend.pictureURL)
                var imageData = NSData()
                do {
                    imageData =  try NSData(contentsOf: url as! URL)
                    
                } catch {
                    
                }
                let image = UIImage(data:imageData as Data)
                
                let s = SKSpriteNode(texture: SKTexture(image: image!))
                s.name = "image"
                s.xScale = 0.4
                s.yScale = 0.4
                s.position = CGPoint(x: self.frame.minX + s.size.width/2 + 20, y: textNode.position.y + 10)
                self.addChild(s)
                textNode.position.x = s.position.x + s.size.width + 20
                
            } else if facebookFriends.count == (FRIENDS_PER_PAGE - 1 - i) + FRIENDS_PER_PAGE * pageNum {
                let textNode = SKLabelNode(text: "Invite more friends")
                textNode.name = "text"
                textNode.fontName = FONT_NAME
                textNode.fontSize = FONT_SIZE_L
                textNode.horizontalAlignmentMode = .left
                let x = self.frame.minX + 20
                let spacing = self.frame.maxY/CGFloat((FRIENDS_PER_PAGE + 1)*2)
                let y = (3 + (2 * CGFloat(i))) * spacing - 10
                textNode.position = CGPoint(x: x, y: y)
                self.addChild(textNode)
                arrowRight.isHidden = true
            }
        }*/
    }
    
    func show() {
        updateLivesNum()
        if let scene = self.parent as? GameScene {
            scene.currentScreen = Screen.lifeManagement
            self.isHidden = false
        }
        arrowRight.xScale = 0
        arrowRight.yScale = 0
        arrowRight.run(SKAction.scale(to: 0.7, duration: 0.4))
        arrowLeft.xScale = 0
        arrowLeft.yScale = 0
        arrowLeft.run(SKAction.scale(to: 0.7, duration: 0.4))
    }
    
    func hide() {
        if let scene = self.parent as? GameScene {
            scene.showLevelSelectScreen()
            scene.playSound(scene.buttonSound)
        }
        self.isHidden = true
    }
    
    func updateLivesNum(){
        let lives = UserDefaults.standard.integer(forKey: "lives")
        if lives == 1 {
            livesLabel.text = "You have " + String(lives) + " life"
        }
        livesLabel.text = "You have " + String(lives) + " lives"
    }
    
    func sendLives(index: Int){
        if let scene = self.parent as? GameScene {
            scene.playSound(scene.buttonSound)
            scene.sendLives(requestIndex: index)
        }
        self.enumerateChildNodes(withName: "text") { node, stop in
            node.removeFromParent()
        }
        showRequests()
    }
    
    func acceptLives(index: Int){
        if let scene = self.parent as? GameScene {
            scene.playSound(scene.buttonSound)
            scene.deleteRequest(id: requestsArray[index].id)
        }
        let currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
        let atEpisode = (currentLevel - 1) / LEVELS_PER_EPISODE
        if UserDefaults.standard.integer(forKey: "lives") < maxLifeForEpisode(atEpisode) - 5{
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "lives") + 5, forKey: "lives")
        }else{
            UserDefaults.standard.set(maxLifeForEpisode(atEpisode), forKey: "lives")
        }
        updateLivesNum()
        requestsArray.remove(at: index)
        self.enumerateChildNodes(withName: "text") { node, stop in
            node.removeFromParent()
        }
        showRequests()
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
            self.hide()
            scene.askFriendsNode.show()
        }
    }
}
