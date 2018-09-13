//
//  Feedback.swift
//  Acua
//
//  Created by AHero on 6/7/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

class Feedback: NSObject {
    
    public var idx, orderID, washerID, senderID, content : String
    public var type : Int = 0
    public var createdAt : Int = (Int)(Date().timeIntervalSince1970) * 1000
    
    init(data:[String:Any]) {
        idx = data["idx"] as? String ?? "?"
        orderID = data["orderID"] as? String ?? "?"
        washerID = data["senderID"] as? String ?? "?"
        senderID = data["washerID"] as? String ?? "?"
        content = data["content"] as? String ?? "?"
        type = data["type"] as? Int ?? 0
        createdAt = data["createdAt"] as? Int ?? 0
    }
    
    class func getFeedbackContent(type: Int) -> String {
        var message = ""
        switch type {
        case 1:
            message = "At Acuar, we aim to provide you with the best quality car wash experience, one worth every cent you pay.\n\n If the quality of the car wash service for this experience was not satisfactory, we apologise for this shortfall. Please share the details of the poor service here:"
        case 2:
            message = "As an Acuar client, your feedback on the Acuar experience and your interaction with the Acuar operators helps us improve the service we provide to you. The Acuar operators have agreed to a professional code of conduct, which includes treating our clients with respect.\n\n If the Acuar operators had an unprofessional interaction with you, we apologise for this behaviour. Please share the details of the unprofessionalism here:"
        case 3:
            message = "Although we aim to run a tight ship, Murphy's law which states \"Anything that can go wrong, will go wrong\" may overtake the Acuar operation.\n\n If the Acuar car wash service failed to honour an appointment you scheduled, please accept our apology for the inconvenience. We understand that your time is valuable, and we will do our best to make amends. Please share the details here:"
        case 4:
            message = "At Acuar we encourage ethical business practices for our operators. Theft is strongly frowned upon and guilty parties are guaranteed to face severe consequences.\n\n If you have good reason to believe that one or more items have gone missing from your car or yard due to theft or taken by mistake by one or more of our operators, we shall investigate as far as reasonably possible. If they are found guilty, your item will be returned to you free of charge. Please share the details here:"
        case 5:
            message = "Although Acuar runs a tight ship, we may disappoint you in ways we never intended to. Your feedback helps us to improve the car wash service we deliver and to ensure you always get value for your money.\n\n If we have fallen short in the delivery of the service, we apologise for the inconvenience caused. Please let us know what went wrong here:"
        case 6:
            message = "Although Acuar runs a tight ship, we may disappoint you in ways we never intended to. Your feedback helps us to improve the car wash service we deliver and to ensure you always get value for your money.\n\n If we have fallen short in the delivery of the service, we apologise for the inconvenience caused. Please let us know what went wrong here:"
        default:
            message = "At Acuar, we aim to provide you with the best quality car wash experience, one worth every cent you pay.\n\n If the quality of the car wash service for this experience was not satisfactory, we apologise for this shortfall. Please share the details of the poor service here:"
        }
        
        return message
    }
    
    class func getFeedbackTitle (type: Int) -> String {
        var message = ""
        switch type {
        case 1:
            message = "1.  I am not satisfied with the quality of the car wash"
        case 2:
            message = "2.  The Acuar operators were unprofessional"
        case 3:
            message = "3.  The Acuar car wash service did not arrive"
        case 4:
            message = "4.  I lost an item"
        case 5:
            message = "5.  The car wash service has caused damage to my car"
        case 6:
            message = "6.  I have a different issue"
        default:
            message = "1.  I am not satisfied with the quality of the car wash"
        }
        
        return message
    }
}
