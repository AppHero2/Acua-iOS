//
//  Extensions.swift
//  Acua
//
//  Created by AHero on 6/6/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

//Extensions
extension UIColor{
    class func rbg(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        let color = UIColor.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
        return color
    }
}
