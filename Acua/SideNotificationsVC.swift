//
//  SideNotificationsVC.swift
//  Acua
//
//  Created by AHero on 5/23/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

protocol NotificationDelegate {
    func didReceived(news: News)
    func didRemoved(news: News)
}

class CellSideNotification: UITableViewCell {
    
    @IBOutlet weak var badge: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        badge.layer.cornerRadius = badge.frame.size.width/2
    }
    public func updateData(notification: News) {
        lblTitle.text = notification.title
        lblMessage.text = notification.message
        lblDate.text = Util.getYesdayFormatDate(millis: notification.createdAt)
        if notification.isRead {
            badge.isHidden = true
        } else {
            badge.isHidden = false
        }
    }
}

class SideNotificationsVC: UIViewController {

    var notifications : [News] = []
    var user : User?
    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblView.estimatedRowHeight = 50.0
        self.tblView.rowHeight = UITableViewAutomaticDimension
        self.notifications = AppManager.shared.notifications
    
        AppManager.shared.notificationDelegate = self
        
        user = AppManager.shared.getUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SideNotificationsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellSideNotification", for: indexPath) as! CellSideNotification
        cell.updateData(notification: notifications[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = self.notifications[indexPath.row]
        if !notification.isRead {
            if user != nil {
                DatabaseRef.shared.notificationRef.child(user!.idx).child(notification.idx).child("isRead").setValue(true)
            }
            
            if notification.title == "Please Rate our Service" {
                //TODO: Rating feature
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if notifications.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No data available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
}

extension SideNotificationsVC: NotificationDelegate {
    func didReceived(news: News) {
        self.notifications = AppManager.shared.notifications
        self.tblView.reloadData()
    }
    
    func didRemoved(news: News) {
        self.notifications = AppManager.shared.notifications
        self.tblView.reloadData()
    }
}
