//
//  AppManager.swift
//  Acua
//
//  Created by AHero on 5/5/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import Firebase

class AppManager: NSObject {
    
    static let shared = AppManager()
    
    public var carTypes : [Car] = []
    public var washTypes : [Wash] = []
    public var menuList : [Menu] = []
    
    override init() {
        
    }
    
    public func setup(){
        self.listenCarTypes()
        self.listenWashTypes()
        self.listenMenuList()
    }
    
    public func listenCarTypes(){
        DatabaseRef.shared.carsRef.observe(DataEventType.value, with: { (snapshot) in
            self.carTypes.removeAll()
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let id = rest.key
                let name = rest.value as? String ?? "?"
                let car = Car(id: id, name: name)
                self.carTypes.append(car)
            }
        })
    }
    
    public func listenWashTypes(){
        DatabaseRef.shared.washRef.observe(DataEventType.value, with: { (snapshot) in
            self.washTypes.removeAll()
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let id = rest.key
                let name = rest.value as? String ?? "?"
                let wash = Wash(id: id, name: name)
                self.washTypes.append(wash)
            }
        })
    }
    
    public func listenMenuList(){
        DatabaseRef.shared.menuRef.observe(DataEventType.value, with: { (snapshot) in
            self.menuList.removeAll()
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let id = rest.key
                let dic = rest.value as? [String:Any] ?? [:]
                let price = dic["price"] as? Double ?? 0.0
                let duration = dic["duration"] as? Int ?? 0
                let menu = Menu(id: id, price: price, duration: duration)
                self.menuList.append(menu)
            }
        })
    }
}
