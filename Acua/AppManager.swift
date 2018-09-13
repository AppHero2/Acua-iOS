//
//  AppManager.swift
//  Acua
//
//  Created by AHero on 5/5/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import Firebase
import OneSignal
import Alamofire

class AppManager: NSObject {
    
    static let shared = AppManager()
    
    public var carTypes : [Car] = []
    public var washTypes : [Wash] = []
    public var menuList : [Menu] = []
    
    public var carTypeDelegate : CarTypeDelegate?
    public var washTypeDelegate : WashTypeDelegate?
    public var menuListDelegate : MenuListDelegate?
    public var orderListDelegate : OrderListDelegate?
    public var sideMenuDelegate : SideMenuDelegate?
    public var userStatusDelegate : UserStatusDelegate?
    public var notificationDelegate : NotificationDelegate?
    public var bookingEventListener : BookingEventListener?
    public var ratingEventListener : RatingEventListener?
    
    public var orderList : [Order] = []
    public var selfOrders : [Order] = []
    public var lastFeedbackOrder : Order?
    
    public var notifications: [News] = []
    
    public var mapLocation : Location?
    
    var handleOrderList : UInt = 0
    
    override init() {
        super.init()
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
            self.menuListDelegate?.didLoaded(menuList: self.menuList)
        })
    }
    
    public func startTrackingUser(userId: String) {
        DatabaseRef.shared.userRef.child(userId).observe(.value, with: { (snapshot) in
            let dic = snapshot.value as? [String:Any] ?? [:]
            let user = User(data: dic)
            self.saveUser(user: user)
            self.userStatusDelegate?.updatedUser(user: user)
        })
    }
    
    public func startTrackingOrders() {
        if handleOrderList != 0 {
            return
        }
        
        let userId = Auth.auth().currentUser?.uid ?? "?"
        
        handleOrderList = DatabaseRef.shared.ordersRef.observe(.value, with: { (snapshot) in
            self.orderList.removeAll()
            self.selfOrders.removeAll()
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let id = rest.key
                let dic = rest.value as? [String:Any] ?? [:]
                let order = Order.init(data: dic)
                order.idx = id
                self.orderList.append(order)
                if order.customerId == userId {
                    self.selfOrders.append(order)
                }
            }
            
            self.orderList.sort(by: {$0.beginAt > $1.beginAt})
            self.selfOrders.sort(by: {$0.beginAt > $1.beginAt})
            
            self.orderListDelegate?.didLoaded(orderList: self.orderList)
        })
    }
    
    public func stopTrackingOrders() {
        DatabaseRef.shared.ordersRef.removeObserver(withHandle: handleOrderList)
    }
    
    public func startTrackingNotification(uid: String) {
        DatabaseRef.shared.notificationRef.child(uid).observe(.childAdded, with: {(snapshot) in
            let dic = snapshot.value as? [String:Any] ?? [:]
            let news = News(data: dic)
            if news.title == "Please Rate our Service" {
                self.ratingEventListener?.onRatingEventReqired(news: news)
            } else {
                self.notifications.append(news)
            }
        
            self.notifications.sort(by: {$0.createdAt > $1.createdAt})
            
            self.notificationDelegate?.didReceived(news: news)
        })
        DatabaseRef.shared.notificationRef.child(uid).observe(.childChanged, with: {(snapshot) in
            let dic = snapshot.value as? [String:Any] ?? [:]
            let news = News(data: dic)
            for notification in self.notifications {
                if notification.idx == news.idx {
                    notification.updateData(data: dic)
                    break
                }
            }
            self.notificationDelegate?.didReceived(news: news)
        })
        DatabaseRef.shared.notificationRef.child(uid).observe(.childRemoved, with: {(snapshot) in
            let dic = snapshot.value as? [String:Any] ?? [:]
            let news = News(data: dic)
            for index in 0..<self.notifications.count {
                let notification = self.notifications[index]
                if notification.idx == news.idx {
                    self.notifications.remove(at: index)
                    break
                }
            }
            self.notificationDelegate?.didRemoved(news: news)
        })
    }
    
    public func getUser(userId:String, callback: @escaping (User?)->())
    {
        let query = DatabaseRef.shared.userRef.queryOrdered(byChild: "uid").queryEqual(toValue: userId) // operator
        query.observeSingleEvent(of: .value) { (snapshot) in
            var existUser : User?
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let dic = rest.value as? [String:Any] ?? [:]
                let user = User(data: dic)
                if user.idx == userId {
                    existUser = user
                    break
                }
            }
            callback(existUser)
        }
    }
    
    public func getAdmins(callback: @escaping([User])->())
    {
        let query = DatabaseRef.shared.userRef.queryOrdered(byChild: "userType").queryEqual(toValue: 2)
        query.observeSingleEvent(of: .value) { (snapshot) in
            var admins : [User] = []
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let dic = rest.value as? [String:Any] ?? [:]
                let user = User(data: dic)
                admins.append(user)
            }
            callback(admins)
        }
    }
    
    public func getTypesPriceString(menu: Menu) -> String {
        let types = menu.getId().split(separator: "_")
        let washID = types[0]
        let carID = types[1]
        var washName = ""
        var carName = ""
        for wash in AppManager.shared.washTypes {
            if wash.getId() == washID {
                washName = wash.getName()
                break
            }
        }
        for car in AppManager.shared.carTypes {
            if car.getId() == carID {
                carName = car.getName()
                break
            }
        }
        
        let full = "\(carName), \(washName) ZAR\(menu.price)"
        return full
    }
    
    public func getTypesString(menu: Menu) -> String {
        let types = menu.getId().split(separator: "_")
        let washID = types[0]
        let carID = types[1]
        var washName = ""
        var carName = ""
        for wash in AppManager.shared.washTypes {
            if wash.getId() == washID {
                washName = wash.getName()
                break
            }
        }
        for car in AppManager.shared.carTypes {
            if car.getId() == carID {
                carName = car.getName()
                break
            }
        }
        
        let full = "\(carName), \(washName)"
        return full
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
        UserDefaults.standard.set(user.cardStatus, forKey: "cardStatus")
        UserDefaults.standard.set(user.cardToken, forKey: "cardToken")
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
        userData["cardStatus"] = UserDefaults.standard.integer(forKey: "cardStatus")
        userData["cardToken"] = UserDefaults.standard.string(forKey: "cardToken")
        
        if userData["uid"] == nil {
            return nil
        } else {
            return User(data: userData)
        }
    }
    
    public func deleteUser() {
        UserDefaults.standard.set(nil, forKey: "uid")
    }
    
    public func sendPushNotificationToService(title: String, message: String) {
        let query = DatabaseRef.shared.userRef.queryOrdered(byChild: "userType").queryStarting(atValue: 1) // operator & admin
        query.observeSingleEvent(of: .value) { (snapshot) in
            var receivers : [String] = []
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let dic = rest.value as? [String:Any] ?? [:]
                let user = User(data: dic)
                if user.pushToken != nil {
                    receivers.append(user.pushToken!)
                }
            }
            
            self.sendOneSignalPush(recievers: receivers, title: title, message: message)
        }
    }
    
    public func sendOneSignalPush(recievers:[String], title: String, message: String) {
        
        OneSignal.postNotification(["headings": ["en": title],
                                    "contents": ["en": message],
                                    "include_player_ids": recievers])
    }
    
    public func sendEmailPushToADMIN(subject:String, text:String, html:String, completion: @escaping (_ result: Bool)->()) {
        
        let url = AppConst.URL_HEROKU_BASE + "email/send"
        
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let params:[String: Any] = ["subject" : subject, "text" : text, "html": html]
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
            let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
                if let response = response {
                    let nsHTTPResponse = response as! HTTPURLResponse
                    let statusCode = nsHTTPResponse.statusCode
                    print ("status code = \(statusCode)")
                }
                
                if let error = error {
                    print ("\(error)")
                    completion(false)
                }else{
                    completion(true)
                }
                
                if let data = data {
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                        print ("data = \(jsonResponse)")
                    }catch _ {
                        print ("OOps not good JSON formatted response")
                    }
                }
            })
            task.resume()
        }catch _ {
            print ("Oops something happened buddy")
        }
    }
    
    public func makePayment(token:String, item:String, amount:String, completion: @escaping (_ result: Bool)->()) {
        let url = "https://api.payfast.co.za/subscriptions/\(token)/adhoc"
        
        let timestamp = Util.getISO8601()
        
        var params : [String:String] = [:]
        params["merchant-id"] = "12925581"
        params["passphrase"] = "abcdEFGH12345"
        params["timestamp"] = timestamp
        params["version"] = "v1"
        params["item_name"] = item
        params["amount"] = amount
        
        let signature = generateSignature(params: params)
        
        let body : [String: String] = ["amount":amount,
                                       "item_name":item]
        
        let headers : HTTPHeaders = ["merchant-id":"12925581",
                                     "version":"v1",
                                     "timestamp":timestamp,
                                     "signature":signature]
        
        Alamofire.request(url, method: HTTPMethod.post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            print(response.result.value ?? "?")
            if let value = response.result.value as? [String:Any] {
                let code = value["code"] as? Int ?? 0
                if code == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private func generateSignature(params:[String:String]) -> String {
        
        var pfParamString = ""
        let sortedKeys = Array(params.keys).sorted()
        
        var i = 0
        for key in sortedKeys {
            let value = params[key] ?? "?"
            
            if i >= (sortedKeys.count-1) {
                pfParamString += "\(key)=\(URLEncodedString.URLEncode(string: value))"
            } else {
                pfParamString += "\(key)=\(URLEncodedString.URLEncode(string: value))&"
            }
            i += 1
        }
        
        return Util.md5(pfParamString)
    }
    
    private func urlEncodedString(str:String) -> String{
        let value = str.replacingOccurrences(of: " ", with: "+")
        return value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? str
    }
}
