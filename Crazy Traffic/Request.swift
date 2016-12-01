//
//  Request.swift
//  Crazy Traffic
//
//  Created by Ana Vitoria do Valle Costa on 10/25/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation

enum RequestType {
    case asked
    case received
}

enum RequestObject {
    case lives
}

var requestsArray = [Request]()

class Request {
    var type: RequestType
    var object: RequestObject
    var from: String
    var fromID: String
    var id: String
    var text: String = ""
    
    init(type: RequestType, object: RequestObject, from: String, id: String, fromID: String) {
        self.type = type
        self.object = object
        self.from = from
        self.id = id
        self.fromID = fromID
        setUpText()
    }
    
    func setUpText(){
        var action = ""
        switch type {
        case .asked:
            action = " asked you to send "
        default:
            action = " sent you "
        }
        text = from + action + "five lives"
    }
}
