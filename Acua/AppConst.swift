//
//  AppConst.swift
//  Acua
//
//  Created by AHero on 5/20/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

class AppConst: NSObject {

    static public let BTN_CORNER_RADIUS : CGFloat = 3
    static public let SERVICE_TIME_START = 7
    static public let SERVICE_TIME_END = 17
    
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
