//
//  Menu.swift
//  Acua
//
//  Created by AHero on 5/15/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

class Menu: NSObject {
    
    var id : String!
    var price : Double = 0.0
    var duration : Int = 3590
    
    init(id:String, price: Double, duration: Int) {
        self.id = id
        self.price = price
    }
    
    public func getId() -> String {
        return self.id
    }
    
    public func getPrice() -> Double {
        return self.price
    }
    
    public func getDuration() -> Int {
        return self.duration
    }
}
