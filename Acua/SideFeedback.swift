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
                let orders = AppManager.shared.selfOrders
                let sorted = orders.sorted(by: { $0.idx! < $1.idx!})
                lastOrder = sorted.last
                
                let typeString = AppManager.shared.getTypesPriceString(menu: lastOrder!.menu!)
                let timeString = Util.getYesdayFormatDate(millis: lastOrder!.beginAt)
                let priceString = " ZAR \(lastOrder!.menu!.price)"
                
                lblTime.text = timeString
                lblType.text = typeString + priceString
                
                if lastOrder!.washers.count > 0 {
                    let washerId = lastOrder?.washers.first
                    AppManager.shared.getUser(userId: washerId!) { (user) in
                        self.lblOperator.text = user?.getFullName()
                    }
                }
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
        
        let ref = DatabaseRef.shared.feedbackRef.childByAutoId()
        
        var feedbackData : [String:Any] = [:]
        feedbackData["idx"] = ref.key
        feedbackData["orderID"] = lastOrder!.idx
        feedbackData["senderID"] = lastOrder!.customerId
        feedbackData["content"] = content
        feedbackData["type"] = issueType
        feedbackData["createdAt"] = (Int)(Date().timeIntervalSince1970) * 1000
        
        AppManager.shared.getAdmins { (users) in
            for user in users {
                if user.pushToken != nil {
                    let title = "Feedback Received"
                    let message = "\(self.user!.getFullName())(\(self.user!.email!) left feedback."
                    AppManager.shared.sendPushNotificationToService(title: title, message: message)
                }
            }
        }
        
        Toast.init(text: "Feedback Sent!").show()
    }
    
    @IBAction func onClickIssues(_ sender: ISRadioButton) {
        issueType = sender.tag

        let message = Feedback.getFeedbackContent(type: issueType)
        
        // Create a custom view controller
        let ratingVC = FeedbackVC(nibName: "FeedbackVC", bundle: nil)
        ratingVC.message = message
        ratingVC.delegate = self
        
        // Create the dialog
        popup = PopupDialog(viewController: ratingVC, buttonAlignment: .horizontal, transitionStyle: .fadeIn, gestureDismissal: true)
        
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
