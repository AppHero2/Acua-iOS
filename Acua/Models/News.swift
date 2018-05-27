//
//  Notification.swift
//  Acua
//
//  Created by AHero on 5/27/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

class News: NSObject {
    
    public var idx, title, message : String
    public var createdAt: Int = Int(Date().timeIntervalSince1970*1000)
    public var isRead : Bool = false
    
    init(data:[String:Any]) {
        idx = data["uid"] as? String ?? "?"
        title = data["title"] as? String ?? "?"
        message = data["message"] as? String ?? ""
        createdAt = data["createdAt"] as? Int ?? Int(Date().timeIntervalSince1970*1000)
        isRead = data["isRead"] as? Bool ?? false
    }
    
    public func updateData(data:[String:Any]) {
        idx = data["uid"] as? String ?? "?"
        title = data["title"] as? String ?? "?"
        message = data["message"] as? String ?? ""
        createdAt = data["createdAt"] as? Int ?? Int(Date().timeIntervalSince1970*1000)
        isRead = data["isRead"] as? Bool ?? false
    }
    
}
