//
//  SideMenuVC.swift
//  Acua
//
//  Created by AHero on 5/22/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import SDWebImage

class SideMenuCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
}

protocol SideMenuDelegate {
    func onProfile()
    func onNotification()
    func onPayment()
    func onShare()
    func onFeedback()
    func onWhere()
    func onAgreement()
}

class SideMenuVC: UIViewController {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var tblView: UITableView!
    
    var menus = ["Profile", "Notifications", "Payment", "Share app with friends", "Feedback", "Where are we?", "Agreement"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let user = AppManager.shared.getUser()
        if user != nil {
            // hide feedback for admins, operators
            if user!.userType >= 1 {
                menus = ["Profile", "Notifications", "Payment", "Share app with friends", "Where are we?", "Agreement"]
            }
        }
        
        let version = Bundle.main.releaseVersionNumber
        let build = Bundle.main.buildVersionNumber
        lblVersion.text = "acuar\(version)(\(build)) Copyright © 2018"
        
        imgProfile.layer.masksToBounds = false
        imgProfile.layer.cornerRadius = imgProfile.frame.size.height/2
        imgProfile.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUserData()
    }
    
    private func setUserData () {
        let user = AppManager.shared.getUser()
        if user != nil {
            lblFullName.text = user!.getFullName()
            lblEmail.text = user!.email
            
            self.imgProfile.sd_setImage(with: URL(string: user!.photo ?? ""), placeholderImage: #imageLiteral(resourceName: "ic_profile_person"))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SideMenuVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell
        cell.lblTitle.text = menus[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dismiss(animated: true, completion: {
            switch indexPath.row {
            case 0:
                // profile
                AppManager.shared.sideMenuDelegate?.onProfile()
                break
            case 1:
                // notifications
                AppManager.shared.sideMenuDelegate?.onNotification()
                break
            case 2:
                // payment
                AppManager.shared.sideMenuDelegate?.onPayment()
                break
            case 3:
                // share app
                AppManager.shared.sideMenuDelegate?.onShare()
                break
            case 4:
                // feedback
                AppManager.shared.sideMenuDelegate?.onFeedback()
                break
            case 5:
                // where are we?
                AppManager.shared.sideMenuDelegate?.onWhere()
                break
            case 6:
                // agreements
                AppManager.shared.sideMenuDelegate?.onAgreement()
                break
            default:
                break
            }
        })
    }
}
