//
//  AppointmentVC.swift
//  Acua
//
//  Created by AHero on 5/3/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

protocol OrderListDelegate {
    func didLoaded(orderList: [Order])
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
            if countdownTime <= 0 {
                return "Expired!!"//"00:00:00"
            } else {
                return String(format:"%02.f:%02.f:%02.f", CGFloat(countdownTime!) / 3600, CGFloat(countdownTime!).truncatingRemainder(dividingBy: 3600) / 60, CGFloat(countdownTime!).truncatingRemainder(dividingBy: 60))
            }
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
    
    var countdownTime : Int?    = 0
    var currentTimeString : String {
        get {
            if countdownTime <= 0 {
                return "Expired!!"//"00:00:00"
            } else {
                return String(format:"%02.f:%02.f:%02.f", CGFloat(countdownTime!) / 3600, CGFloat(countdownTime!).truncatingRemainder(dividingBy: 3600) / 60, CGFloat(countdownTime!).truncatingRemainder(dividingBy: 60))
            }
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
    }
    
    public func updateData(order: Order) {
        self.order = order
        
        lblTypes.text = AppManager.shared.getTypesPriceString(menu: order.menu!)
        lblAddress.text = order.location!.name
        lblSchedule.text = "\(Util.getSimpleDateString(millis: order.beginAt)) ~ \(Util.getSimpleTimeString(millis: order.endAt))"
        lblStatus.text = order.serviceStatus.description
        let current = Int(Date().timeIntervalSince1970)
        countdownTime = (order.endAt/1000 - current)
    }
    
    @IBAction func onClickLocation(_ sender: Any) {
        
    }
    
    @IBAction func onClickPhone(_ sender: Any) {
        
    }
    
    @IBAction func onClickAction(_ sender: Any) {
        
    }
}

class AppointmentVC: UITableViewController {

    var orderList : [Order] = []
    var user : User!
    
    fileprivate var timer      : Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AppManager.shared.orderListDelegate = self
        
        user = AppManager.shared.getUser()
        
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        // Init timer.
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerEvent), userInfo: nil, repeats: true)
        
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
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer.invalidate()
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
                    //TODO: long press view
                    if order.serviceStatus == .COMPLETED {
                        //TODO: rate service
                        
                    } else {
                        let alert = UIAlertController(title: "Change of Plans?", message: nil, preferredStyle: .actionSheet)
                        
                        alert.addAction(UIAlertAction(title: "Update Booking", style: .default , handler:{ (UIAlertAction)in
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Withdraw Booking", style: .default , handler:{ (UIAlertAction)in
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    
                }
            }
        }
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
            return cell
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
