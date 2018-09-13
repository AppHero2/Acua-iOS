//
//  AppointmentVC.swift
//  Acua
//
//  Created by AHero on 5/3/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import Firebase
import Toaster
import SVProgressHUD

protocol OrderListDelegate {
    func didLoaded(orderList: [Order])
}

protocol CellOrderDelegate {
    func onLocation(location : Location)
    func onAction(order: Order, customer: User)
}

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    default:
        return !(rhs < lhs)
    }
}



public class CellOrderSelf: UITableViewCell, DefaultNotificationCenterDelegate {
    
    @IBOutlet weak var lblTypes: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblSchedule: UILabel!
    @IBOutlet weak var lblRemain: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    private var order: Order?
    
    var countdownTime : Int?    = 0
    var currentTimeString : String {
        get {
            if order != nil {
                if order?.serviceStatus == ServiceStatus.COMPLETED {
                    if order?.payStatus == PayStatus.PAID {
                        return "paid"
                    } else {
                        return "service\ncompleted"
                    }
                }
                
                if order?.serviceStatus == ServiceStatus.ENGAGED {
                    return "Engaged"
                }
            }
            
            return Util.getRemainFormatDate(millis: countdownTime!)
        }
    }
    
    fileprivate var notificationCenter : DefaultNotificationCenter = DefaultNotificationCenter()

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        notificationCenter.addNotificationName("countDownTimeCellCountDown")
        notificationCenter.delegate = self
    }
    
    func defaultNotificationCenter(_ notificationName: String, object: AnyObject?) {
        if notificationName == "countDownTimeCellCountDown" {
           countDown()
        }
    }
    
    func countDown() {
        countdownTime = countdownTime! - 1
        lblRemain.text = currentTimeString
    }
    
    public func updateData(order: Order) {
        self.order = order
        
        lblTypes.text = AppManager.shared.getTypesPriceString(menu: order.menu!)
        lblAddress.text = order.location!.name
        lblSchedule.text = "\(Util.getSimpleDateString(millis: order.beginAt)) ~ \(Util.getSimpleTimeString(millis: order.endAt))"
        lblStatus.text = order.serviceStatus.description
        let current = Int(Date().timeIntervalSince1970)
        countdownTime = (order.endAt/1000 - current)
        
//        if self.order?.serviceStatus == ServiceStatus.COMPLETED && self.order?.payStatus != PayStatus.PAID {
//            lblRemain.isHidden = true
//        } else {
//            lblRemain.isHidden = false
//        }
        
//        if self.order?.payStatus == PayStatus.PAID {
//            lblStatus.text = "Paid"
//        }
    }

}



public class CellOrderAdmin: UITableViewCell, DefaultNotificationCenterDelegate {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblTypes: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblSchedule: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblRemain: UILabel!
    @IBOutlet weak var viewLocation: UIView!
    @IBOutlet weak var viewPhone: UIView!
    @IBOutlet weak var icLocation: UIImageView!
    @IBOutlet weak var icPhone: UIImageView!
    @IBOutlet weak var btnAction: UIButton!
    
    private var order: Order?
    private var customer : User?
    
    var delegate : CellOrderDelegate?
    
    var countdownTime : Int?    = 0
    var currentTimeString : String {
        get {
            if order != nil {
                if order?.serviceStatus == ServiceStatus.COMPLETED {
                    return "service\ncompleted"
                }
                
                if order?.serviceStatus == ServiceStatus.ENGAGED {
                    return "Engaged"
                }
            }
            
            return Util.getRemainFormatDate(millis: countdownTime!)
        }
    }
    
    fileprivate var notificationCenter : DefaultNotificationCenter = DefaultNotificationCenter()
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        notificationCenter.addNotificationName("countDownTimeCellCountDown")
        notificationCenter.delegate = self
    }
    
    func defaultNotificationCenter(_ notificationName: String, object: AnyObject?) {
        if notificationName == "countDownTimeCellCountDown" {
            countDown()
        }
    }
    
    func countDown() {
        countdownTime = countdownTime! - 1
        lblRemain.text = currentTimeString
    }
    
    public override func awakeFromNib() {
        viewLocation.layer.cornerRadius  = viewLocation.frame.width/2
        viewPhone.layer.cornerRadius = viewPhone.frame.width/2
        btnAction.layer.cornerRadius = AppConst.BTN_CORNER_RADIUS
        Util.setImageTintColor(imgView: icLocation, color: .white)
        Util.setImageTintColor(imgView: icPhone, color: .white)
        
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width/2
        imgProfile.layer.masksToBounds = true
    }
    
    public func updateData(order: Order) {
        self.order = order
        
        if self.order != nil {
            AppManager.shared.getUser(userId: self.order!.customerId!) { (user) in
                if user != nil {
                    self.customer = user
                    self.lblUsername.text = user!.getFullName()
                    self.imgProfile.sd_setImage(with: URL(string: user!.photo ?? ""), placeholderImage: #imageLiteral(resourceName: "ic_profile_person"))
                }
            }
        }
        
        lblTypes.text = AppManager.shared.getTypesPriceString(menu: order.menu!)
        lblAddress.text = order.location!.name
        lblSchedule.text = "\(Util.getSimpleDateString(millis: order.beginAt)) ~ \(Util.getSimpleTimeString(millis: order.endAt))"
        lblStatus.text = order.serviceStatus.description
        let current = Int(Date().timeIntervalSince1970)
        countdownTime = (order.endAt/1000 - current)
        
        if order.serviceStatus == .BOOKED {
            lblStatus.text = "In Complete"
            btnAction.isHidden = false
            btnAction.setTitle("Engage", for: .normal)
        } else if order.serviceStatus == .ENGAGED {
            lblStatus.text = "In Progress"
            btnAction.isHidden = false
            btnAction.setTitle("Done", for: .normal)
        } else {
            lblStatus.text = "Completed"
            btnAction.isHidden = true
            if (order.payStatus == .PAID) {
                lblStatus.text = "Paid"
            }
        }
    }
    
    @IBAction func onClickLocation(_ sender: Any) {
        if self.order != nil {
            self.delegate?.onLocation(location: self.order!.location!)
        }
    }
    
    @IBAction func onClickPhone(_ sender: Any) {
        if self.customer != nil {
            if let url = URL(string: "tel://\(customer!.phone!)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    @IBAction func onClickAction(_ sender: Any) {
        if self.order != nil {
            self.delegate?.onAction(order: self.order!, customer: self.customer!)
        }
    }
}

protocol AppointmentVCDelegate {
    func onClickRating()
    func onClickFeedback()
    func onClickUpdateBooking(order:Order)
}

class AppointmentVC: UITableViewController {

    public var delegate : AppointmentVCDelegate?
    var orderList : [Order] = []
    var user : User!
    
    fileprivate var secondsTimer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AppManager.shared.orderListDelegate = self
        
        user = AppManager.shared.getUser()
        
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        // Init timer.
        secondsTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerEvent), userInfo: nil, repeats: true)
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.view.addGestureRecognizer(longPressRecognizer)
    }

    @objc func timerEvent() {
        DefaultNotificationCenter.PostMessageTo("countDownTimeCellCountDown")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if secondsTimer == nil {
            secondsTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerEvent), userInfo: nil, repeats: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if secondsTimer != nil {
            secondsTimer?.invalidate()
            secondsTimer = nil
        }
    }

    @objc func refresh(refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == .began {
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                print(indexPath)
                let order = orderList[indexPath.row]
                if user.userType == 0 {
                    
                    if order.serviceStatus == .COMPLETED {
                        
                        let alert = UIAlertController(title: "Would you like to:", message: nil, preferredStyle: .actionSheet)
                        
                        alert.addAction(UIAlertAction(title: "Rate Service", style: .default , handler:{ (UIAlertAction)in
                            DispatchQueue.main.async {
                                self.delegate?.onClickRating()
                            }
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Leave Feedback", style: .default , handler:{ (UIAlertAction)in
                            DispatchQueue.main.async {
                                self.delegate?.onClickFeedback()
                            }
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    else {
                        
                        let alert = UIAlertController(title: "Change of Plans?", message: nil, preferredStyle: .actionSheet)
                        
                        alert.addAction(UIAlertAction(title: "Update Booking", style: .default , handler:{ (UIAlertAction)in
                            DispatchQueue.main.async {
                                self.delegate?.onClickUpdateBooking(order: order)
                            }
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Withdraw Booking", style: .default , handler:{ (UIAlertAction)in
                            DispatchQueue.main.async {
                                self.confirmToWithdraw(order: order)
                            }
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    
                }
            }
        }
    }
    
    func confirmToWithdraw(order: Order) -> Void {
        let confirmAlert = UIAlertController(title: "Are you sure?", message: "Do you really want to withdraw this order?", preferredStyle: .alert)
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        confirmAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            DatabaseRef.shared.ordersRef.child(order.idx!).removeValue()
        }))
        self.present(confirmAlert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orderList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if user.userType == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellOrderSelf", for: indexPath) as! CellOrderSelf
            cell.updateData(order: self.orderList[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellOrderAdmin", for: indexPath) as! CellOrderAdmin
            cell.updateData(order: self.orderList[indexPath.row])
            cell.delegate = self
            return cell
        }
    }
}

extension AppointmentVC: CellOrderDelegate {
    func onLocation(location: Location) {
        AppManager.shared.mapLocation = location
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "MapNC")
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func onAction(order: Order, customer: User) {
        
        if order.serviceStatus == .BOOKED {
            order.serviceStatus = .ENGAGED
            order.washers.append(user.idx)
            let dic = order.toAnyObject()
            SVProgressHUD.show()
            DatabaseRef.shared.ordersRef.child(order.idx!).updateChildValues(dic) { (error, ref) in
                SVProgressHUD.dismiss()
                if let error = error {
                    print("Data could not be saved: \(error).")
                } else {
                    Toast(text: "You accepted booking!").show()
                    
                    let title = "We are on the way!"
                    let message = "Our acuar operators are on the way..."
                    
                    if order.customerPushToken != nil {
                        AppManager.shared.sendOneSignalPush(recievers: [order.customerPushToken!], title: title, message: message)
                    }
                    
                    let ref = DatabaseRef.shared.notificationRef.child(order.customerId!).childByAutoId()
                    let notificationData : [String:Any] = ["idx": ref.key,
                                                           "title": title,
                                                           "message": message,
                                                           "createdAt": (Int)(Date().timeIntervalSince1970*1000),
                                                           "isRead": false]
                    ref.setValue(notificationData)
                }
            }
            
        } else if (order.serviceStatus == .ENGAGED) {
            SVProgressHUD.show()
            let item = AppManager.shared.getTypesString(menu: order.menu!)
            let amount = "\((Int)((order.menu?.getPrice())! * 100))"
            let token = customer.cardToken ?? "-"
            AppManager.shared.makePayment(token: token, item: item, amount: amount) { (success) in
                if success {
                    order.serviceStatus = .COMPLETED
                    let dic = order.toAnyObject()
                    
                    DatabaseRef.shared.ordersRef.child(order.idx!).updateChildValues(dic) { (error, ref) in
                        SVProgressHUD.dismiss()
                        if let error = error {
                            print("Data could not be saved: \(error).")
                        } else {
                            Toast(text: "Booking has been completed!").show()
                            
                            let title = "acuar experience complete!"
                            let message = "Thank you for choosing acuar. Keep safe until we meet again"
                            
                            if order.customerPushToken != nil {
                                AppManager.shared.sendOneSignalPush(recievers: [order.customerPushToken!], title: title, message: message)
                            }
                            
                            let ref = DatabaseRef.shared.notificationRef.child(order.customerId!).childByAutoId()
                            let notificationData : [String:Any] = ["idx": ref.key,
                                                                   "title": title,
                                                                   "message": message,
                                                                   "createdAt": (Int)(Date().timeIntervalSince1970*1000),
                                                                   "isRead": false]
                            ref.setValue(notificationData)
                        }
                    }
                    
                    DatabaseRef.shared.ordersRef.child(order.idx!).child("payStatus").setValue(PayStatus.PAID.description)
                    
                }
                else {
                    SVProgressHUD.dismiss()
                    Toast(text: "Payment failed").show()
                }
            }
            
        } else {
            
        }
    }
}

extension AppointmentVC: OrderListDelegate {
    func didLoaded(orderList: [Order]) {
        if user.userType == 0 {
            self.orderList = AppManager.shared.selfOrders
        } else {
            self.orderList = orderList
        }
        self.tableView.reloadData()
    }
}
