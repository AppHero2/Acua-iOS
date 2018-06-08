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

protocol UserStatusDelegate {
    func updatedUser(user: User)
}

class MainVC: UIViewController {

    var pagingViewController : FixedPagingViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = AppManager.shared.getUser()
        if user != nil {
            AppManager.shared.startTrackingOrders()
            AppManager.shared.startTrackingUser(userId: user!.idx)
            AppManager.shared.startTrackingNotification(uid: user!.idx)
         
            AppManager.shared.sideMenuDelegate = self
            AppManager.shared.userStatusDelegate = self
            AppManager.shared.bookingEventListener = self
            
            if user!.userType == 0 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let bookingVC = storyboard.instantiateViewController(withIdentifier: "BOOKING")
                let appointVC = storyboard.instantiateViewController(withIdentifier: "APPOINTMENT")
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
        let textToShare = "Spend time on what matters. Have your car professionally washed at home with acuar. Download the app at: https://itunes.apple.com/us/app/acuar/id1386096453?ls=1&mt=8"
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
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
extension MainVC: SideMenuDelegate {
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
    func onWhere() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SideWhereVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func onAgreement() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SideAgreementsVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
