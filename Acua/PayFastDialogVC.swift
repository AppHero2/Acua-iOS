//
//  PayFastDialogVC.swift
//  Acua
//
//  Created by AHero on 8/13/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import SVProgressHUD

class PayFastDialogVC: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    lazy var order: Order = Order()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let orderId = order.idx!//.replacingOccurrences(of: "-", with: "")
        let orderName = AppManager.shared.getTypesString(menu: order.menu!)
        let price = order.menu!.price
        let urlString = "\(AppConst.URL_HEROKU_PAYMENT)?orderId=\(orderId)&orderName=\(orderName)&price=\(price)"
        let url = URL (string: urlString.replacingOccurrences(of: " ", with: "%20"))
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
        webView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
