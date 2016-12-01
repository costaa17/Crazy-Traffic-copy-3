//
//  GameOver.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/30/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import SpriteKit
import Firebase

class GameOverNode: SKSpriteNode {
    var nextLevelButton: AGSpriteButton?
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
        self.alpha = 0.8
        
        let textNode = SKLabelNode(text: "Game Over")
        textNode.name = "text"
        textNode.fontName = FONT_NAME
        textNode.fontSize = FONT_SIZE_XL
        self.addChild(textNode)
        
        let highScoreText = SKLabelNode(text: "(Pssst...you got a high score)")
        highScoreText.name = "high_score"
        highScoreText.fontName = FONT_NAME
        highScoreText.fontSize = FONT_SIZE_M
        self.addChild(highScoreText)
        
        self.nextLevelButton?.isHidden = true
        self.nextLevelButton = AGSpriteButton(color: LEVEL_SELECT_COLOR, andSize: CGSize(width: 110, height: 40))
        self.nextLevelButton!.position = CGPoint(x: self.frame.width/2, y: 70)
        self.nextLevelButton!.addTarget(self, selector:#selector(GameOverNode.nextLevel), with: nil, for:AGButtonControlEvent.touchUpInside)
        self.nextLevelButton!.setLabelWithText("Next Level", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
        self.addChild(nextLevelButton!)
    }
    
    func show() {
        if let scene = self.parent as? GameScene {
            scene.currentScreen = Screen.gameOver
            
            let center = CGPoint(x: self.size.width/2, y: self.size.height/2)
            let gameOverTextNode = self.childNode(withName: "text") as! SKLabelNode
            let highScoreTextNode = self.childNode(withName: "high_score") as! SKLabelNode
            
            // Check if we got a high score
            let levelKey = "level\(scene.levelNode.levelNum)"
            let carKey = "car"
            let pedKey = "ped"
            var highScoreDict: [String: [String: Int]]! = UserDefaults.standard.dictionary(forKey: "highScores") as? [String: [String: Int]]
            if highScoreDict == nil {
                highScoreDict = [:]
            }
            var levelScoreDict = highScoreDict[levelKey] as [String: Int]!
            if levelScoreDict == nil {
                levelScoreDict = [carKey: 0, pedKey: 0]
            }
            var carHighScore = levelScoreDict?[carKey]!
            var pedHighScore = levelScoreDict?[pedKey]!
            var isHighScore = false
            if scene.levelNode.carScore > carHighScore! {
                carHighScore = scene.levelNode.carScore
                isHighScore = true
            }
            if scene.levelNode.pedScore > pedHighScore! {
                pedHighScore = scene.levelNode.pedScore
                isHighScore = true
            }
            
            highScoreDict[levelKey] = [carKey: carHighScore!, pedKey: pedHighScore!]
            
            UserDefaults.standard.setValue(highScoreDict, forKey: "highScores")
            UserDefaults.standard.synchronize()
            
            if isHighScore {
                highScoreTextNode.isHidden = false
                gameOverTextNode.position = CGPoint(x: center.x, y: center.y + 20)
                highScoreTextNode.position = CGPoint(x: center.x, y: center.y - 20)
            } else {
                highScoreTextNode.isHidden = true
                gameOverTextNode.position = CGPoint(x: center.x, y: center.y)
            }

            // Check to see if we lost or won
            if scene.levelNode.score >= scene.levelNode.goal &&
                scene.levelNode.pedScore >= scene.levelNode.pedGoal && scene.levelNode.carScore >= scene.levelNode.carGoal {
                // We won!
                gameOverTextNode.text = "Good job!"
                nextLevelButton?.isHidden = false
                
                // Increase the current level
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
                
            } else {
                self.nextLevelButton?.isHidden = true
                highScoreTextNode.isHidden = true
                gameOverTextNode.position = CGPoint(x: center.x, y: center.y)
                gameOverTextNode.text = "You lost"
                let currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
                let currentEpisode = (currentLevel - 1) / LEVELS_PER_EPISODE
                if UserDefaults.standard.integer(forKey: "lives") == maxLifeForEpisode(currentEpisode) {
                    UserDefaults.standard.setValue(Date(), forKey: "time")
                    UserDefaults.standard.set(0, forKey: "subtractTime")
                }
                let lev = scene.levelNode.levelNum
                let temp = "level" + String(lev)
                let episode = (lev - 1) / LEVELS_PER_EPISODE
                let temp2 = "episode" + String(episode)
                if UserDefaults.standard.integer(forKey: "me") != 1{
                GameAnalytics.addProgressionEvent(with: GAProgressionStatusFail , progression01:temp2, progression02: temp, progression03:" ")
                }
                if currentEpisode != 0 {
                    UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "lives") - 1, forKey: "lives")
                    //FIRAnalytics.setUserPropertyString(String(UserDefaults.standard.integer(forKey: "lives")), forName: "lives")
                }

                //long timestamp = (DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc))
                //string value = timestamp.ToString();
                //PlayerPrefs.SetString("Time", 0);
                
            }
            
            self.isHidden = false
        }
    }
    
    func hide() {
        self.isHidden = true
    }
    
    func nextLevel(){
        if let scene = self.parent as? GameScene {
            let levelNum = scene.levelNode.levelNum + 1
            let levn = scene.levelNode
            scene.loadLevel(levelNum: levelNum)
            levn?.removeFromParent()
            scene.shouldUpdate = true
        }
        self.hide()
        
    }
    
}
