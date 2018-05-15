//
//  DatabaseRef.swift
//  Acua
//
//  Created by AHero on 5/14/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import Firebase

class DatabaseRef: NSObject {
    
    static let shared = DatabaseRef()
    
    public let userRef, carsRef, washRef, ordersRef, menuRef, notificationRef, feedbackRef : DatabaseReference

    override init() {
        Database.database().isPersistenceEnabled = true
        
        userRef = Database.database().reference().child("Users")
        carsRef = Database.database().reference().child("CarType")
        washRef = Database.database().reference().child("WashType")
        ordersRef = Database.database().reference().child("Orders")
        menuRef = Database.database().reference().child("WashMenu")
        notificationRef = Database.database().reference().child("Notifications")
        feedbackRef = Database.database().reference().child("Feedbacks")
    }

    public func setup() {
        print("DatabaseRef setup")
        carsRef.keepSynced(true)
        washRef.keepSynced(true)
        menuRef.keepSynced(true)
    }
}
