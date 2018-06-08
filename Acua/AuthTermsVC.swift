//
//  AuthTermsVC.swift
//  Acua
//
//  Created by AHero on 5/3/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

var MyObservationContext = 0

class AuthTermsVC: UIViewController {
    
    public var user : User!

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var btnAccept: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnAccept.layer.cornerRadius = AppConst.BTN_CORNER_RADIUS
        
        
        let htmlFile = Bundle.main.path(forResource: "acua_agreements", ofType: "html")
        do {
            let html = try String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            self.webView.loadHTMLString(html, baseURL: nil)
        } catch {
            print(error)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClickAgree(_ sender: Any) {
        
        let userId = user.idx
        DatabaseRef.shared.userRef.child(userId).child("uid").setValue(userId)
        DatabaseRef.shared.userRef.child(userId).child("phone").setValue(user.phone)
        DatabaseRef.shared.userRef.child(userId).child("firstname").setValue(user.firstname)
        DatabaseRef.shared.userRef.child(userId).child("lastname").setValue(user.lastname)
        DatabaseRef.shared.userRef.child(userId).child("email").setValue(user.email)
        DatabaseRef.shared.userRef.child(userId).child("userType").setValue(user.userType)
        
        AppManager.shared.saveUser(user: user)
        
        let appDelegateTemp = UIApplication.shared.delegate as? AppDelegate
        appDelegateTemp?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
    }

}
