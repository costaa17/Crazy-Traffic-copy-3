//
//  Level.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/22/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit
import Firebase


class LevelNode: SKSpriteNode {
    let rows: Int
    let cols: Int
    let levelNum: Int
    let goal: Int
    let pedGoal: Int
    let carGoal: Int
    let backgroundColor: UIColor
    let speedMult: CGFloat
    let intervalMult: Float
    
    var hasTutorial: Bool {
        return tutorialText.characters.count > 0
    }
    
    let tutorialText: String
    let paths: [Path]
    var hasGarbage = true
    var garbage: [Garbage]
    var garbageTimer = CFTimeInterval(arc4random_uniform(UInt32(GARBAGE_INTERVAL_UPPER_BOUND)))
    //var garbageSpriteNode = SKSpriteNode()
    
    var view: SKSpriteNode! = nil
    var ground: SKSpriteNode! = nil
    var scoreLabel: ASAttributedLabelNode! = nil
    var pedScoreLabel: ASAttributedLabelNode! = nil
    var carScoreLabel: ASAttributedLabelNode! = nil
    var goalAchievedLabel: ASAttributedLabelNode! = nil
    var goalReached = false
    
    var carScore: Int = 0 {
        didSet {
            if carScore > 0{
                if let scene = self.parent as? GameScene {
                    scene.playSound(scene.scoreSound)
                }
            }
            if let carScoreLabel = self.carScoreLabel{
                let text = "\(carScore)"
                //self.pedScoreLabel = ASAttributedLabelNode(size: self.frame.size)
                let textFontAttributes: NSDictionary = [NSFontAttributeName : UIFont(name: FONT_NAME, size: FONT_SIZE_L)!, NSForegroundColorAttributeName : UIColor.white, NSStrokeColorAttributeName: UIColor.black, NSStrokeWidthAttributeName: -2,]
                let attrString = NSAttributedString(
                    string: text,
                    attributes: textFontAttributes as?[String : AnyObject])
                carScoreLabel.attributedString = attrString
                carScoreLabel.position = CGPoint(x: self.frame.midX * 3 - FONT_SIZE_L/2, y: self.frame.maxY - FONT_SIZE_L * 1.5)
                var temp = carScore
                while temp/10 >= 1{
                    temp /= 10
                    carScoreLabel.position.x -= FONT_SIZE_L/2
                }
                carScoreLabel.zPosition = Z_SCORE_LABEL
            }
            //scoreLabel.removeFromParent()
            let text = "\(carScore + pedScore + extraScore)"
            //self.scoreLabel = ASAttributedLabelNode(size: self.frame.size)
            let textFontAttributes: NSDictionary = [NSFontAttributeName : UIFont(name: FONT_NAME, size: FONT_SIZE_L)!, NSForegroundColorAttributeName : UIColor.white, NSStrokeColorAttributeName: UIColor.black, NSStrokeWidthAttributeName: -2,]
            let attrString = NSAttributedString(
                string: text,
                attributes: textFontAttributes as?[String : AnyObject])
            self.scoreLabel.attributedString = attrString
            self.scoreLabel.position = CGPoint(x: self.frame.midX * 3 - FONT_SIZE_L/2, y: self.frame.maxY - FONT_SIZE_M)
            var temp = carScore + pedScore + extraScore
            while temp/10 >= 1{
                temp /= 10
                scoreLabel.position.x -= FONT_SIZE_L/2
            }
            self.scoreLabel.zPosition = Z_SCORE_LABEL
            //self.addChild(scoreLabel)
            self.checkIfGoalMet()
        }
    }
    
    var pedScore: Int = 0 {
        didSet {
            if pedScore > 0{
                if let scene = self.parent as? GameScene {
                    scene.playSound(scene.scoreSound)
                }
            }
            if let pedScoreLabel = self.pedScoreLabel{
                let text = "\(pedScore)"
                //self.pedScoreLabel = ASAttributedLabelNode(size: self.frame.size)
                let textFontAttributes: NSDictionary = [NSFontAttributeName : UIFont(name: FONT_NAME, size: FONT_SIZE_L)!, NSForegroundColorAttributeName : UIColor.white, NSStrokeColorAttributeName: UIColor.black, NSStrokeWidthAttributeName: -2,]
                let attrString = NSAttributedString(
                    string: text,
                    attributes: textFontAttributes as?[String : AnyObject])
                pedScoreLabel.attributedString = attrString
                pedScoreLabel.position = CGPoint(x: self.frame.midX * 3 - FONT_SIZE_L/2, y: self.frame.maxY - FONT_SIZE_L * 1.5)
                var temp = pedScore
                while temp/10 >= 1{
                    temp /= 10
                    pedScoreLabel.position.x -= FONT_SIZE_L/2
                }
                pedScoreLabel.zPosition = Z_SCORE_LABEL
            }
            let text = "\(carScore + pedScore + extraScore)"
            //self.scoreLabel = ASAttributedLabelNode(size: self.frame.size)
            let textFontAttributes: NSDictionary = [NSFontAttributeName : UIFont(name: FONT_NAME, size: FONT_SIZE_L)!, NSForegroundColorAttributeName : UIColor.white, NSStrokeColorAttributeName: UIColor.black, NSStrokeWidthAttributeName: -2,]
            let attrString = NSAttributedString(
                string: text,
                attributes: textFontAttributes as?[String : AnyObject])
            self.scoreLabel.attributedString = attrString
            self.scoreLabel.position = CGPoint(x: self.frame.midX * 3 - FONT_SIZE_L/2, y: self.frame.maxY - FONT_SIZE_M)
            var temp = carScore + pedScore + extraScore
            while temp/10 >= 1{
                temp /= 10
                scoreLabel.position.x -= FONT_SIZE_L/2
            }
            self.scoreLabel.zPosition = Z_SCORE_LABEL
            self.checkIfGoalMet()
        }
    }
    
    var extraScore: Int = 0 {
        didSet {
            if extraScore > 0{
                if let scene = self.parent as? GameScene {
                    scene.playSound(scene.scoreSound)
                }
            }
            
            let text = "\(carScore + pedScore + extraScore)"
            //self.scoreLabel = ASAttributedLabelNode(size: self.frame.size)
            let textFontAttributes: NSDictionary = [NSFontAttributeName : UIFont(name: FONT_NAME, size: FONT_SIZE_L)!, NSForegroundColorAttributeName : UIColor.white, NSStrokeColorAttributeName: UIColor.black, NSStrokeWidthAttributeName: -2,]
            let attrString = NSAttributedString(
                string: text,
                attributes: textFontAttributes as?[String : AnyObject])
            self.scoreLabel.attributedString = attrString
            self.scoreLabel.position = CGPoint(x: self.frame.midX * 3 - FONT_SIZE_L/2, y: self.frame.maxY - FONT_SIZE_M)
            var temp = carScore + pedScore + extraScore
            while temp/10 >= 1{
                temp /= 10
                scoreLabel.position.x -= FONT_SIZE_L/2
            }
            self.scoreLabel.zPosition = Z_SCORE_LABEL
            self.checkIfGoalMet()
        }
    }
    
    
    var score: Int {
        get {
            return carScore + pedScore + extraScore
        }
    }
    
    var nextCarID: Int = 1
    
    init(data: [String:AnyObject], size: CGSize) {
        print(data["garbage"])
        self.rows = data["rows"] as! Int
        self.cols = data["cols"] as! Int
        self.levelNum = data["levelNum"] as! Int
        self.goal = data["goal"] as! Int
        self.pedGoal = data["pedGoal"] as! Int
        self.carGoal = data["carGoal"] as! Int
        self.backgroundColor = UIColor(hex: data["backgroundColor"] as! String)
        self.tutorialText = data["tutorialText"] as! String
        self.speedMult = data["speedMult"] as! CGFloat
        self.intervalMult = data["intervalMult"] as! Float
        self.paths = data["paths"] as! [Path]
        self.garbage = data["garbage"] as! [Garbage]
            /*for o in g {
                self.garbage.append(o as! CGPoint)
            }*/
        // Outset screen size slightly to prevent seeing what's underneath
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let bounds = rect.insetBy(dx: -1, dy: -1)
        super.init(texture: nil, color: UIColor.clear, size: bounds.size)
        self.anchorPoint = CGPoint.zero
        self.position = CGPoint(x: -1, y: -1)
        if garbage.isEmpty {
            hasGarbage = false
        }
        /*garbageSpriteNode = SKSpriteNode(imageNamed: "PlasticBag")
        garbageSpriteNode.xScale = 0.35
        garbageSpriteNode.yScale = 0.35
        garbageSpriteNode.name = "garbage"
        garbageSpriteNode.zPosition = Z_PATH_FOLLOWER
        garbageSpriteNode.isHidden = true
        addChild(garbageSpriteNode)*/
        let level = UserDefaults.standard.integer(forKey: "currentLevel")
        let temp = "level" + String(level)
        let episode = (level - 1) / LEVELS_PER_EPISODE
        let temp2 = "episode" + String(episode)
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "played") + 1, forKey: "played")
        if UserDefaults.standard.integer(forKey: "me") != 1{
            FIRAnalytics.setUserPropertyString(String(UserDefaults.standard.integer(forKey: "played")), forName: "played")
            GameAnalytics.addProgressionEvent(with: GAProgressionStatusStart, progression01:temp2, progression02: temp, progression03:" ")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Swift requires this initializer to exist
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup code
    
    func setup() {
        if let scene = self.parent as? GameScene {
            scene.currentScreen = Screen.levelIntro
            self.setupGroundNode()
            self.setupView()
            self.setupScoreNodes()
            self.setupLevelInfoNodes()
            self.activatePhysics()
            self.transitionToPlayWithDelay(4.0)
            if hasGarbage {
                setupGarbage()
            }
        }
        
    }
    
    fileprivate func setupScoreNodes() {
        self.scoreLabel = ASAttributedLabelNode(size: self.frame.size)
        let textFontAttributes: NSDictionary = [NSFontAttributeName : UIFont(name: FONT_NAME, size: FONT_SIZE_L)!, NSForegroundColorAttributeName : UIColor.white, NSStrokeColorAttributeName: UIColor.black, NSStrokeWidthAttributeName: -2,]
        let attrString = NSAttributedString(
            string: "a",
            attributes: textFontAttributes as?[String : AnyObject])
        self.scoreLabel.attributedString = attrString
        
        self.carScore = 0
        self.scoreLabel.position = CGPoint(x: self.frame.midX * 3 - FONT_SIZE_L/2, y: self.frame.maxY - FONT_SIZE_M)
        self.scoreLabel.zPosition = Z_SCORE_LABEL
        self.view.addChild(self.scoreLabel)
        
        if self.pedGoal > 0 {
            self.pedScoreLabel = ASAttributedLabelNode(size: self.frame.size)
            let textFontAttributes: NSDictionary = [NSFontAttributeName : UIFont(name: FONT_NAME, size: FONT_SIZE_L)!, NSForegroundColorAttributeName : UIColor.white, NSStrokeColorAttributeName: UIColor.black, NSStrokeWidthAttributeName: -2,]
            let attrString = NSAttributedString(
                string: "",
                attributes: textFontAttributes as?[String : AnyObject])
            self.pedScoreLabel.attributedString = attrString
            self.pedScore = 0
            self.pedScoreLabel.position = CGPoint(x: self.frame.midX * 3 - FONT_SIZE_L/2, y: self.frame.maxY - FONT_SIZE_L * 1.5)
            self.pedScoreLabel.zPosition = Z_SCORE_LABEL
            self.view.addChild(self.pedScoreLabel)
        }
        
        if self.carGoal > 0 {
            self.carScoreLabel = ASAttributedLabelNode(size: self.frame.size)
            let textFontAttributes: NSDictionary = [NSFontAttributeName : UIFont(name: FONT_NAME, size: FONT_SIZE_L)!, NSForegroundColorAttributeName : UIColor.white, NSStrokeColorAttributeName: UIColor.black, NSStrokeWidthAttributeName: -2,]
            let attrString = NSAttributedString(
                string: "",
                attributes: textFontAttributes as?[String : AnyObject])
            self.carScoreLabel.attributedString = attrString
            self.carScore = 0
            self.carScoreLabel.position = CGPoint(x: self.frame.midX * 3 - FONT_SIZE_L/2, y: self.frame.maxY - FONT_SIZE_L * 1.5)
            if self.pedGoal > 0{
                self.carScoreLabel.position.y -= FONT_SIZE_L * 1.5
            }
            self.carScoreLabel.zPosition = Z_SCORE_LABEL
            self.view.addChild(self.carScoreLabel)
        }
        
        let highScoreNode = ASAttributedLabelNode(size: self.frame.size)
        if let highScores = UserDefaults.standard.dictionary(forKey: "highScores") as? [String: [String: Int]], let levelScore = highScores["level\(self.levelNum)"] {
            let carScore = levelScore["car"]!
            let pedScore = levelScore["ped"]!
            let text = "High: \(carScore + pedScore)"
            let textFontAttributes: NSDictionary = [NSFontAttributeName : UIFont(name: FONT_NAME, size: FONT_SIZE_L)!, NSForegroundColorAttributeName : UIColor.white, NSStrokeColorAttributeName: UIColor.black, NSStrokeWidthAttributeName: -2,]
            let attrString = NSAttributedString(
                string: text,
                attributes: textFontAttributes as?[String : AnyObject])
            highScoreNode.attributedString = attrString
            highScoreNode.position = CGPoint(x: self.frame.midX + 10, y: self.frame.maxY - FONT_SIZE_M)
            highScoreNode.zPosition = Z_SCORE_LABEL
            self.view.addChild(highScoreNode)
        }
        
        self.goalAchievedLabel = ASAttributedLabelNode(size: self.frame.size)
        let textFontAttributes2: NSDictionary = [NSFontAttributeName : UIFont(name: FONT_NAME, size: FONT_SIZE_L)!, NSForegroundColorAttributeName : UIColor.white, NSStrokeColorAttributeName: UIColor.black, NSStrokeWidthAttributeName: -2,]
        let attrString2 = NSAttributedString(
            string: "Good Job! You reached the goal!",
            attributes: textFontAttributes2 as?[String : AnyObject])
        self.goalAchievedLabel.attributedString = attrString2
        self.goalAchievedLabel.position = CGPoint(x: self.frame.midX + goalAchievedLabel.width / 5, y: self.frame.midY)
        self.goalAchievedLabel.zPosition = Z_GAMEOVER_VIEW
        self.view.addChild(self.goalAchievedLabel)
        self.goalAchievedLabel.isHidden = true
    }
    
    fileprivate func setupLevelInfoNodes(){
        let textFontAttributes: NSDictionary = [NSFontAttributeName : UIFont(name: FONT_NAME, size: FONT_SIZE_L)!, NSForegroundColorAttributeName : UIColor.white, NSStrokeColorAttributeName: UIColor.black, NSStrokeWidthAttributeName: -2,]
        let attrString = NSAttributedString(
            string: "?",
            attributes: textFontAttributes as?[String : AnyObject])
        let help = ASAttributedLabelNode(size: CGSize(width: 60, height: 60))
        help.attributedString = attrString
        //let toggleLevelInfoButton = AGSpriteButton(color: self.backgroundColor, andSize: CGSize(width: 60, height: 60))
        let toggleLevelInfoButton = AGSpriteButton(texture: help.texture, andSize: CGSize(width: 60, height: 60))
        toggleLevelInfoButton?.position = CGPoint(x: 35, y: 25)
        toggleLevelInfoButton?.name = "help"
        toggleLevelInfoButton?.zPosition = Z_PATH_FOLLOWER
        toggleLevelInfoButton?.addTarget(self, selector:#selector(LevelNode.toggleLevelInfo), with: nil, for:AGButtonControlEvent.touchUpInside)
        //toggleLevelInfoButton.setLabelWithText("?", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), withColor: UIColor.whiteColor())
        self.view.addChild(toggleLevelInfoButton!)
        
        let exitButton = AGSpriteButton(color: LEVEL_SELECT_COLOR, andSize: CGSize(width: 80, height: 40))
        exitButton?.position = CGPoint(x: self.frame.width/2, y: 70)
        exitButton?.name = "exit"
        exitButton?.alpha = 0.0
        exitButton?.zPosition = Z_LEVEL_INFO_ITEM
        exitButton?.addTarget(self, selector:#selector(LevelNode.exitLevel), with: nil, for:AGButtonControlEvent.touchUpInside)
        exitButton?.setLabelWithText("Exit", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
        self.view.addChild(exitButton!)
        
    }
    func setupGarbage() {
        /*for i in 0..<garbage.count{
            let o = garbage[i]
            garbage[i] = self.pointForVertex(PathVertex(row: Int(o.x), col: Int(o.y)))
            
        }*/
    }
    
    fileprivate func setupGroundNode() {
        let groundSize = CGSize(width: self.size.width, height: 1)
        self.ground = SKSpriteNode(color: UIColor.black, size: groundSize)
        self.addChild(self.ground)
        self.ground.anchorPoint = CGPoint(x: 0, y: 0)
        self.ground.position = CGPoint(x: 0, y: 0) // Position just under the screen
    }
    
    fileprivate func setupView() {
        self.view = SKSpriteNode(color: self.backgroundColor, size: self.size)
        self.addChild(self.view)
        self.view.zPosition = Z_LEVEL_VIEW
        self.view.anchorPoint = CGPoint(x: 0, y: 0)
        self.view.position = CGPoint(x: 0, y: size.height) // Position just above the screen
        
        let center = CGPoint(x: self.view.size.width/2, y: self.view.size.height/2)
        
        let levelInfoBackground = SKSpriteNode(color: self.backgroundColor, size: self.size)
        levelInfoBackground.name = "level_info"
        self.view.addChild(levelInfoBackground)
        levelInfoBackground.zPosition = Z_LEVEL_INFO_BACKGROUND
        levelInfoBackground.anchorPoint = CGPoint.zero
        levelInfoBackground.position = CGPoint.zero
        
        let levelNumNode = SKLabelNode()
        levelNumNode.name = "level_info"
        levelNumNode.fontName = FONT_NAME
        levelNumNode.fontSize = FONT_SIZE_XL
        levelNumNode.fontColor = TUTORIAL_TEXT_COLOR
        levelNumNode.text = "Level \(self.levelNum)"
        levelNumNode.position = CGPoint(x: center.x, y: center.y + 80)
        levelNumNode.zPosition = Z_LEVEL_INFO_ITEM
        self.view.addChild(levelNumNode)
        
        let levelGoalNode = SKLabelNode()
        levelGoalNode.name = "level_info"
        levelGoalNode.fontName = FONT_NAME
        levelGoalNode.fontSize = FONT_SIZE_L
        levelGoalNode.fontColor = TUTORIAL_TEXT_COLOR
        levelGoalNode.text = "Goal:  \(self.goal) points"
        levelGoalNode.zPosition = Z_LEVEL_INFO_ITEM
        if self.pedGoal > 0 {
            levelGoalNode.text = levelGoalNode.text! + " and at least \(self.pedGoal) pedestrians"
        }
        if self.carGoal > 0 {
            levelGoalNode.text = levelGoalNode.text! + " and at least \(self.carGoal) cars"
        }
        levelGoalNode.position = CGPoint(x: center.x, y: center.y + 40)
        self.view.addChild(levelGoalNode)
        //tutorialTextNode.name = "level_info"
        //tutorialTextNode.text = self.tutorialText
        //tutorialTextNode.position = CGPoint(x: center.x, y: center.y - 30)
        //tutorialTextNode.zPosition = Z_LEVEL_INFO_ITEM
        //self.view.addChild(tutorialTextNode)
        let text: String = self.tutorialText
        let labelWidth = 400
        let pos = CGPoint(x: self.frame.midX, y: self.frame.midY)
        let fontName = FONT_NAME
        let fontSize = FONT_SIZE_M
        let fontColor = TUTORIAL_TEXT_COLOR
        
        let tutorialTextNode = SKMultilineLabel(text: text, labelWidth: labelWidth, pos: pos, fontName: fontName, fontSize: fontSize, fontColor: fontColor)
        
        tutorialTextNode.name = "level_info"
        tutorialTextNode.zPosition = Z_LEVEL_INFO_ITEM
        self.view.addChild(tutorialTextNode)
        // First pass add all paths that are not walking paths
        for path in self.paths {
            if path.type != Path.PathType.Road {
                continue
            }
            let shapeNode = SKShapeNode(path: path.CGPath(self))
            shapeNode.name = "path_road"
            shapeNode.strokeColor = ROAD_COLOR
            shapeNode.lineWidth = 50
            shapeNode.isAntialiased = true
            shapeNode.alpha = 0.0
            shapeNode.zPosition = Z_ROAD_PATH
            self.view.addChild(shapeNode)
        }
        // Second pass add all walking paths and crosswalks
        //var arrayOfCrossWalks: [(CGPoint, CGPoint, Bool)] = []
        for path in self.paths {
            if path.type != Path.PathType.Walk {
                continue
            }
            let shapeNode = SKShapeNode(path: path.CGPath(self))
            shapeNode.name = "path_walk"
            shapeNode.zPosition = Z_WALK_PATH
            shapeNode.strokeColor = WALK_COLOR
            shapeNode.lineWidth = 20
            shapeNode.alpha = 0.0
            self.view.addChild(shapeNode)
            
            //self.addCrossWalkToPath(path, array: &arrayOfCrossWalks)
        }
        
        for path in self.paths {
            if path.type != Path.PathType.Rail {
                continue
            }
            let dashedPath = path.CGPath(self).copy(dashingWithPhase: 0, lengths: [5.0,5.0])
            let dashedNode = SKShapeNode(path: dashedPath)
            dashedNode.strokeColor = WALK_COLOR
            dashedNode.lineWidth = 20
            dashedNode.name = "path_rail"
            dashedNode.zPosition = Z_ROAD_PATH
            dashedNode.alpha = 0.0
            self.view.addChild(dashedNode)
            
            let outPath = path.CGPath(self).copy(strokingWithWidth: 10, lineCap: CGLineCap.round, lineJoin: CGLineJoin.round, miterLimit: 0)
            let outNode = SKShapeNode(path: outPath)
            outNode.strokeColor = ROAD_COLOR
            outNode.lineWidth = 2
            outNode.name = "path_rail"
            outNode.zPosition = Z_ROAD_PATH + 1
            outNode.alpha = 0.0
            self.view.addChild(outNode)
            
            
            //self.addCrossWalkToPath(path, array: &arrayOfCrossWalks)
        }
        //Third pass add crosswalk - on top
        for path in self.paths {
            if path.type != Path.PathType.CrossWalk {
                continue
            }
            let pattern: [CGFloat] = [7.0, 7.0]
            let dashed = CGPath(__byDashing: path.CGPath(self), transform: nil, phase: 0, lengths: pattern, count: 2)
            let shapeNode = SKShapeNode(path: dashed!)
            shapeNode.name = "path_cross"
            shapeNode.strokeColor = ROAD_COLOR
            shapeNode.lineWidth = 30
            shapeNode.alpha = 1.0
            shapeNode.zPosition = Z_CROSSWALK
            self.view.addChild(shapeNode)
            
            //self.addCrossWalkToPath(path, array: &arrayOfCrossWalks)
        }
        //TODO: get crosswalks to work
        /*var i = 0
         var didCombine = false
         // first pass check if there is any repeated crosswalk
         while i < arrayOfCrossWalks.count {
         for j in 0 ..< arrayOfCrossWalks.count {
         if i != j && j < arrayOfCrossWalks.count{
         let cw1 = arrayOfCrossWalks[i]
         let cw2 = arrayOfCrossWalks[j]
         if cw1.2 == false && cw2.2 == false {
         //same crosswalk
         if (isSame(cw1.0, cp2: cw2.0, e: 10) && isSame(cw1.1, cp2: cw2.1, e: 10)) || (isSame(cw1.1, cp2: cw2.0, e: 10) && isSame(cw1.0, cp2: cw2.1, e: 10)) {//|| (isSame(cw1.1, cp2: cw2.0, e: 8) && isSame(cw1.0, cp2: cw2.1, e: 8))){
         /*arrayOfCrossWalks.append((cw1.0, cw1.1, false))
         arrayOfCrossWalks[i].2 = true
         arrayOfCrossWalks[j].2 = true*/
         arrayOfCrossWalks.removeAtIndex(j)
         print("should combine same crosswalk \(i) + \(j)")
         }
         }
         }
         }
         i += 1
         }
         i = 0
         // second pass look for double streets - and combine crosswalks
         while i < arrayOfCrossWalks.count {
         for j in i + 1 ..< arrayOfCrossWalks.count {
         //if i != j {
         didCombine = false
         let cw1 = arrayOfCrossWalks[i]
         let cw2 = arrayOfCrossWalks[j]
         if cw1.2 == false && cw2.2 == false {
         
         // one point is the same
         if(isSame(cw1.0, cp2: cw2.1, e: 10)){
         arrayOfCrossWalks.append((cw1.1, cw2.0, false))
         didCombine = true
         } else if isSame(cw1.1, cp2: cw2.0, e: 10){
         arrayOfCrossWalks.append((cw1.0, cw2.1, false))
         didCombine = true
         }
         if inBetween(cw1, cw2: cw2) {
         arrayOfCrossWalks.append((CGPoint(x: min(cw1.0.x, cw1.1.x, cw2.0.x, cw2.1.x), y: min(cw1.0.y, cw1.1.y, cw2.0.y, cw2.1.y) ), CGPoint(x: max(cw1.0.x, cw1.1.x, cw2.0.x, cw2.1.x), y: max(cw1.0.y, cw1.1.y, cw2.0.y, cw2.1.y) ), false))
         didCombine = true
         }
         if didCombine == true {
         // print("should combine \(i) + \(j)")
         // Mark these crosswalks as combined
         arrayOfCrossWalks[i].2 = true
         arrayOfCrossWalks[j].2 = true
         print("should combine double street \(i) + \(j)")
         }
         }
         //}
         }
         
         let cw = arrayOfCrossWalks[i]
         if cw.2 == false {
         // Add this crosswalk
         //print("added crosswalk at \(i)")
         let crossWalk = UIBezierPath()
         crossWalk.moveToPoint(cw.0)
         crossWalk.addLineToPoint(cw.1)
         let pattern: [CGFloat] = [7.0, 7.0]
         let dashed = CGPathCreateCopyByDashingPath(crossWalk.CGPath, nil, 0, pattern, 2)
         let shapeNode = SKShapeNode(path: dashed!)
         shapeNode.name = "path_cross"
         shapeNode.strokeColor = ROAD_COLOR
         shapeNode.lineWidth = 30
         shapeNode.alpha = 1.0
         shapeNode.zPosition = Z_CROSSWALK
         self.view.addChild(shapeNode)
         }
         
         i += 1
         }*/
    }
    
    fileprivate func sameX(_ cp1: CGPoint, cp2: CGPoint, e: CGFloat) -> Bool {
        return abs(cp1.x - cp2.x) < e;
    }
    
    fileprivate func sameY(_ cp1: CGPoint, cp2: CGPoint, e: CGFloat) -> Bool {
        return abs(cp1.y - cp2.y) < e;
    }
    
    fileprivate func isInBetween(_ middle: CGFloat, cg1: CGFloat, cg2: CGFloat) -> Bool {
        return middle >= min(cg1, cg2) && middle <= max(cg1, cg2)
    }
    
    fileprivate func isSame(_ cp1: CGPoint, cp2: CGPoint, e: CGFloat) -> Bool{
        return sameX(cp1, cp2: cp2, e: e) && sameY(cp1, cp2: cp2, e: e)
    }
    fileprivate func inBetween(_ cw1: (CGPoint, CGPoint, Bool), cw2: (CGPoint, CGPoint, Bool)) -> Bool{
        var YinBetween = false
        var XinBetween = false
        //cw1 x in between cw2 xs
        if(isInBetween(cw1.0.x, cg1: cw2.0.x, cg2: cw2.1.x) || isInBetween(cw1.1.x, cg1: cw2.0.x, cg2: cw2.1.x)){
            XinBetween = true
        }
        
        //cw2 x in between cw1 xs
        if !XinBetween && (isInBetween(cw2.0.x, cg1: cw1.0.x, cg2: cw1.1.x) || isInBetween(cw2.1.x, cg1: cw1.0.x, cg2: cw1.1.x)){
            XinBetween = true
        }
        
        //cw1 y in between cw2 ys
        if(isInBetween(cw1.0.y, cg1: cw2.0.y, cg2: cw2.1.y) || isInBetween(cw1.1.y, cg1: cw2.0.y, cg2: cw2.1.y)){
            YinBetween = true
        }
        
        //cw2 y in between cw1 ys
        if !XinBetween && (isInBetween(cw2.0.y, cg1: cw1.0.y, cg2: cw1.1.y) || isInBetween(cw2.1.y, cg1: cw1.0.y, cg2: cw1.1.y)){
            YinBetween = true
        }
        
        return XinBetween && YinBetween
    }
    
    fileprivate func addCrossWalkToPath(_ path: Path, array: inout [(CGPoint, CGPoint, Bool)]) {
        // Check if this walk path intersects with any roads
        for path2 in self.paths {
            if path2.type == Path.PathType.Road {
                let walkPath = UIBezierPath(cgPath: path.CGPath(self))
                let roadPath = CGPath(__byStroking: path2.CGPath(self), transform: nil, lineWidth: calculatePathWidth(), lineCap: CGLineCap.butt, lineJoin: CGLineJoin.miter, miterLimit: 0.0)
                
                var startPoint: CGPoint!
                var endPoint: CGPoint!
                var prevPoint: CGPoint!
                
                // Check for intersections every 1 percent
                for p in stride(from: 0.0, through: 1.0, by: 0.01) {
                    let point = walkPath.point(atPercentOfLength: CGFloat(p))
                    if roadPath!.contains(point) {
                        // The road path contains this point from the walk path
                        if startPoint == nil {
                            startPoint = point
                        }
                    } else {
                        if startPoint != nil && endPoint == nil {
                            endPoint = prevPoint
                        }
                    }
                    
                    prevPoint = point
                    if startPoint != nil && endPoint != nil {
                        array.append((startPoint, endPoint, false))
                        startPoint = nil
                        endPoint = nil
                    }
                }
            }
        }
    }
    
    func activatePhysics() {
        // Borders
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionTypeLevelBorder
        self.physicsBody?.contactTestBitMask = CollisionTypeCar
        self.physicsBody?.collisionBitMask = CollisionTypeNone
        self.physicsBody?.usesPreciseCollisionDetection = true
        
        // Ground physics to stop the falling background
        self.ground.physicsBody = SKPhysicsBody(rectangleOf: self.ground.size, center: CGPoint(x: self.ground.size.width/2, y: self.ground.size.height/2))
        self.ground.physicsBody?.categoryBitMask = CollisionTypeLevelGround
        self.ground.physicsBody?.collisionBitMask = CollisionTypeLevelBackground
        self.ground.physicsBody?.contactTestBitMask = CollisionTypeLevelBackground
        self.ground.physicsBody?.isDynamic = false
        
        // The background is where all of the paths are stored. It starts above the screen and will start to fall when the physics are activated, stopping at the ground.
        self.view.physicsBody = SKPhysicsBody(rectangleOf: self.view.size, center: CGPoint(x: self.view.size.width/2, y: self.view.size.height/2))
        self.view.physicsBody?.categoryBitMask = CollisionTypeLevelBackground
        self.view.physicsBody?.collisionBitMask = CollisionTypeLevelGround
        self.view.physicsBody?.contactTestBitMask = CollisionTypeLevelGround
        self.view.physicsBody?.allowsRotation = false
        self.view.physicsBody?.restitution = 0.5
    }
    
    // MARK: - Show level
    
    func transitionToPlayWithDelay(_ delay: TimeInterval) {
        let wait = SKAction.wait(forDuration: delay)
        
        let transition = getTransitionToPlayActionWithDuration(1.0)
        
        let finished = SKAction.run { () -> Void in
            self.finishedTransitionToPlay()
        }
        
        let sequence = SKAction.sequence([wait, transition, finished])
        self.run(sequence, withKey: "intro_transition")
        
    }
    
    func transitionToPlay() {
        // Remove any existing transition
        self.removeAction(forKey: "intro_transition")
        
        // Transition to play immediately
        let transition = getTransitionToPlayActionWithDuration(0.0)
        
        let finished = SKAction.run { () -> Void in
            self.finishedTransitionToPlay()
        }
        
        let sequence = SKAction.sequence([transition, finished])
        self.run(sequence, withKey: "intro_transition")
    }
    
    fileprivate func getTransitionToPlayActionWithDuration(_ duration: TimeInterval) -> SKAction {
        let transition = SKAction.group([
            SKAction.run { () -> Void in
                // Fade in paths
                self.view.enumerateChildNodes(withName: "path_*", using: { node, stop in
                    node.run(SKAction.fadeIn(withDuration: duration))
                })
            },
            SKAction.run { () -> Void in
                self.view.enumerateChildNodes(withName: "level_info", using: { node, stop in
                    node.run(SKAction.fadeOut(withDuration: duration))
                })
            }])
        return transition
    }
    
    fileprivate func finishedTransitionToPlay() {
        // Level intro has either finished delay or the user tapped the screen
        self.view.physicsBody?.restitution = 0
        self.view.physicsBody?.isDynamic = false
        self.view.position = CGPoint.zero
        if let scene = self.parent as? GameScene {
            scene.currentScreen = Screen.levelPlay
        }
    }
    
    // MARK: - Level Info
    
    func toggleLevelInfo() {
        if let scene = self.parent as? GameScene {
            scene.playSound(scene.buttonSound)
        }
        if let scene = self.parent as? GameScene {
            var shouldShow = true
            if scene.currentScreen == Screen.help {
                // Hide help
                shouldShow = false
            }
            self.view.childNode(withName: "exit")?.alpha = shouldShow ? 1.0 : 0.0
            self.view.enumerateChildNodes(withName: "path_*") { node, stop in
                node.alpha = shouldShow ? 0.0 : 1.0
            }
            self.enumerateChildNodes(withName: "path_follower") { node, stop in
                node.alpha = shouldShow ? 0.0 : 1.0
            }
            self.view.enumerateChildNodes(withName: "level_info") { node, stop in
                node.alpha = shouldShow ? 1.0 : 0.0
            }
            scene.shouldUpdate = !shouldShow
            scene.currentScreen = shouldShow ? Screen.help : Screen.levelPlay
            
        }
    }
    
    func exitLevel() {
        if let scene = self.parent as? GameScene {
            scene.playSound(scene.buttonSound)
        }
        if let scene = self.parent as? GameScene {
            scene.levelNode.removeFromParent()
            scene.levelNode = nil
            scene.shouldUpdate = true
            scene.showLevelSelectScreen()
        }
    }
    
    // MARK: - Utils
    
    func checkIfGoalMet() {
        if self.score >= self.goal && self.pedScore >= self.pedGoal && self.carScore >= carGoal && !goalReached {
            goalReached = true
            if let scene = self.parent as? GameScene {
                scene.winNode.show()
            }
            //self.scoreLabel.fontName = "Lane - Posh"
            //self.pedScoreLabel?.fontName = "Lane - Posh"
            /*let wait = SKAction.wait(forDuration: 2)
             let show = SKAction.run { () -> Void in
             self.goalAchievedLabel.isHidden = false
             }
             let hide = SKAction.run{() -> Void in
             self.goalAchievedLabel.isHidden = true
             }
             goalReached = true
             self.run(SKAction.sequence([show, wait, hide]))*/
            //self.runAction(sequence, withKey: "intro_transition")
        }
    }
    
    // Convert a vertex to a point in this level -- depends on the screen size
    // and the number of rows and cols from this level
    func pointForVertex(_ vertex: PathVertex) -> CGPoint {
        let tileWidth = self.size.width / CGFloat(self.cols)
        let tileHeight = self.size.height / CGFloat(self.rows)
        return CGPoint(x: CGFloat(vertex.row) * tileWidth, y: CGFloat(vertex.col) * tileHeight)
    }
    
    func calculatePathWidth() -> CGFloat {
        let tileWidth = self.size.width / CGFloat(self.cols)
        let tileHeight = self.size.height / CGFloat(self.rows)
        return 2 * max(tileWidth, tileHeight) + 1
    }
    
    // MARK: - Update
    
    func update(_ timeSinceLastUpdate: CFTimeInterval) {
        //print(timeSinceLastUpdate)
        for (i, path) in self.paths.enumerated() {
            path.timeUntilNextRun -= timeSinceLastUpdate
            if path.timeUntilNextRun <= 0 {
                if path.type == Path.PathType.Road {
                    let _ = Car(level: self, pathIndex: i, speed: path.initSpeed)
                } else if self.paths[i].type == Path.PathType.Walk || self.paths[i].type == Path.PathType.CrazyPed {
                    let _ = Person(level: self, pathIndex: i, speed: path.initSpeed)
                } else if self.paths[i].type == Path.PathType.Garbage {
                    let g = Garbage(level: self, pathIndex: i, speed: path.initSpeed)
                    g.name = "garbage"
                }
                self.nextCarID += 1
                path.timeUntilNextRun = path.timeInterval
                path.updateTimeInterval()
                path.pathUpdate(intervalMult, speedMult: speedMult)
            }
        }
        self.enumerateChildNodes(withName: "path_follower|garbage") { node, stop in
            let pathFollower = node as! PathFollower
            pathFollower.update(timeSinceLastUpdate)
        }
        /*if hasGarbage {
            garbageTimer -= timeSinceLastUpdate
            if garbageTimer <= 0 {
                // get a ramdom num from 1 - 3 if 1 put garbage in random possible position otherwise hide garbage
                //then set a new timer
                garbageTimer = CFTimeInterval(arc4random_uniform(UInt32(GARBAGE_INTERVAL_UPPER_BOUND)))
                let i = Useful.random(min: 1, max: 3)
                if i == 1{
                    garbageSpriteNode.isHidden = false
                    let g = garbage[Useful.random(min: 0, max: garbage.count)]
                    let seg = g.enterPath[0].vertices[1]
                    let pos = self.pointForVertex(PathVertex(row: Int(seg.row), col: Int(seg.col)))
                    garbageSpriteNode.position = pos
                }else{
                    garbageSpriteNode.isHidden = true
                }
                
            }
        }*/
    }
    
    // MARK: - Garbage
    
    //Where the plastic bag start to enter the screen or exit the screen
    //Random point near where it is supposed to go
    
    /*func calculateStartingOrEndPoint(point: CGPoint) -> CGPoint {
        let midX = self.frame.midX
        let midY = self.frame.midY
        var minX: CGFloat = 0
        var minY: CGFloat = 0
        var maxX = self.frame.maxX
        var maxY = self.frame.maxY
        var x: CGFloat = -2
        var y: CGFloat = -2
        
        switch calculateQuadrant(point: point) {
        case 1:
            x = maxX + 2
            y = maxY + 2
            minX = midX
            minY = midY
        case 2:
            y = maxY + 2
            maxX = midX
            minY = midY
        case 3:
            maxX = midX
            maxY = midY
        default:
            x = maxX + 2
            minX = midX
            maxY = midY
        }
        
        let b = Useful.randomBool
        if b {
            x = CGFloat(Useful.random(min: Int(minX), max: Int(maxX) + 2))
            y = CGFloat(Useful.random(min: Int(minY), max: Int(maxY) + 2))
        }
        
        return CGPoint(x: x, y: y)
    }
    
    func calculateQuadrant(point: CGPoint) -> Int {
        let midX = self.frame.midX
        let midY = self.frame.midY
        if point.x < midX{
            if point.y < midY {
                return 3
            } else {
                return 2
            }
        } else {
            if point.y < midY {
                return 4
            } else {
                return 1
            }
        }
    }*/
}
