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
    
    public var carTypeDelegate : CarTypeDelegate?
    public var washTypeDelegate : WashTypeDelegate?
    
    override init() {
        
    }
    
    public func initLocation (){

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
            self.carTypeDelegate?.didLoaded(cars: self.carTypes)
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
            self.washTypeDelegate?.didLoaded(washes: self.washTypes)
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
    
    public func saveUser(user: User) {
        UserDefaults.standard.set(user.idx, forKey: "uid")
        UserDefaults.standard.set(user.firstname, forKey: "firstname")
        UserDefaults.standard.set(user.lastname, forKey: "lastname")
        UserDefaults.standard.set(user.email, forKey: "email")
        UserDefaults.standard.set(user.photo, forKey: "photo")
        UserDefaults.standard.set(user.phone, forKey: "phone")
        UserDefaults.standard.set(user.pushToken, forKey: "pushToken")
        UserDefaults.standard.set(user.userType, forKey: "userType")
    }
    
    public func getUser() -> User? {
        var userData : [String:Any] = [:]
        userData["uid"] = UserDefaults.standard.string(forKey: "uid")
        userData["firstname"] = UserDefaults.standard.string(forKey: "firstname")
        userData["lastname"] = UserDefaults.standard.string(forKey: "lastname")
        userData["email"] = UserDefaults.standard.string(forKey: "email")
        userData["photo"] = UserDefaults.standard.string(forKey: "photo")
        userData["phone"] = UserDefaults.standard.string(forKey: "phone")
        userData["pushToken"] = UserDefaults.standard.string(forKey: "pushToken")
        userData["userType"] = UserDefaults.standard.integer(forKey: "userType")
        
        let user = User(data: userData)
        if user.idx == nil {
            return nil
        } else {
            return user
        }
    }
    
    public func deleteUser() {
        UserDefaults.standard.set(nil, forKey: "uid")
    }
}
