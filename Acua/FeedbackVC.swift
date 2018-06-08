//
//  FeedbackVC.swift
//  Acua
//
//  Created by AHero on 6/6/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import Toaster

protocol FeedbackDelegate {
    func onSubmitted(content:String)
    func onCancelled()
}

class FeedbackVC: UIViewController {

    public var delegate : FeedbackDelegate?
    public var message : String?
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var tvFeedback: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tvFeedback.placeholder = "Please write your feedback."
        lblMessage.text = message
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onSubmit(_ sender: Any) {
        if let content = tvFeedback.text {
            delegate?.onSubmitted(content: content)
        } else {
            Toast.init(text: "Please type your feedback").show()
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        delegate?.onCancelled()
    }
}
