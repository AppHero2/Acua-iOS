//
//  SideAgreementsVC.swift
//  Acua
//
//  Created by AHero on 5/23/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

class SideAgreementsVC: UIViewController {

   
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    

}
