//
//  SideAgreementsVC.swift
//  Acua
//
//  Created by AHero on 5/23/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

class SideAgreementsVC: UIViewController {

    @IBOutlet weak var lblContent: UILabel!
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let htmlFile = Bundle.main.path(forResource: "acua_agreements", ofType: "html")
        do {
            let html = try String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let prefix = "<style>* { font-family: \("Helvetica"); font-size: 14px; color: #3f3f3f;}</style>"
            let attrStr = (prefix + html).htmlToAttributedString
            lblContent.attributedText = attrStr
        } catch {
            print(error)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes:nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
