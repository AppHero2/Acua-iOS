//
//  AppConst.swift
//  Acua
//
//  Created by AHero on 5/20/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

class AppConst: NSObject {

    static public let URL_HEROKU_BASE = "https://acua-node.herokuapp.com/"
    static public let URL_HEROKU_PAYMENT = "https://acua-node.herokuapp.com/payment"
    static public let URL_HEROKU_PAYMENT_VERIFY = "https://acua-node.herokuapp.com/payment/verify"
    
    static public let BTN_CORNER_RADIUS : CGFloat = 3
    static public let SERVICE_TIME_START = 7
    static public let SERVICE_TIME_END = 18
    
    static public let LIMIT_ORDERS_PER_HOUR = 1
    
    static public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static public var primaryColor: UIColor {
        return UIColor(red: 33/255, green: 137/255, blue: 190/255, alpha: 1.0)
    }
}
