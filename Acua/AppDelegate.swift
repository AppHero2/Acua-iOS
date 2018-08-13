//
//  AppDelegate.swift
//  Acua
//
//  Created by AHero on 5/3/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import Firebase
import SideMenu
import GooglePlaces
import GoogleMaps
import OneSignal


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSSubscriptionObserver {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSPlacesClient.provideAPIKey("AIzaSyBZ9iyjBtabbNlGRSYw0SzPAplVrtJDM-g")
        GMSServices.provideAPIKey("AIzaSyBZ9iyjBtabbNlGRSYw0SzPAplVrtJDM-g")
        
        SideMenuManager.default.menuFadeStatusBar = false
        //SideMenuManager.default.menuShadowColor = .clear
        //SideMenuManager.default.menuAnimationBackgroundColor = .clear
        
        FirebaseApp.configure()
        
        DatabaseRef.shared.setup()
        
        AppManager.shared.setup()
        
        let fireUser = Auth.auth().currentUser
        if (fireUser == nil) {
            let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AuthPhoneVC")
            self.window?.rootViewController = rootController
        } else {
            let user = AppManager.shared.getUser()
            if user == nil {
                let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AuthProfileVC")
                self.window?.rootViewController = rootController
            } else {
//                if user!.email != nil {
//                    OneSignal.setEmail(user!.email!);
//                }
            }
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload = result!.notification.payload
            let fullMessage = payload.body
            if fullMessage != "Please Rate our Service" {
                UserDefaults.standard.set(true, forKey: "notificationOpenedBlock")
                UserDefaults.standard.synchronize()
            }
            print("Message = \(String(describing: fullMessage))")
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "1f9e701b-7709-40e6-a1b6-7dff0ee29b42",
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        OneSignal.add(self as OSSubscriptionObserver)
        
        return true
    }

    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
            // get player ID
            let playerID = stateChanges.to.userId
            //let token = stateChanges.to.pushToken
            let fireUser = Auth.auth().currentUser
            if fireUser != nil {
                DatabaseRef.shared.userRef.child(fireUser!.uid).child("pushToken").setValue(playerID)
                DatabaseRef.shared.pushTokenRef.child(fireUser!.uid).setValue(playerID)
            }
        }
        print("SubscriptionStateChange: \n\(stateChanges)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to auth
        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.prod)
//        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.sandbox)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(UIBackgroundFetchResult.noData)
            return
        }
        // This notification is not auth related, developer should handle it.
    }

}

