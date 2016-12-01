//
//  GameScene.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/3/16.
//  Copyright (c) 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit
import AVFoundation
import GoogleMobileAds
import Firebase
import FirebaseCrash

enum Screen {
    case levelSelect
    case levelIntro
    case levelPlay
    case gameOver
    case help
    case noLife
    case episodeHelp
    case store
    case win
    case askFriends
    case lifeManagement
}

let CollisionTypeNone: UInt32            = 1
let CollisionTypeLevelGround: UInt32     = 2
let CollisionTypeLevelBackground: UInt32 = 4
let CollisionTypeLevelBorder: UInt32     = 8
let CollisionTypeCar: UInt32             = 16
let CollisionTypePerson: UInt32          = 32

class GameScene: SKScene, SKPhysicsContactDelegate, FBSDKAppInviteDialogDelegate, FBSDKGameRequestDialogDelegate {
    var currentScreen: Screen = .levelSelect
    
    var levelNode: LevelNode!
    var gameOverNode: GameOverNode!
    var noLifeNode: NoLifeNode!
    var episodeHelpNode: EpisodeHelp!
    var store: Store!
    var winNode: WinNode!
    var askFriendsNode: AskFriendsNode!
    var livesManagementNode: LivesManagementNode!
    
    var touchedNode: SKNode!
    
    var lastUpdateTime: CFTimeInterval = 0.0
    var shouldUpdate: Bool = true
    var currentEpisode = -1
    
    let comingSoonLabel = SKLabelNode(text: "New levels coming soon!")
    let timerLabel = SKLabelNode(text: "")
    var lifeNumLabel = SKLabelNode(text: "")
    
    var minutesLeft = 0
    var secondsLeft = 0
    
    var gvc: GameViewController?
    
    var loggedIn = false
    
    var sound = false
    
    //load the sound effects
    let slideSound = SKAction.playSoundFileNamed("slideSound.mp3", waitForCompletion: false)
    let buttonSound = SKAction.playSoundFileNamed("buttonSound.mp3", waitForCompletion: false)
    let scoreSound = SKAction.playSoundFileNamed("scoreSound.mp3", waitForCompletion: false)
    let hornSound = SKAction.playSoundFileNamed("hornSound.mp3", waitForCompletion: false)
    let blockSound = SKAction.playSoundFileNamed("blockSound2.mp3", waitForCompletion: false)
    
    // MARK: - Move to view
    
    override func didMove(to view: SKView) {
        FIRCrashMessage("Chash in GameScene")
        //fatalError()
        
        let level = UserDefaults.standard.integer(forKey: "currentLevel")
        if UserDefaults.standard.integer(forKey: "me") != 1{
            FIRAnalytics.setUserPropertyString(String(level), forName: "currentLevel")
        }
        //let temp = "level" + String(level)
        
        
        //GameAnalytics.addProgressionEvent(with: GAProgressionStatusComplete, progression01:temp, progression02:" ", progression03:" ")
        
        self.physicsWorld.contactDelegate = self
        if UserDefaults.standard.value(forKey: "lives") == nil {
            UserDefaults.standard.set(10, forKey: "lives")
        }
        if UserDefaults.standard.value(forKey: "rateMe") == nil {
            UserDefaults.standard.set(false, forKey: "neverRate")
            if UserDefaults.standard.value(forKey: "currentLevel") != nil && UserDefaults.standard.integer(forKey: "currentLevel") > 8{
                UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "currentLevel"), forKey: "rateMe")
                rateMe()
            }else{
                UserDefaults.standard.set(8, forKey: "rateMe")
            }
            
            
        }
        
        if UserDefaults.standard.value(forKey: "subtractTime") == nil {
            UserDefaults.standard.set(0, forKey: "subtractTime")
        }
        
        if UserDefaults.standard.value(forKey: "time") == nil {
            UserDefaults.standard.setValue(Date(), forKey: "time")
        }
        
        if UserDefaults.standard.value(forKey: "latestEpisode") == nil {
            UserDefaults.standard.set(0, forKey: "latestEpisode")
        }
        
        if UserDefaults.standard.value(forKey: "played") == nil {
            UserDefaults.standard.set(0, forKey: "played")
        }
        if UserDefaults.standard.integer(forKey: "me") == 1{
        UserDefaults.standard.set(60, forKey: "currentLevel")
        UserDefaults.standard.set(15, forKey: "lives")
        UserDefaults.standard.set(0, forKey: "latestEpisode")
        }
        
        self.view!.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(GameScene.handlePanFrom(_:))))
        
        self.backgroundColor = LEVEL_SELECT_COLOR
        
        self.gameOverNode = GameOverNode(size: self.frame.size)
        self.addChild(self.gameOverNode)
        
        self.noLifeNode = NoLifeNode(size: self.frame.size)
        self.addChild(noLifeNode)
        
        self.episodeHelpNode = EpisodeHelp(size: self.frame.size)
        self.addChild(episodeHelpNode)
        
        self.store = Store(size: self.frame.size)
        self.addChild(store)
        
        self.winNode = WinNode(size: self.frame.size)
        self.addChild(winNode)
        
        self.askFriendsNode = AskFriendsNode(size: self.frame.size)
        self.addChild(askFriendsNode)
        
        self.livesManagementNode = LivesManagementNode(size: self.frame.size)
        self.addChild(livesManagementNode)
        
        self.addChild(timerLabel)
        timerLabel.isHidden = true
        self.addChild(self.lifeNumLabel)
        lifeNumLabel.isHidden = true
        
        let titleLabel = SKLabelNode(text: "Crazy Traffic")
        titleLabel.fontName = "Lane - Narrow"
        titleLabel.fontSize = 60
        titleLabel.fontColor = UIColor.white
        titleLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height - 60)
        self.addChild(titleLabel)
        
        comingSoonLabel.isHidden = true
        comingSoonLabel.fontName = "Lane - Narrow"
        comingSoonLabel.fontSize = 60
        comingSoonLabel.fontColor = UIColor.white
        comingSoonLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        self.addChild(comingSoonLabel)
        
        self.enumerateChildNodes(withName: "level-*|arrow*|life*|sound") { node, stop in
            let spriteNode = node as! SKSpriteNode
            spriteNode.isHidden = true
        }
        // Generate images for level selection
        /*self.enumerateChildNodesWithName("level-*") { node, stop in
         let spriteNode = node as! SKSpriteNode
         let levelNum = Int(spriteNode.name!.componentsSeparatedByString("-")[1])!
         let fillColor = levelNum % 2 == 0 ? DARK_COLOR : LIGHT_COLOR
         let strokeColor = levelNum % 2 == 0 ? LIGHT_COLOR : DARK_COLOR
         spriteNode.texture = SKTexture(image: ImageManager.imageForLevel(levelNum, fillColor: fillColor, strokeColor: strokeColor))
         spriteNode.hidden = true
         }
         self.enumerateChildNodesWithName("arrow*") { node, stop in
         let spriteNode = node as! SKSpriteNode
         if node.name == "arrowUp" {
         spriteNode.texture = SKTexture(image: ImageManager.imageForArrow(LIGHT_COLOR, stroke: DARK_COLOR))
         } else {
         spriteNode.texture = SKTexture(image: ImageManager.imageForArrow(DARK_COLOR, stroke: LIGHT_COLOR))
         spriteNode.zRotation = CGFloat(M_PI)
         }
         spriteNode.hidden = true
         }*/
        self.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run({
            self.showLevelSelectScreen()
        })]))
        
        //allow people to keep listening their music
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with:AVAudioSessionCategoryOptions.mixWithOthers)
        try! AVAudioSession.sharedInstance().setActive(true)
    }
    
    func showLevelSelectScreen() {
        self.currentScreen = .levelSelect
        let currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
        if currentEpisode < 0 {
            currentEpisode = (currentLevel - 1) / LEVELS_PER_EPISODE
        }
        if currentLevel > UserDefaults.standard.integer(forKey: "rateMe") && !UserDefaults.standard.bool(forKey: "neverRate"){
            rateMe()
        }
        
        let atEpisode = (currentLevel - 1) / LEVELS_PER_EPISODE
        if UserDefaults.standard.integer(forKey: "latestEpisode") < currentEpisode && atEpisode >= currentEpisode && currentEpisode < MAX_EPISODE{
            UserDefaults.standard.set(currentEpisode, forKey: "latestEpisode")
            loadEpisodeHelp(currentEpisode)
        }
        
        var waitTime = 0.0
        var levelNum = 1 + (currentEpisode) * 20
        
        self.enumerateChildNodes(withName: "sound") { node, stop in
            node.xScale = 0
            node.yScale = 0
            node.isHidden = false
            node.run(SKAction.scale(to: 0.7, duration: 0.4))
            let spriteNode = node as! SKSpriteNode
            spriteNode.texture = SKTexture(image: ImageManager.imageForSoundIcon(soundOn: self.sound))
            
        }
        self.enumerateChildNodes(withName: "arrowDown") { node, stop in
            node.xScale = 0
            node.yScale = 0
            node.isHidden = false
            node.run(SKAction.scale(to: 1.0, duration: 0.4))
            let spriteNode = node as! SKSpriteNode
            spriteNode.texture = SKTexture(image: ImageManager.imageForArrow(DARK_COLOR, stroke: LIGHT_COLOR))
            node.zRotation = CGFloat(M_PI)
        }
        if currentEpisode < MAX_EPISODE {
            if currentEpisode > 0 { // no lives on episode 1
                if atEpisode < MAX_EPISODE {
                    self.enumerateChildNodes(withName: "life*") { node, stop in
                        if node.name == "lifeSymbol"{
                            let spriteNode = node as! SKSpriteNode
                            spriteNode.texture = SKTexture(image: ImageManager.imageForLife())
                            node.isHidden = false
                            spriteNode.xScale = 0.7
                            spriteNode.yScale = 0.7
                            self.timerLabel.position.x = spriteNode.position.x
                        } else if node.name == "lifeNumLabel" {
                            self.lifeNumLabel.text = String(UserDefaults.standard.integer(forKey: "lives"))
                            self.lifeNumLabel.fontName = "Lane - Narrow"
                            self.lifeNumLabel.fontSize = FONT_SIZE_L
                            self.lifeNumLabel.fontColor = LIFE_COLOR
                            self.lifeNumLabel.position = CGPoint(x: node.position.x, y: node.position.y - FONT_SIZE_M)
                            self.lifeNumLabel.isHidden = false
                            if UserDefaults.standard.integer(forKey: "lives") < maxLifeForEpisode(atEpisode) && self.currentEpisode < MAX_EPISODE{
                                self.timerLabel.isHidden = false
                            }
                            self.timerLabel.position.x += self.lifeNumLabel.position.x
                            self.timerLabel.position.x /= 2
                            self.timerLabel.position.y = self.lifeNumLabel.position.y - 30
                        }
                    }
                }
                timerLabel.text = String(minutesLeft) + ":" + String(secondsLeft)
                let currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
                
                let atEpisode = (currentLevel - 1) / LEVELS_PER_EPISODE
                if UserDefaults.standard.integer(forKey: "lives") < maxLifeForEpisode(atEpisode){
                    updateTimerText()
                    timerLabel.fontName = "Lane - Narrow"
                    timerLabel.fontSize = FONT_SIZE_M
                    timerLabel.fontColor = LIFE_COLOR
                    if currentEpisode < MAX_EPISODE {
                        //timerLabel.isHidden = false
                    }
                } else {
                    timerLabel.isHidden = true
                }
            }
            let currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
            let atEpisode = (currentLevel - 1) / LEVELS_PER_EPISODE
            if atEpisode == 0{
                self.lifeNumLabel.isHidden = true
                self.timerLabel.isHidden = true
                self.enumerateChildNodes(withName: "lifeSymbol") { node, stop in
                    node.isHidden = true
                }
            }
            comingSoonLabel.isHidden = true
            self.enumerateChildNodes(withName: "level-*|arrow*") { node, stop in
                let spriteNode = node as! SKSpriteNode
                if node.name == "arrowUp" {
                    spriteNode.texture = SKTexture(image: ImageManager.imageForArrow(LIGHT_COLOR, stroke: DARK_COLOR))
                } else if node.name != "arrowDown" {
                    //let level = Int(spriteNode.name!.componentsSeparatedByString("-")[1])!
                    let fillColor = levelNum % 2 == 0 ? DARK_COLOR : LIGHT_COLOR
                    let strokeColor = levelNum % 2 == 0 ? LIGHT_COLOR : DARK_COLOR
                    spriteNode.texture = SKTexture(image: ImageManager.imageForLevel(levelNum, fillColor: fillColor, strokeColor: strokeColor))
                }
                node.xScale = 0
                node.yScale = 0
                node.isHidden = false
                if node.name == "arrowDown" && self.currentEpisode == 0 {
                    node.isHidden = true
                }
                if levelNum > currentLevel && node.name != "arrowUp" && node.name != "arrowDown" {
                    node.alpha = 0.3
                } else {
                    node.alpha = 1.0
                }
                
                var sequence = SKAction.sequence([SKAction.wait(forDuration: waitTime), SKAction.scale(to: 1.0, duration: 0.4)])
                if levelNum == currentLevel {
                    sequence = SKAction.sequence([SKAction.wait(forDuration: waitTime), SKAction.scaleTo(1.0, duration: 4.0, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0)])
                }
                node.run(sequence)
                waitTime += 0.08
                levelNum += 1
            }
            
        } else {
            comingSoonLabel.isHidden = false
            self.enumerateChildNodes(withName: "level-*|arrowUp|life*") { node, stop in
                let spriteNode = node as! SKSpriteNode
                spriteNode.isHidden = true
            }
            self.timerLabel.isHidden = true
            self.lifeNumLabel.isHidden = true
        }
        //arrow?.hidden = false
    }
    
    // MARK: - Contact
    
    fileprivate func getOrderedBodies(_ contact: SKPhysicsContact) -> (firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
        var firstBody: SKPhysicsBody!
        var secondBody: SKPhysicsBody!
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        return (firstBody, secondBody)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodies = getOrderedBodies(contact)
        if bodies.firstBody.categoryBitMask == CollisionTypeCar &&
            bodies.secondBody.categoryBitMask == CollisionTypeCar {
            // Car hit a car
            let car1 = bodies.firstBody.node as! Car
            let car2 = bodies.secondBody.node as! Car
            if car1.pathIndex != car2.pathIndex {
                self.gameOverNode.show()
                playSound(self.hornSound)
                gvc?.addAd()
            }
        } else if bodies.firstBody.categoryBitMask == CollisionTypeCar &&
            bodies.secondBody.categoryBitMask == CollisionTypePerson {
            // Car hit person
            self.gameOverNode.show()
            playSound(self.hornSound)
            gvc?.addAd()
        }
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let bodies = getOrderedBodies(contact)
        
        // TODO: Each PathFollower has an edgeHitCount property that keeps track of how
        // many times a car has hit the border around the level. In theory, when the car
        // enters the level, it gets set to 1 and when the car exist the level it is > 1
        // and the car is removed. But if the path begins too close to the edge of the level,
        // it won't get set to 1 on level entry and therefore will never get removed (and the
        // score won't go up). Come up with a better way to track when the car exits the level.
        if bodies.firstBody.categoryBitMask == CollisionTypeLevelBorder && bodies.secondBody.categoryBitMask == CollisionTypeCar {
            // Car hit the edge of the level
            if let car = bodies.secondBody.node as? Car{
                car.edgeHitCount += 1
                if car.edgeHitCount > 1 && car.lastEdgeHit > 60 || (car.edgeHitCount > 1 && car.lastEdgeHit > 20 && car.slided){
                    self.levelNode.carScore += 1
                    car.removeFromParent()
                } else {
                    car.lastEdgeHit = 0
                }
            }
        } else if bodies.firstBody.categoryBitMask == CollisionTypeLevelBorder && bodies.secondBody.categoryBitMask == CollisionTypePerson {
            // Person hit the edge of the level
            let person = bodies.secondBody.node as! Person
            person.edgeHitCount += 1
            if person.edgeHitCount > 1 {
                self.levelNode.pedScore += 1
                person.removeFromParent()
            }
        }
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.currentScreen == .levelSelect {
            // Check if tap on level
            if let location = touches.first?.location(in: self) {
                let node = self.atPoint(location)
                if node.alpha < 1.0 {
                    // Disabled node, we haven't gotten unlocked this level yet
                    return
                }
                if let nodeName = node.name {
                    if(nodeName == "arrowUp" || nodeName == "arrowDown"){
                        playSound(self.buttonSound)
                        if node.name == "arrowUp" {
                            currentEpisode += 1;
                        }else{
                            currentEpisode -= 1;
                        }
                        self.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run({
                            self.showLevelSelectScreen()
                        })]))
                    } else if nodeName == "sound"{
                        sound = !sound
                        let n = node as! SKSpriteNode
                        n.texture = SKTexture(image: ImageManager.imageForSoundIcon(soundOn: self.sound))
                        
                    } else if nodeName == "lifeSymbol" || nodeName == "lifeNumLabel"{
                        self.livesManagementNode.show()
                        
                    }else{
                        let currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
                        let atEpisode = (currentLevel - 1) / LEVELS_PER_EPISODE
                        if UserDefaults.standard.integer(forKey: "lives") > 0 || maxLifeForEpisode(atEpisode) == 0 {
                            playSound(self.buttonSound)
                            if nodeName.components(separatedBy: "-").count > 1{
                                let levelNum: Int = Int(nodeName.components(separatedBy: "-")[1])! + currentEpisode * 20
                                loadLevel(levelNum: levelNum)
                            }
                        } else { // no lives
                            playSound(blockSound)
                            noLifeNode.show()
                        }
                    }
                }
            }
        } else if self.currentScreen == .levelIntro {
            // Tap on the intro screen immediately goes to play screen
            playSound(self.buttonSound)
            self.levelNode.transitionToPlay()
        } else if self.currentScreen == .levelPlay {
            self.touchedNode = nil
            if let initialTouchLocation = touches.first?.location(in: self) {
                let nodes = self.nodes(at: initialTouchLocation)
                for node in nodes{
                    if node.name == "path_follower" {
                        self.touchedNode = node
                    }
                    if node.name == "garbage" {
                        node.isHidden = true
                        self.levelNode.extraScore += 1
                    }
                }
            }
            
        } else if self.currentScreen == .help {
            self.levelNode.toggleLevelInfo()
        } else if self.currentScreen == .gameOver {
            // Go back to the level select screen
            self.levelNode.removeFromParent()
            self.levelNode = nil
            self.gameOverNode.hide()
            playSound(self.buttonSound)
            self.showLevelSelectScreen()
        } else if self.currentScreen == .noLife {
            noLifeNode.hide()
            self.showLevelSelectScreen()
        } else if self.currentScreen == .episodeHelp {
            self.episodeHelpNode.hide()
            self.showLevelSelectScreen()
        } else if self.currentScreen == .lifeManagement {
            if let location = touches.first?.location(in: self) {
                let node = self.atPoint(location)
                if node.name == "arrowRight" {
                    self.livesManagementNode.pageNum += 1
                }else if node.name == "arrowLeft" {
                    self.livesManagementNode.pageNum -= 1
                }
            }
        } else if self.currentScreen == .askFriends {
            if let location = touches.first?.location(in: self) {
                let node = self.atPoint(location)
                if node.name == "arrowRight" {
                    self.askFriendsNode.pageNum += 1
                }else if node.name == "arrowLeft" {
                    self.askFriendsNode.pageNum -= 1
                }else{
                    let spacing = self.frame.maxY/CGFloat(FRIENDS_PER_PAGE + 1)
                    var index = FRIENDS_PER_PAGE * self.askFriendsNode.pageNum + Int(floor(location.y)) / Int(floor(spacing))
                    index = FRIENDS_PER_PAGE - index
                    if index < facebookFriends.count{
                        let friend = facebookFriends[index]
                        print(friend.name)
                        sendLifeRequest(index: index)
                    }
                    
                    if index == facebookFriends.count{
                        inviteFriends()
                        self.askFriendsNode.hide()
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.currentScreen == .levelPlay {
            if let pathFollower = self.touchedNode as? PathFollower {
                pathFollower.slowDown()
                playSound(buttonSound)
            }
        }
    }
    
    // MARK: - Swipe handling
    
    func handlePanFrom(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            break
        case .changed:
            break
        case .ended:
            let panAngle = self.getPanAngle(gesture)
            if let car = self.touchedNode as? Car {
                let spriteAngle = self.getSpriteAngle(car)
                if self.isAngleWithinRangeOfAngle(panAngle, spriteAngle: spriteAngle, delta: 30.0) {
                    // Speed up
                    car.speedUp()
                    playSound(slideSound)
                    
                }
                
                let oppAngle = self.getOppositeAngle(spriteAngle)
                
                if self.isAngleWithinRangeOfAngle(panAngle, spriteAngle: oppAngle, delta: 30.0) {
                    // Slow down
                    car.slowDown()
                    playSound(buttonSound)
                }
            } else if currentScreen == .levelSelect{
                if self.isAngleWithinRangeOfAngle(panAngle, spriteAngle: 0, delta: 30.0) {
                    // slided up
                    if currentEpisode < MAX_EPISODE{
                        playSound(slideSound)
                        currentEpisode += 1;
                        self.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run({
                            self.showLevelSelectScreen()
                        })]))
                    }
                } else if self.isAngleWithinRangeOfAngle(panAngle, spriteAngle: 180, delta: 30.0) {
                    if currentEpisode > 0{
                        playSound(slideSound)
                        currentEpisode -= 1;
                        self.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run({
                            self.showLevelSelectScreen()
                        })]))
                    }
                }
            }
        default:
            break
        }
    }
    
    fileprivate func getOppositeAngle(_ angle: CGFloat) -> CGFloat {
        var oppAngle = angle + 180
        if oppAngle > 359 {
            oppAngle -= 360
        }
        return oppAngle
    }
    
    fileprivate func getPanAngle(_ gesture: UIPanGestureRecognizer) -> CGFloat {
        let velocity = gesture.velocity(in: gesture.view?.superview)
        var panAngle = radToDeg(atan2(velocity.y, velocity.x))
        
        // Rotate cc 90
        panAngle = 270.0 - panAngle
        
        // Make right side negative to match SpriteKit
        if panAngle >= 180 {
            panAngle = panAngle - 360
        }
        
        // Angle goes from 0-359
        if panAngle < 0 {
            panAngle += 360
        }
        
        return panAngle
    }
    
    fileprivate func getSpriteAngle(_ sprite: SKSpriteNode) -> CGFloat {
        // Convert from SpriteKit to 0-359
        var spriteAngle = radToDeg(sprite.zRotation)
        if spriteAngle < 0 {
            spriteAngle += 360
        }
        return spriteAngle
    }
    
    fileprivate func isAngleWithinRangeOfAngle(_ panAngle: CGFloat, spriteAngle: CGFloat, delta: CGFloat) -> Bool {
        var min = spriteAngle - delta
        if min < 0 {
            min += 360
        }
        
        var max = spriteAngle + delta
        if max > 359 {
            max -= 360
        }
        
        var inSameDirection = false
        if min < max {
            inSameDirection = panAngle > min && panAngle < max
        } else {
            // Min overflowed to bigger numbers. For example, if angle is 10,
            // max is 40 and min is 340.
            inSameDirection = panAngle < max || panAngle > min
        }
        return inSameDirection
    }
    
    fileprivate func radToDeg(_ radians: CGFloat) -> CGFloat {
        return radians * CGFloat((180.0 / M_PI))
    }
    
    // MARK: - Update function
    
    override func update(_ currentTime: TimeInterval) {
        if UserDefaults.standard.integer(forKey: "lives") < 0 {
            UserDefaults.standard.set(0, forKey: "lives")
            UserDefaults.standard.set(0, forKey: "subtractTime")
        }
        if self.currentScreen == .levelPlay {
            var timeSinceLastUpdate = currentTime - self.lastUpdateTime
            self.lastUpdateTime = currentTime
            if timeSinceLastUpdate > 1 {
                timeSinceLastUpdate = 1.0 / 60.0
                self.lastUpdateTime = currentTime
            }
            
            if self.shouldUpdate {
                if let _ = levelNode{
                    levelNode.update(timeSinceLastUpdate)
                }
            }
        }
        updateTime()
    }
    
    // MARK: - Timer
    
    func updateTime() {
        let currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
        
        let atEpisode = (currentLevel - 1) / LEVELS_PER_EPISODE
        
        if UserDefaults.standard.integer(forKey: "lives") == maxLifeForEpisode(atEpisode){
            self.minutesLeft = 0
            self.secondsLeft = 0
        } else {
            var totalSec = Int(Date().timeIntervalSince(UserDefaults.standard.value(forKey: "time") as! Date))
            totalSec -= UserDefaults.standard.integer(forKey: "subtractTime")
            while totalSec > TIME_TO_LIFE * 60 {
                totalSec -= TIME_TO_LIFE * 60
                UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "subtractTime") + TIME_TO_LIFE * 60, forKey: "subtractTime")
                if UserDefaults.standard.integer(forKey: "lives") < maxLifeForEpisode(atEpisode){
                    UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "lives") + 1, forKey: "lives")
                    self.lifeNumLabel.text = String(UserDefaults.standard.integer(forKey: "lives"))
                }
            }
            self.minutesLeft = TIME_TO_LIFE - (totalSec / 60) - 1
            self.secondsLeft = 59 - abs(totalSec % 60)
            if secondsLeft > 60{
                print("total sec")
                print(secondsLeft)
                print(totalSec % 60)
            }
        }
        
        if secondsLeft == 0 && minutesLeft == 0 && UserDefaults.standard.integer(forKey: "lives") < maxLifeForEpisode(atEpisode){
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "lives") + 1, forKey: "lives")
            UserDefaults.standard.setValue(Date(), forKey: "time")
            UserDefaults.standard.set(0, forKey: "subtractTime")
            self.lifeNumLabel.text = String(UserDefaults.standard.integer(forKey: "lives"))
        }
        if UserDefaults.standard.integer(forKey: "lives") >= maxLifeForEpisode(atEpisode) {
            UserDefaults.standard.set(maxLifeForEpisode(atEpisode), forKey: "lives")
            self.timerLabel.isHidden = true
            self.lifeNumLabel.text = String(maxLifeForEpisode(atEpisode))
            
        } else {
            if atEpisode != 0 && currentEpisode < MAX_EPISODE{
                //timerLabel.isHidden = false
            }
        }
        updateTimerText()
        if self.currentScreen == .noLife {
            noLifeNode.updateTimerText()
        }
    }
    
    func updateTimerText(){
        var first0 = ""
        var second0 = ""
        if minutesLeft < 10{
            first0 = "0"
        }
        if secondsLeft < 10{
            second0 = "0"
        }
        timerLabel.text = first0 + String(minutesLeft) + ":" + second0 + String(secondsLeft)
    }
    
    // MARK: - Sound
    
    func playSound(_ sound: SKAction) {
        if self.sound{
            run(sound)
        }
    }
    
    // MARK: - Episodes and Levels
    
    func loadEpisodeHelp(_ episode: Int) {
        UserDefaults.standard.set(maxLifeForEpisode(episode), forKey: "lives")
        self.episodeHelpNode.show(episodeTutorial(episode))
    }
    func loadLevel(levelNum: Int) {
        if let level = LevelManager.loadLevel(levelNum, gs: self) {
            self.levelNode = level
            self.addChild(level)
            level.setup()
        }
    }
    
    //MARK: Facebook
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("invitation made")
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print("error made")
    }
    
    public func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print("invitation made")
    }
    
    func inviteFriends() {
        let content = FBSDKAppInviteContent()
        content.appLinkURL = NSURL(string: APP_LINK_URL) as URL!
        content.appInvitePreviewImageURL = NSURL(string: APP_INVITE_IMAGE_URL) as URL!
        FBSDKAppInviteDialog.show(with: content, delegate: self)
    }
    
    // sends a life request to friend in index index of the facebookFriends array
    func sendLifeRequest(index: Int){
        let content = FBSDKGameRequestContent()
        content.message = "Please help me with 5 lives"
        content.data = "asked-5lives"
        let id = facebookFriends[index].id as NSString
        var to: [NSString] = [NSString]()
        to.append(id)
        content.recipients = to
        content.title = "Please help me with 5 lives"
        print(content.description)
        FBSDKGameRequestDialog.show(with: content, delegate: self)
    }
    
    func sendLives(requestIndex: Int){
        let content = FBSDKGameRequestContent()
        let name = requestsArray[requestIndex].from as String
        content.message = name + " sent you 5 lives"
        content.data = "sent-5lives"
        let id = requestsArray[requestIndex].fromID as NSString
        var to: [NSString] = [NSString]()
        to.append(id)
        content.recipients = to
        content.title = "You just recieved 5 lives"
        print(content.description)
        FBSDKGameRequestDialog.show(with: content, delegate: self)
        self.deleteRequest(id: requestsArray[requestIndex].id)
        requestsArray.remove(at: requestIndex)
    }
    
    func gameRequestDialog(_ gameRequestDialog: FBSDKGameRequestDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print("request sent")
        //print(results)
    }
    
    func gameRequestDialog(_ gameRequestDialog: FBSDKGameRequestDialog!, didFailWithError error: Error!) {
        print("error sending request")
        print(error)
    }
    
    func gameRequestDialogDidCancel(_ gameRequestDialog: FBSDKGameRequestDialog!) {
        print("request canceled")
    }
    
    func deleteRequest(id: String) {
        FBSDKGraphRequest(graphPath: id, parameters: nil, httpMethod: "DELETE").start(completionHandler: { (connect, req, requestErr) -> Void in
            print("----------Request Delete-----------")
            print(requestErr)
            print(req)
        })
    }
    
    func rateMe(){
        var alert = UIAlertController(title: "Having fun?", message: "Rate Crazy Traffic Rush>", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Rate now", style: UIAlertActionStyle.default, handler: { alertAction in
            UIApplication.shared.openURL(NSURL(string : "https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1155170268&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=7") as! URL)
            UserDefaults.standard.set(true, forKey: "neverRate")
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No Thanks", style: UIAlertActionStyle.default, handler: { alertAction in
            UserDefaults.standard.set(true, forKey: "neverRate")
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Maybe Later", style: UIAlertActionStyle.default, handler: { alertAction in
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "rateMe") + 2, forKey: "rateMe")
            alert.dismiss(animated: true, completion: nil)
        }))
        if(UIApplication.shared.keyWindow != nil && UIApplication.shared.keyWindow!.rootViewController != nil){
            let currentViewController:UIViewController=UIApplication.shared.keyWindow!.rootViewController!
            currentViewController.present(alert, animated: true, completion: nil)
        }

    }
    
}
