//
//  Order.swift
//  Acua
//
//  Created by AHero on 5/17/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

public enum PayStatus : Int{
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
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .UNPAID: return "UNPAID"
        case .PENDING: return "PENDING"
        case .PAID: return "PAID"
        case .REFUND: return "REFUND"
        }
    }
}

public enum ServiceStatus : Int{
    case BOOKED
    case ENGAGED
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
    
    var description : String {
        switch self {
        case .BOOKED: return "BOOKED"
        case .ENGAGED: return "ENGAGED"
        case .STARTED: return "STARTED"
        case .ENDED: return "ENDED"
        case .COMPLETED: return "COMPLETED"
        }
    }
}

public class Order: NSObject {
    
    public var idx, customerId, customerPushToken : String?
    public var washers : [String] = []
    public var menu : Menu?
    public var location : Location?
    public var beginAt = Int(Date().timeIntervalSince1970*1000)
    public var endAt = Int(Date().timeIntervalSince1970*1000)
    public var completedAt: Int = 0
    public var payStatus : PayStatus = .UNPAID
    public var serviceStatus : ServiceStatus = .BOOKED
    public var hasTap : Bool = true
    public var hasPlug : Bool = true
    public var is24reminded : Bool = false
    
    override init() {
        super.init()
    }
    
    init(data : [String : Any]) {
        super.init()
        self.updateData(data: data)
    }
    
    public func updateData(data : [String : Any]) {
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
        
        self.beginAt = data["beginAt"] as? Int ?? 0
        self.endAt = data["endAt"] as? Int ?? 0
        self.completedAt = data["completedAt"] as? Int ?? 0
        
        self.hasTap = data["hasTap"] as? Bool ?? true
        self.hasPlug = data["hasPlug"] as? Bool ?? true
        self.is24reminded = data["is24reminded"] as? Bool ?? false
    }
    
    public func toAnyObject() -> [String:Any]{
        var data : [String:Any] = [:]
        data["idx"] = self.idx!
        data["customerId"] = self.customerId ?? "?"
        data["customerPushToken"] = self.customerPushToken
        
        var menuData : [String:Any] = data["menu"] as? [String:Any] ?? [:]
        menuData["idx"] = menu?.getId()
        menuData["price"] = menu?.getPrice()
        menuData["duration"] = menu?.getDuration()
        data["menu"] = menuData

        var locationData : [String:Any] = data["location"] as? [String:Any] ?? [:]
        locationData["name"] = location?.name
        locationData["latitude"] = location?.latitude
        locationData["longitude"] = location?.longitude
        data["location"] = locationData
        
        data["payStatus"] = payStatus.description
        data["serviceStatus"] = serviceStatus.description
        
        data["beginAt"] = beginAt
        data["endAt"] = endAt
        data["hasTap"] = hasTap
        data["hasPlug"] = hasPlug
        data["is24reminded"] = is24reminded
        return data
    }
}
