//
//  CarType.swift
//  Acua
//
//  Created by AHero on 5/15/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

public class Car: NSObject {
    
    var id, name : String!
    
    init(id:String, name:String) {
        self.id = id
        self.name = name
    }
    
    public func getId() -> String {
        return self.id
    }
    
    public func getName() -> String {
        return self.name
    }
}
