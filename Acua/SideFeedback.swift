//
//  SideFeedback.swift
//  Acua
//
//  Created by AHero on 5/23/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import Toaster

class SideFeedbackCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblContent: UILabel!
}

class SideFeedback: UIViewController {

    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblOperator: UILabel!
    
    var popup : PopupDialog?
    @IBOutlet weak var issue1: ISRadioButton!
    @IBOutlet weak var tblView: UITableView!
    
    var feedbacks : [Feedback] = []
    var user : User?
    var lastOrder : Order?
    var issueType : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        user = AppManager.shared.getUser()
        if user != nil {
            if user!.userType == 0 // normal
            {
                lastOrder = AppManager.shared.lastFeedbackOrder
                
                let typeString = AppManager.shared.getTypesString(menu: lastOrder!.menu!)
                let timeString = Util.getYesdayFormatDate(millis: lastOrder!.completedAt)
                let priceString = " ZAR \(lastOrder!.menu!.price)"
                
                lblTime.text = timeString
                lblType.text = typeString + priceString
                
            }
            else // admin
            {
                self.tblView.isHidden = false
                self.tblView.estimatedRowHeight = 100.0
                self.tblView.rowHeight = UITableViewAutomaticDimension
                
                startTrackingFeedback()
            }
        }
    }

    deinit {
        DatabaseRef.shared.feedbackRef.removeAllObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startTrackingFeedback()
    {
        DatabaseRef.shared.feedbackRef.observe(.childAdded) { (snapshot) in
            let dic = snapshot.value as? [String:Any] ?? [:]
            let feedback = Feedback(data: dic)
            self.feedbacks.append(feedback)
            self.tblView.reloadData()
        }
    }
    
    func submitFeedback(content:String) {
        
        let subject = Feedback.getFeedbackTitle(type: issueType)
        
        let html = content + "\n\n"
                    + "\(self.user!.getFullName())\n(\(self.user!.email ?? "(no email)")\n"
                    + self.user!.phone! + "\n"
                    + AppManager.shared.getTypesString(menu: lastOrder!.menu!) + "\n"
                    + Util.getFullTimeString(millis: lastOrder!.completedAt)
        
        AppManager.shared.sendEmailPushToADMIN(subject: subject, text: subject, html: html) { (result) in
            if result {
                Toast.init(text: "Your feedback has been sent successfully.").show()
            } else {
                Toast.init(text: "Failed to send your feedback. Please try again...").show()
            }
        }
       
    }
    
    @IBAction func onClickIssues(_ sender: ISRadioButton) {
        issueType = sender.tag

        let message = Feedback.getFeedbackContent(type: issueType)
        
        // Create a custom view controller
        let feedbackVC = FeedbackVC(nibName: "FeedbackVC", bundle: nil)
        feedbackVC.message = message
        feedbackVC.delegate = self
        
        // Create the dialog
        popup = PopupDialog(viewController: feedbackVC, buttonAlignment: .horizontal, transitionStyle: .fadeIn, gestureDismissal: true)
        
        // Present dialog
        present(popup!, animated: true, completion: nil)
        
    }

}

extension SideFeedback : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedbacks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideFeedbackCell", for: indexPath) as! SideFeedbackCell
        let feedback = self.feedbacks[indexPath.row]
        cell.lblTitle.text = Feedback.getFeedbackTitle(type: feedback.type)
        cell.lblContent.text = feedback.content
        cell.lblTime.text = Util.getYesdayFormatDate(millis: feedback.createdAt)
        return cell
    }
}

extension SideFeedback : FeedbackDelegate {
    func onSubmitted(content: String) {
        submitFeedback(content: content)
        popup?.dismiss()
    }
    func onCancelled() {
        popup?.dismiss()
    }
}
