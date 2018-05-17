//
//  Location.swift
//  Acua
//
//  Created by AHero on 5/17/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

class Location: NSObject {
    public var name : String
    public var latitude, longitude : Double
    
    init(_ name:String, lat:Double, lng: Double) {
        self.name = name
        self.latitude = lat
        self.longitude = lng
    }
}
