//
//  IntroScene.swift
//  Crazy Traffic
//
//  Created by Ana Vitoria do Valle Costa on 10/1/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import Firebase
import FirebaseCrash

class IntroScene: SKScene, FBSDKLoginButtonDelegate, FBSDKAppInviteDialogDelegate  {
    /*!
     @abstract Sent to the delegate when the app invite completes without error.
     @param appInviteDialog The FBSDKAppInviteDialog that completed.
     @param results The results from the dialog.  This may be nil or empty.
     */
    public func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print("invitation made")
    }
    
    var gvc: GameViewController?
    let loginButton = FBSDKLoginButton()
    var loggedIn = false
    
    override func didMove(to view: SKView) {
        // clear friends array
        FIRCrashMessage("Chash in IntroScene")
        //fatalError()
        facebookFriends = [FacebookFriend]()
        
        self.backgroundColor = LEVEL_INTRO_COLOR
        
        // setup play button
        let texture = SKTexture(image: ImageManager.imageForPlayButton())
        let playButton = SKSpriteNode(texture: texture)
        playButton.name = "playButton"
        playButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 40)
        playButton.xScale = 2
        playButton.yScale = 2
        self.addChild(playButton)
        
        
        //setup facebook login button
        loginButton.center = (self.view?.center)!
        self.view?.addSubview(loginButton)
        loginButton.frame = CGRect(x: 0, y: 0, width: 360, height: 60)
        loginButton.center = CGPoint(x: self.frame.midX, y: self.frame.midY + 90)
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
        // if already logged in, get the information
        if let _ = FBSDKAccessToken.current(){
            fetchProfile()
        }
    }
    
    // go to level select screen
    func startGame(){
        if let scene = GameScene(fileNamed:"GameScene") {
            loginButton.removeFromSuperview()
            
            // Configure the view.
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFit
            
            scene.gvc = self.gvc
            scene.loggedIn = self.loggedIn
            
            skView.presentScene(scene)
        }
    }
    
    // check if touched the play button
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self) {
            let node = self.atPoint(location)
            if let nodeName = node.name {
                if nodeName == "playButton" {
                    startGame()
                }
            }
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if(error == nil)
        {
            print("login complete")
            //print(FBSDKAccessToken.current().tokenString)
            //print(result.grantedPermissions)
        }
        else{
            print(error.localizedDescription)
        }
        
        fetchProfile()
    }
    
    func fetchProfile() {
        loggedIn = true
        facebookFriends.removeAll()
        requestsArray.removeAll()
        //get information about the player
        /*let parameters = ["fields": "first_name, email, last_name, picture"]
         FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: { (connection, user, requestError) -> Void in
         
         if requestError != nil {
         print("----------ERROR-----------")
         print(requestError)
         return
         }
         let userData = user as! NSDictionary
         let email = userData["email"] as? String
         let firstName = userData["first_name"] as? String
         let lastName = userData["last_name"] as? String
         print("----------ID-----------")
         print(userData["id"])
         var pictureUrl = ""
         if let picture = userData["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary, let url = data["url"] as? String {
         pictureUrl = url
         print(pictureUrl)
         }
         })*/
        
        //get friends picture, name and id and save to friends array
        let parameters2 = ["fields": "name,picture.type(normal)"]
        FBSDKGraphRequest(graphPath: "/me/friends", parameters: parameters2).start(completionHandler: { (connection, user, requestError) -> Void in
            if let userData = user as? NSDictionary{
                let friends = userData["data"] as? [NSDictionary]
                if requestError != nil {
                    print("----------ERROR-----------")
                    print(requestError)
                    return
                }
                
                //print("------------FRIENDS--------------")
                //print(user)
                for friend in friends!{
                    let f = friend as NSDictionary
                    let name = f["name"] as? String
                    let id = f["id"] as? String
                    if let picture = (((f["picture"] as? NSDictionary)?["data"] as? NSDictionary)?["url"] as? String) {
                        let fr = FacebookFriend(name: name!, id: id!, pictureURL: picture)
                        facebookFriends.append(fr)
                    }
                }
            }
        })
        
        // doesn't work because must have a playable canvas version to get invitable friends
        /*FBSDKGraphRequest(graphPath: "/me/invitable_friends", parameters: nil).start(completionHandler: { (connection, user, requestError) -> Void in
         if let userData = user as? NSDictionary{
         let friends = userData["data"] as? [NSDictionary]
         if requestError != nil {
         print("----------ERROR-----------")
         print(requestError)
         return
         }
         
         print("------------FRIENDS--------------")
         //print(friends)
         for friend in friends!{
         let f = friend as NSDictionary
         print(f["name"])
         /*let name = f["name"] as? String
         let id = f["id"] as? String
         if let picture = (((f["picture"] as? NSDictionary)?["data"] as? NSDictionary)?["url"] as? String) {
         let fr = FacebookFriend(name: name!, id: id!, pictureURL: picture)
         facebookFriends.append(fr)
         }*/
         }
         }else{
         /*print("------------FRIENDS--------------")
         print(connection)
         print(user)
         print(requestError)
         let content = FBSDKAppInviteContent()
         content.appLinkURL = NSURL(string: APP_LINK_URL) as URL!
         content.appInvitePreviewImageURL = NSURL(string: APP_INVITE_IMAGE_URL) as URL!
         FBSDKAppInviteDialog.show(with: content, delegate: self)
         //FBSDKAppInviteDialog.show(self, withContent: content, delegate: self)*/
         }
         })*/
        FBSDKGraphRequest(graphPath: "/me/apprequests", parameters: nil).start(completionHandler: { (connection, user, requestError) -> Void in
            print("----------Requests-----------")
            if let userData = user as? NSDictionary , let data = userData["data"] as? [NSDictionary]{
            //let data = userData["data"] as! [NSDictionary]
            print(data.count)
            for request in data {
                print(request["data"])
                if request["data"] != nil{
                    let requestData = (request["data"] as! String).characters.split(separator: "-").map(String.init)
                    if requestData.count < 2{
                        print("invalid data")
                        self.deleteRequest(id: request["id"] as! String)
                    }else{
                        var type = RequestType.received
                        if requestData[0] == "asked"{
                            type = RequestType.asked
                        }
                        let object = RequestObject.lives
                        let from = (request["from"] as! NSDictionary)["name"]
                        let fromID = (request["from"] as! NSDictionary)["id"]
                        var repeated = false
                        for r in requestsArray{
                            if type == r.type && fromID as! String == r.fromID{
                                repeated = true
                            }
                        }
                        if repeated{
                            self.deleteRequest(id: request["id"] as! String)
                        }else{
                            let id = request["id"] as! String
                            requestsArray.append(Request(type: type, object: object, from: from as! String, id: id, fromID: fromID as! String))
                        }
                    }
                }
                /*FBSDKGraphRequest(graphPath: request["id"] as! String, parameters: nil, httpMethod: "DELETE").start(completionHandler: { (connect, req, requestErr) -> Void in
                 print("----------Request Delete-----------")
                 print(requestErr)
                 print(req)
                 })*/
                
            }
            }
        })
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("invitation made")
    }
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print("error made")
    }
    
    func deleteRequest(id: String) {
        FBSDKGraphRequest(graphPath: id, parameters: nil, httpMethod: "DELETE").start(completionHandler: { (connect, req, requestErr) -> Void in
            print("----------Request Delete-----------")
            print(requestErr)
            print(req)
        })
    }
}
