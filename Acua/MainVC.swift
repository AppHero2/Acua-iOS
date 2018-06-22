//
//  ViewController.swift
//  Acua
//
//  Created by AHero on 5/3/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import Parchment
import Toaster
import Firebase
import OneSignal

protocol UserStatusDelegate {
    func updatedUser(user: User)
}

class MainVC: UIViewController {

    var pagingViewController : FixedPagingViewController?
    var popup : PopupDialog?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = AppManager.shared.getUser()
        if user != nil {
            
            if let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState() {
                if let userID = status.subscriptionStatus.userId {
                    print("userID = \(userID)")
                    DatabaseRef.shared.userRef.child(user!.idx).child("pushToken").setValue(userID)
                    DatabaseRef.shared.pushTokenRef.child(user!.idx).setValue(userID)
                }
            }
            
            AppManager.shared.startTrackingOrders()
            AppManager.shared.startTrackingUser(userId: user!.idx)
            AppManager.shared.startTrackingNotification(uid: user!.idx)
         
            AppManager.shared.sideMenuDelegate = self
            AppManager.shared.userStatusDelegate = self
            AppManager.shared.bookingEventListener = self
            
            if user!.userType == 0 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let bookingVC = storyboard.instantiateViewController(withIdentifier: "BOOKING")
                let appointVC = storyboard.instantiateViewController(withIdentifier: "APPOINTMENT") as! AppointmentVC
                appointVC.delegate = self
                pagingViewController = FixedPagingViewController(viewControllers: [
                    bookingVC,
                    appointVC
                    ])
                
                // Make sure you add the PagingViewController as a child view
                // controller and contrain it to the edges of the view.
                addChildViewController(pagingViewController!)
                view.addSubview(pagingViewController!.view)
                view.constrainToEdges(pagingViewController!.view)
                pagingViewController!.didMove(toParentViewController: self)
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let statisticVC = storyboard.instantiateViewController(withIdentifier: "STATISTIC")
                let appointVC = storyboard.instantiateViewController(withIdentifier: "APPOINTMENT")
                pagingViewController = FixedPagingViewController(viewControllers: [
                    statisticVC,
                    appointVC
                    ])
                
                // Make sure you add the PagingViewController as a child view
                // controller and contrain it to the edges of the view.
                addChildViewController(pagingViewController!)
                view.addSubview(pagingViewController!.view)
                view.constrainToEdges(pagingViewController!.view)
                pagingViewController!.didMove(toParentViewController: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func shareApp() {
        let textToShare = "Spend time on what matters. Have your car professionally washed at home with acuar. Download the app at: https://itunes.apple.com/us/app/acuar/id1386096453?ls=1&mt=8 (You can also download the app via Google Play Store: https://play.google.com/store/apps/details?id=com.acua.app)"
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
}

extension MainVC: AppointmentVCDelegate {
    func onClickFeedback() {
        self.presentFeedbackVC()
    }
    
    func onClickRating() {
        self.showRatingDialog()
    }
    
    func onClickUpdateBooking(order: Order) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "BookingUpdateVC") as! BookingUpdateVC
        vc.order = order
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension MainVC: UserStatusDelegate {
    func updatedUser(user: User) {
        
    }
}

extension MainVC: BookingEventListener {
    func didBooking(success: Bool) {
        if success {
            pagingViewController?.select(index: 1)
        }
    }
}

extension MainVC: RatingVCDelegate {
    
    func showRatingDialog(){
        // Create a custom view controller
        let ratingVC = RatingVC(nibName: "RatingVC", bundle: nil)
        ratingVC.delegate = self
        
        // Create the dialog
        popup = PopupDialog(viewController: ratingVC, buttonAlignment: .horizontal, transitionStyle: .fadeIn, gestureDismissal: true)
        
        // Present dialog
        present(popup!, animated: true, completion: nil)
    }
    
    func onSubmitted(score: Double, content: String) {
        if let user = AppManager.shared.getUser() {
            let title = "\(user.getFullName()) left service rating as \(score)"
            
            let query = DatabaseRef.shared.userRef.queryOrdered(byChild: "userType").queryEqual(toValue: 2) // admin
            query.observeSingleEvent(of: .value) { (snapshot) in
                var receivers : [String] = []
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? DataSnapshot {
                    let dic = rest.value as? [String:Any] ?? [:]
                    let user = User(data: dic)
                    if user.pushToken != nil {
                        receivers.append(user.pushToken!)
                    }
                    let ref = DatabaseRef.shared.notificationRef.child(user.idx).childByAutoId()
                    let notificationData : [String:Any] = ["idx": ref.key,
                                                           "title": title,
                                                           "message": content,
                                                           "createdAt": (Int)(Date().timeIntervalSince1970*1000),
                                                           "isRead": false]
                    ref.setValue(notificationData)
                }
                
                AppManager.shared.sendOneSignalPush(recievers: receivers, title: title, message: content)
            }
            
        }
        
        popup?.dismiss()
    }
    func onCancelled() {
        popup?.dismiss()
    }
}

extension MainVC: SideMenuDelegate {
    
    func presentFeedbackVC() {
        if let user = AppManager.shared.getUser() {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "SideFeedback")
            if user.userType == 0 {
                if AppManager.shared.selfOrders.count > 0 {
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    Toast(text: "You have no previous appointment.").show()
                }
            } else {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func onProfile() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SideProfileVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func onNotification() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SideNotificationsVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func onPayment() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SidePaymentVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func onShare() {
        shareApp()
    }
    func onFeedback() {
        self.presentFeedbackVC()
    }
    func onWhere() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SideWhereVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func onAgreement() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SideAgreementsVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
