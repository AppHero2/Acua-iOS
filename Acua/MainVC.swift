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
import StoreKit

protocol UserStatusDelegate {
    func updatedUser(user: User)
}

protocol RatingEventListener {
    func onRatingEventReqired(news: News)
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
            
            AppManager.shared.sideMenuDelegate = self
            AppManager.shared.userStatusDelegate = self
            AppManager.shared.bookingEventListener = self
            AppManager.shared.ratingEventListener = self
            
            AppManager.shared.startTrackingOrders()
            AppManager.shared.startTrackingUser(userId: user!.idx)
            AppManager.shared.startTrackingNotification(uid: user!.idx)
            
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
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appDidBecomeActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc func appDidBecomeActive() {
        let clickedNotification = UserDefaults.standard.bool(forKey: "notificationOpenedBlock")
        if clickedNotification {
            self.onNotification()
            UserDefaults.standard.set(false, forKey: "notificationOpenedBlock")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func shareApp() {
        let textToShare = "Have your car professionally washed at home or at the office with Acuar.\n" +
            "\n" +
            "Download the Acuar App on:\n" +
            "the App Store: https://itunes.apple.com.us/app/acuar/id386096453?ls=1&mt=8\n" +
            "Google Play Store: https;//play.google.com/store/apps/details?id=com.acua.app\n" +
            "\n" +
            "Spend time on what matters"
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
}

extension MainVC: AppointmentVCDelegate {
    
    func onClickPayFor(order: Order) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "PayFastDialogVC") as! PayFastDialogVC
        vc.order = order
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
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

extension MainVC: RatingVCDelegate , RatingEventListener {
    
    func onRatingEventReqired(news: News) {
        if !news.isRead {
            self.showRatingDialog()
            if let user = AppManager.shared.getUser() {
                DatabaseRef.shared.notificationRef.child(user.idx).child(news.idx).child("isRead").setValue(true)
            }
        }
    }
    
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
            
            let html = content
            
            AppManager.shared.sendEmailPushToADMIN(subject: title, text: title, html: html){ (result) in
                if result {
                    Toast.init(text: "Your rating has been sent successfully.").show()
                } else {
                    Toast.init(text: "Failed to send your rating. Please try again...").show()
                }
                
                self.showAppRating()
            }
            
        }
        
        popup?.dismiss()
    }
    func onCancelled() {
        popup?.dismiss()
    }
    
    func showAppRating() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            let appID = "1386096453"
            let rateURL = URL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(appID)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8")!
            if UIApplication.shared.canOpenURL(rateURL) {
                UIApplication.shared.openURL(rateURL)
            }
        }
    }
}

extension MainVC: SideMenuDelegate {
    
    func presentFeedbackVC() {
        if let user = AppManager.shared.getUser() {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "SideFeedback")
            if user.userType == 0 {
                AppManager.shared.lastFeedbackOrder = nil
                var selfOrders : [Order] = []
                for order in AppManager.shared.selfOrders {
                    selfOrders.append(order)
                }
                selfOrders.sort(by: {$0.completedAt > $1.completedAt})
                for index in (0..<selfOrders.count) {
                    let order = AppManager.shared.selfOrders[index]
                    if order.serviceStatus == .COMPLETED, order.completedAt > 0 {
                        AppManager.shared.lastFeedbackOrder = order
                        break;
                    }
                }
                
                if AppManager.shared.lastFeedbackOrder != nil {
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
