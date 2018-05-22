//
//  ViewController.swift
//  Acua
//
//  Created by AHero on 5/3/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import Parchment

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load each of the view controllers you want to embed
        // from the storyboard.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let bookingVC = storyboard.instantiateViewController(withIdentifier: "BOOKING")
        let appointVC = storyboard.instantiateViewController(withIdentifier: "APPOINTMENT")
        
        // Initialize a FixedPagingViewController and pass
        // in the view controllers.
        let pagingViewController = FixedPagingViewController(viewControllers: [
            bookingVC,
            appointVC
            ])
        
        // Make sure you add the PagingViewController as a child view
        // controller and contrain it to the edges of the view.
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
        
        AppManager.shared.sideMenuDelegate = self
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
extension MainVC: SideMenuDelegate {
    func onProfile() {
        
    }
    func onNotification() {
        
    }
    func onPayment() {
        
    }
    func onShare() {
        shareApp()
    }
    func onFeedback() {
        
    }
    func onWhere() {
        
    }
    func onAgreement() {
        
    }
}
