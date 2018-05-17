//
//  Order.swift
//  Acua
//
//  Created by AHero on 5/17/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

enum PayStatus : Int{
    case UNPAID
    case PENDING
    case PAID
    case REFUND
    
    static func enumFromString(string:String) -> PayStatus? {
        var i = 0
        while let item = PayStatus(rawValue: i) {
            if String(describing: item) == string { return item }
            i += 1
        }
        return nil
    }
}

enum ServiceStatus : Int{
    case BOOKED
    case ACCEPTED
    case STARTED
    case ENDED
    case COMPLETED
    
    static func enumFromString(string:String) -> ServiceStatus? {
        var i = 0
        while let item = ServiceStatus(rawValue: i) {
            if String(describing: item) == string { return item }
            i += 1
        }
        return nil
    }
}

class Order: NSObject {
    
    public var idx, customerId, customerPushToken : String?
    public var washers : [String] = []
    public var menu : Menu
    public var location : Location
    public var beginAt, endAt : Int
    public var payStatus : PayStatus = .UNPAID
    public var serviceStatus : ServiceStatus = .BOOKED
    public var hasTap : Bool = true
    public var hasPlug : Bool = true
    public var is24reminded : Bool = false
    
    init( data : [String : Any]) {
        self.idx = data["idx"] as? String
        self.customerId = data["customerId"] as? String
        self.customerPushToken = data["customerPushToken"] as? String
        
        var menuData : [String:Any] = data["menu"] as? [String:Any] ?? [:]
        let menuId = menuData["idx"] as? String ?? ""
        let price = menuData["price"] as? Double ?? 0.0
        let duration = menuData["duration"] as? Int ?? 0
        self.menu = Menu(id: menuId, price: price, duration: duration)
        
        var locationData : [String:Any] = data["location"] as? [String:Any] ?? [:]
        let name = locationData["name"] as? String  ?? ""
        let lat = locationData["latitude"] as? Double ?? 0.0
        let lng = locationData["longitude"] as? Double ?? 0.0
        self.location = Location.init(name, lat: lat, lng: lng)
        
        self.payStatus = PayStatus.enumFromString(string: data["payStatus"] as? String ?? "") ?? PayStatus.PENDING
        self.serviceStatus = ServiceStatus.enumFromString(string: data["serviceStatus"] as? String ?? "") ?? ServiceStatus.BOOKED
        
        self.beginAt = data["beginAt"] as? Int ?? Int(Date().timeIntervalSince1970/1000)
        self.endAt = data["endAt"] as? Int ?? Int(Date().timeIntervalSince1970/1000)
        
        self.hasTap = data["hasTap"] as? Bool ?? true
        self.hasPlug = data["hasPlug"] as? Bool ?? true
        self.is24reminded = data["is24reminded"] as? Bool ?? false
    }
}
