//
//  User.swift
//  Acua
//
//  Created by AHero on 5/17/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

public class User: NSObject {
    
    public var idx : String
    public var firstname, lastname, email, photo, phone, bio, pushToken : String?
    public var userType : Int = 0 // 0: customer, 1: operator, 2: admin
    public var cardStatus : Int = 0 // 0: not verified, 1: verified, 2: expired
    public var cardToken : String?
    
    init(data:[String:Any]) {
        idx = data["uid"] as? String ?? ""
        firstname = data["firstname"] as? String
        lastname = data["lastname"] as? String
        email = data["email"] as? String
        photo = data["photo"] as? String
        phone = data["phone"] as? String ?? ""
        pushToken = data["pushToken"] as? String
        userType = data["userType"] as? Int ?? 0
        cardStatus = data["cardStatus"] as? Int ?? 0
        cardToken = data["cardToken"] as? String
    }
    
    public func getFullName() -> String {
        return "\(firstname ?? "") \(lastname ?? "")"
    }
}
