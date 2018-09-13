//
//  SidePaymentVC.swift
//  Acua
//
//  Created by AHero on 5/23/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import SVProgressHUD

class SidePaymentVC: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var layout_status: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnVerify: UIButton!
    
    var request : URLRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnVerify.layer.cornerRadius = AppConst.BTN_CORNER_RADIUS
        
        if let user = AppManager.shared.getUser() {
            let urlString = "\(AppConst.URL_HEROKU_PAYMENT_VERIFY)?userId=\(user.idx)"
            let url = URL (string: urlString.replacingOccurrences(of: " ", with: "%20"))
            request = URLRequest(url: url!)
            
            switch user.cardStatus {
            case 0:
                layout_status.isHidden = true
                webView.loadRequest(request!)
                break
            case 1:
                layout_status.isHidden = false
                webView.isHidden = true
                lblStatus.text = "Your verified credit card token :\n\(user.cardToken ?? "-")"
                btnVerify.setTitle("Verify another card", for: .normal)
                break
            case 2:
                layout_status.isHidden = false
                webView.isHidden = true
                lblStatus.text = "Your credit card is expired"
                btnVerify.setTitle("Verify another card", for: .normal)
                break
            default:
                layout_status.isHidden = true
                webView.loadRequest(request!)
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onVerify(_ sender: Any) {
        layout_status.isHidden = true
        webView.isHidden = false
        webView.loadRequest(request!)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }

}
