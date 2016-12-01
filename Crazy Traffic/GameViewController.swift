//
//  GameViewController.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 3/3/16.
//  Copyright (c) 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import GoogleMobileAds
import Firebase

class GameViewController: UIViewController, UIAlertViewDelegate {
    
    //ads
    var adsFree = false
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.value(forKey: "me") == nil {
            UserDefaults.standard.set(0, forKey: "me")
        }
        if UserDefaults.standard.integer(forKey: "me") == 1{
            adsFree = true
        }
        
        //ads
        if !adsFree {
            createAndLoadInterstitial()
        }
        
        // Register defaults
        let defaults = [
            "currentLevel": 1
        ]
        UserDefaults.standard.register(defaults: defaults)
        UserDefaults.standard.synchronize()
        
        //let path = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)
        //let folder = path[0]
        //Swift.print("Your NSUserDefaults are stored in this folder: \(folder)/Preferences")
        
        Swift.print("currentLevel: \(UserDefaults.standard.integer(forKey: "currentLevel"))")
        Swift.print("highScores: \(UserDefaults.standard.dictionary(forKey: ("highScores")))")
        
        /*if let scene = GameScene(fileNamed:"GameScene") {
         // Configure the view.
         let skView = self.view as! SKView
         //skView.showsFPS = true
         //skView.showsNodeCount = true
         //skView.showsPhysics = true
         
         /* Sprite Kit applies additional optimizations to improve rendering performance */
         skView.ignoresSiblingOrder = true
         
         /* Set the scale mode to scale to fit the window */
         scene.scaleMode = .resizeFill
         scene.gvc = self
         
         skView.presentScene(scene)
         }*/
        
        let scene = IntroScene()
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        scene.size = (size: skView.bounds.size)
        scene.gvc = self
        skView.presentScene(scene)
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    fileprivate func createAndLoadInterstitial() {
        //self.interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        //request.testDevices = ["9e9943d33bf32d302fefb8cfd65fb2d4"]
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        //request.testDevices = [ kGADSimulatorID, "2077ef9a63d2b398840261c8221a0c9b" ]
        if !adsFree{
            interstitial = GADInterstitial(adUnitID: "ca-app-pub-3528807648470489/6696477059")
            let request = GADRequest()
            interstitial.load(request)
        }
    }
    
    func addAd() {
        if !adsFree && interstitial.isReady {
            interstitial.present(fromRootViewController: self)
            createAndLoadInterstitial()
        } else {
            print("Ad wasn't ready")
        }
    }
}
