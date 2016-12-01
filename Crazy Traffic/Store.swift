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

class Store: SKSpriteNode, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    var buyButton: AGSpriteButton?
    var buy10LivesButton: AGSpriteButton?
    var exitButton: AGSpriteButton?
    var productID: String = ""
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
        
        let textNode = SKLabelNode(text: "5 Lives")
        textNode.name = "text"
        textNode.fontName = FONT_NAME
        textNode.fontSize = FONT_SIZE_L
        textNode.position = CGPoint(x: self.frame.minX + 60, y: self.frame.maxY - 60)
        self.addChild(textNode)
        
        let TenLtextNode = SKLabelNode(text: "10 Lives")
        TenLtextNode.name = "text"
        TenLtextNode.fontName = FONT_NAME
        TenLtextNode.fontSize = FONT_SIZE_L
        TenLtextNode.position = CGPoint(x: self.frame.minX + 60, y: self.frame.maxY - 120)
        self.addChild(TenLtextNode)
        
        self.isHidden = true
        
        self.buyButton = AGSpriteButton(color: LEVEL_SELECT_COLOR, andSize: CGSize(width: 80, height: 30))
        self.buyButton!.position = CGPoint(x: self.frame.maxX - 60, y: self.frame.maxY - 55)
        self.buyButton!.name = "Buy"
        self.buyButton!.addTarget(self, selector:#selector(Store.buy5lives), with: nil, for:AGButtonControlEvent.touchUpInside)
        self.buyButton!.setLabelWithText("Buy", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
        self.addChild(buyButton!)
        
        self.buy10LivesButton = AGSpriteButton(color: LEVEL_SELECT_COLOR, andSize: CGSize(width: 80, height: 30))
        self.buy10LivesButton!.position = CGPoint(x: self.frame.maxX - 60, y: self.frame.maxY - 110)
        self.buy10LivesButton!.name = "Buy"
        self.buy10LivesButton!.addTarget(self, selector:#selector(Store.buy10lives), with: nil, for:AGButtonControlEvent.touchUpInside)
        self.buy10LivesButton!.setLabelWithText("Buy", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
        self.addChild(buy10LivesButton!)
        
        self.exitButton = AGSpriteButton(color: LEVEL_SELECT_COLOR, andSize: CGSize(width: 80, height: 30))
        self.exitButton!.position = CGPoint(x: self.frame.maxX - 60, y: self.frame.minY + 40)
        self.exitButton!.name = "Exit"
        self.exitButton!.addTarget(self, selector:#selector(Store.hide), with: nil, for:AGButtonControlEvent.touchUpInside)
        self.exitButton!.setLabelWithText("Exit", andFont: UIFont(name: FONT_NAME, size: FONT_SIZE_M), with: UIColor.white)
        self.addChild(exitButton!)
        SKPaymentQueue.default().add(self)
    }
    
    func show() {
        if let scene = self.parent as? GameScene {
            scene.currentScreen = Screen.store
            self.isHidden = false
        }
        FIRAnalytics.logEvent(withName: "share_image", parameters: [
            "name": "enterStore" as NSObject,
            "full_text": "user entered Store" as NSObject
            ])
    }
    
    func hide() {
        if let scene = self.parent as? GameScene {
            scene.showLevelSelectScreen()
            scene.playSound(scene.buttonSound)
        }
        self.isHidden = true
    }
    
    func buy5lives() {
        if let scene = self.parent as? GameScene {
            scene.playSound(scene.buttonSound)
        }
        productID = "5Lives"
        FIRAnalytics.logEvent(withName: "share_image", parameters: [
            "name": "buy5lives" as NSObject,
            "full_text": "user bougth 5 lives" as NSObject
            ])
        buyConsumable()
    }
    
    func buy10lives() {
        if let scene = self.parent as? GameScene {
            scene.playSound(scene.buttonSound)
        }
        productID = "10Lives"
        FIRAnalytics.logEvent(withName: "share_image", parameters: [
            "name": "buy10lives" as NSObject,
            "full_text": "user bougth 10 lives" as NSObject
            ])
        buyConsumable()
    }
    
    func buyConsumable(){
        print("About to fetch the products");
        // We check that we are allow to make the purchase.
        if (SKPaymentQueue.canMakePayments())
        {
            let productID: NSSet = NSSet(object: self.productID);
            let productsRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
            productsRequest.delegate = self;
            productsRequest.start();
            print("Fething Products");
        }else{
            print("can not make purchases");
        }
    }
    
    func buyProduct(product: SKProduct){
        print("Sending the Payment Request to Apple");
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment);
    }
    
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("got the request from Apple")
        let count : Int = response.products.count
        if (count>0) {
            _ = response.products
            let validProduct: SKProduct = response.products[0] as SKProduct
            if (validProduct.productIdentifier == self.productID) {
                print(validProduct.localizedTitle)
                print(validProduct.localizedDescription)
                print(validProduct.price)
                buyProduct(product: validProduct);
            } else {
                print(validProduct.productIdentifier)
            }
        } else {
            print(response.invalidProductIdentifiers)
            print("nothing")
        }
    }
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])    {
        print("Received Payment Transaction Response from Apple");
        
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    print("Product Purchased");
                    var livesNum = 0
                    if productID == "5Lives"{
                        livesNum = 5
                    }
                    if productID == "10Lives"{
                        livesNum = 10
                    }
                    UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "lives") + livesNum, forKey: "lives")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .failed:
                    print("Purchased Failed");
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                    // case .Restored:
                //[self restoreTransaction:transaction];
                default:
                    break;
                }
            }
        }
    }
    
}
