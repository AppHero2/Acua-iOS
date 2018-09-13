//
//  BookingVC.swift
//  Acua
//
//  Created by AHero on 5/3/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import DropDown
import GooglePlaces
import GooglePlacePicker
import NotificationBannerSwift
import Toaster
import SVProgressHUD

protocol CarTypeDelegate {
    func didLoaded(cars:[Car])
}
protocol WashTypeDelegate {
    func didLoaded(washes:[Wash])
}
protocol MenuListDelegate {
    func didLoaded(menuList:[Menu])
}

protocol BookingEventListener {
    func didBooking(success: Bool)
}

class BookingVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnCarType: UIButton!
    @IBOutlet weak var btnWashType: UIButton!
    @IBOutlet weak var btnHour: UIButton!
    
    @IBOutlet weak var btnTapYes: ISRadioButton!
    @IBOutlet weak var btnPlugYes: ISRadioButton!
    @IBOutlet weak var btnConfirm: UIButton!
    
    @IBOutlet weak var icCalendar: UIImageView!
    @IBOutlet weak var icTimer: UIImageView!
    @IBOutlet weak var icLocation: UIImageView!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    let carTypeDropDown = DropDown()
    let washTypeDropDown = DropDown()
    let hourSelection = DropDown()
    var banner : NotificationBanner?
    var customView : BottomAlert?
    
    var carNames : [String] = []
    var washNames : [String] = []
    var menuList : [Menu] = []
    let availableHours:[String] = ["07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00"]
    
    var hasTap : Bool = true
    var hasPlug : Bool = true
    
    var year, month, day, hour, minute : Int?
    
    fileprivate var curDate: Date = Date()
    fileprivate var curTime: Int = 8
    fileprivate var curLcoation: Location?
    fileprivate var curCarType : Car?
    fileprivate var curWashType: Wash?
    fileprivate var curMenu : Menu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDropDown()
        
        btnTapYes.isSelected = true
        btnPlugYes.isSelected = true
        btnConfirm.layer.cornerRadius = AppConst.BTN_CORNER_RADIUS
        
        Util.setImageTintColor(imgView: icCalendar, color: AppConst.primaryColor)
        Util.setImageTintColor(imgView: icTimer, color: AppConst.primaryColor)
        Util.setImageTintColor(imgView: icLocation, color: AppConst.primaryColor)
        
        AppManager.shared.carTypeDelegate = self
        AppManager.shared.washTypeDelegate = self
        AppManager.shared.menuListDelegate = self
        
        setupDateLabel()
        setupTimeLabel()
        
        updateDate(date: curDate)
    }
    
    private func setupDropDown() {
        carTypeDropDown.anchorView = btnCarType
        washTypeDropDown.anchorView = btnWashType
        
        carTypeDropDown.bottomOffset = CGPoint(x: 0, y: btnCarType.bounds.height)
        washTypeDropDown.bottomOffset = CGPoint(x: 0, y: btnWashType.bounds.height)
        
        setupCarTypes()
        setupWashTypes()
        self.menuList = AppManager.shared.menuList
        setupAvailableHours()
        setupBottomAlert()
    }
    
    private func setupCarTypes() {
        for car in AppManager.shared.carTypes {
            carNames.append(car.getName())
        }
        carTypeDropDown.dataSource = carNames
        carTypeDropDown.selectionAction = { [weak self] (index, item) in
            self?.btnCarType.setTitle(item, for: .normal)
            for car in AppManager.shared.carTypes {
                if car.getName() == item {
                    self?.curCarType = car
                    break
                }
            }
            self?.updatePrice()
        }
        if AppManager.shared.carTypes.count > 0 {
            self.curCarType = AppManager.shared.carTypes[0]
            self.btnCarType.titleLabel?.text = self.curCarType?.name
        }
    }
    
    private func setupWashTypes(){
        for wash in AppManager.shared.washTypes {
            washNames.append(wash.getName())
        }
        washTypeDropDown.dataSource = washNames
        washTypeDropDown.selectionAction = { [weak self] (index, item) in
            self?.btnWashType.setTitle(item, for: .normal)
            for wash in AppManager.shared.washTypes {
                if wash.getName() == item {
                    self?.curWashType = wash
                    break
                }
            }
            self?.updatePrice()
        }
        if AppManager.shared.washTypes.count > 0 {
            self.curWashType = AppManager.shared.washTypes[0]
            self.btnWashType.titleLabel?.text = self.curWashType?.name
        }
    }
    
    private func setupAvailableHours(){
        hourSelection.dataSource = availableHours
        hourSelection.selectionAction = { [weak self] (index, item) in
            self?.lblTime.text = item
            self?.hour = Int(item.replacingOccurrences(of: ":00", with: ""))
            self?.updateDate(date: (self?.curDate)!)
        }
        hour = 7
        lblTime.text = availableHours[0]
    }

    private func setupDateLabel() {
        lblDate.text = Util.getComplexTimeString(date: curDate)
    }
    
    private func setupTimeLabel() {
        lblTime.text = String(format: "%02d:00", hour!)
    }
    
    private func setupBottomAlert (){
        customView = BottomAlert(frame: CGRect(x: 0, y: 0, width: AppConst.screenWidth, height: 100))
        customView!.delegate = self
        banner = NotificationBanner(customView: customView!)
        banner!.delegate = self
        banner!.backgroundColor = UIColor.rbg(r: 240, g: 173, b: 78)
        banner!.autoDismiss = false
        banner!.bannerHeight = 105
        banner!.onTap = {
            
        }
        banner!.onSwipeUp = {
            //banner.dismiss()
        }
    }
    private func checkOptions() {
        var title = "";
        if (hasTap && hasPlug) {
            btnWashType.isEnabled = true
            return;
        } else if (!hasTap && hasPlug) {
            title = "Due to an inaccessible tap, we can only offer the waterless full wash option.";
        } else if (hasTap && !hasPlug) {
            title = "Due to an inaccessible plug, we can only offer the waterless wash option.";
        } else if (!hasTap && !hasPlug) {
            title = "Due to an inaccessible tap, we can only offer the waterless wash option.";
        }
        showBottomAlert(title: title)
    }
    
    private func showBottomAlert(title:String){
        customView?.lblTitle.text = title
        banner?.show(queuePosition: .front, bannerPosition: .bottom)
        self.view.isUserInteractionEnabled = false
    }
    
    private func isValidBooking(order: Order) -> Bool {
        
        if curMenu == nil{
            Util.showMessagePrompt(title: "Note!", message: "Please check your network, and reopen acuar", vc: self)
            return false
        }
        
        if order.location == nil {
            Util.showMessagePrompt(title: "Note!", message: "Please select location.", vc: self)
            return false
        }
        
        if !Util.checkAvailableTimeRange(milis: order.beginAt) {
            //let message = "The operating hours for the car wash is  \(AppConst.SERVICE_TIME_START):00 to \(AppConst.SERVICE_TIME_END):00."
            let message = "Dear valued client, our winter operating hours are \(AppConst.SERVICE_TIME_START):00 to \(AppConst.SERVICE_TIME_END):00."
            Util.showMessagePrompt(title: "Note!", message: message, vc: self)
            return false
        }
        
        if isPastTime(time: order.beginAt) {
            Util.showMessagePrompt(title: "Note!", message: "You can only book dates and times that are in the future.", vc: self)
            return false
        }
        
        return true
    }
    
    private func isPastTime(time: Int) -> Bool {
        if Int(NSDate().timeIntervalSince1970 * 1000) < time{
            return false
        }
        return true
    }
    
    private func isExistingOrdersCount(time: Int) -> Bool {
        var existCount = 0
        for order in AppManager.shared.orderList {
            if order.beginAt <= time, time <= order.endAt {
                existCount += 1
            }
        }
        
        return existCount >= AppConst.LIMIT_ORDERS_PER_HOUR
    }
    
    private func makeOrder(order: Order) {
        if let user = AppManager.shared.getUser() {
            if user.cardStatus == 1, user.cardToken != nil {
                let push_title = "\(user.getFullName()) has made an offer"
                let push_message = "\(curCarType!.getName()), \(curWashType!.getName()) at \(Util.getSimpleDateString(millis: order.beginAt))"
                
                let ref = DatabaseRef.shared.ordersRef.childByAutoId()
                order.idx = ref.key
                let dic = order.toAnyObject()
                
                SVProgressHUD.show()
                DatabaseRef.shared.ordersRef.child(order.idx!).updateChildValues(dic) { (error, ref) in
                    SVProgressHUD.dismiss()
                    if let error = error {
                        print("Data could not be saved: \(error).")
                        AppManager.shared.bookingEventListener?.didBooking(success: false)
                    } else {
                        Toast(text: "Booked successfully").show()
                        AppManager.shared.bookingEventListener?.didBooking(success: true)
                        AppManager.shared.sendPushNotificationToService(title: push_title, message: push_message)
                    }
                }
            } else {
                Util.showMessagePrompt(title: "Note", message: "Please verify your payment first", vc: self)
            }
        }
    }
    
    private func generateValidTime(time: Int) -> Int{
        var value = time - 3600 * 1000
        while true {
            value = value + 3600 * 1000
            if Util.checkAvailableTimeRange(milis: value), !isExistingOrdersCount(time: value) {
                break
            }
        }
        return value
    }
    
    private func updateDate(date: Date){
        let dateformater = DateFormatter()
        dateformater.dateFormat = "dd"
        day = Int(dateformater.string(from: date))
        dateformater.dateFormat = "MM"
        month = Int(dateformater.string(from: date))
        dateformater.dateFormat = "yyyy"
        year = Int(dateformater.string(from: date))
        curDate = Util.getDate(year: year ?? 0, month: month ?? 0, day: day ?? 0, hour: hour ?? 0, minute: 0, second: 0)
        lblDate.text = Util.getComplexTimeString(date: curDate)
    }
    
    private func updateTime(date: Date) {
        let dateformater = DateFormatter()
        dateformater.dateFormat = "HH"
        hour = Int(dateformater.string(from: date))
        lblTime.text = String(format: "%02d:00", hour!)
    }
    
    private func updatePrice(){
        if curCarType != nil, curWashType != nil {
            let key = "\(curWashType!.getId())_\(curCarType!.getId())"
            for menu in AppManager.shared.menuList {
                if menu.getId() == key {
                    curMenu = menu
                    break
                }
            }
            
            if curMenu != nil {
                lblPrice.text = String(format: "ZAR %.02f", curMenu!.getPrice())
            }
        }
    }
    
    //MARK : Button Events
    @IBAction func onClickCarType(_ sender: Any) {
        carTypeDropDown.show()
    }
    
    @IBAction func onClickWashType(_ sender: Any) {
        washTypeDropDown.show()
    }
    
    @IBAction func onClickTap(_ sender: ISRadioButton) {
        if btnTapYes.isSelected {
            hasTap = true
        } else {
            hasTap = false
        }
        
        checkOptions()
    }
    
    @IBAction func onClickPlug(_ sender: ISRadioButton) {
        if btnPlugYes.isSelected {
            hasPlug = true
        } else {
            hasPlug = false
        }
        
        checkOptions()
    }
    
    @IBAction func onClickDate(_ sender: Any) {
        let selector = UIStoryboard(name: "WWCalendarTimeSelector", bundle: nil).instantiateInitialViewController() as! WWCalendarTimeSelector
        selector.delegate = self
        selector.optionCurrentDate = curDate
        selector.optionStyles.showDateMonth(true)
        selector.optionStyles.showMonth(false)
        selector.optionStyles.showYear(false)
        selector.optionStyles.showTime(false)
        
        present(selector, animated: true, completion: nil)
    }
    
    @IBAction func onClickTime(_ sender: Any) {
        hourSelection.show()
    }
    
    @IBAction func onClickAddress(_ sender: Any) {
        /*let center = CLLocationCoordinate2D(latitude: 37.788204, longitude: -122.411937)
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)*/
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
    
        let order = Order()
        order.menu = curMenu
        order.location = curLcoation
        order.customerId = AppManager.shared.getUser()?.idx
        order.customerPushToken = AppManager.shared.getUser()?.pushToken
        let bookedAt : Date = Util.getDate(year: year ?? 0, month: month ?? 0, day: day ?? 0, hour: hour ?? 0, minute: minute ?? 0, second: 0)
        order.beginAt = Int(bookedAt.timeIntervalSince1970*1000)
        order.endAt = order.beginAt + (curMenu != nil ? curMenu!.getDuration()*1000 : 0)
        order.hasTap = hasTap
        order.hasPlug = hasPlug
        order.is24reminded = false
        
        if isValidBooking(order: order) {
            if isExistingOrdersCount(time: order.beginAt) {
                // show alert
                let validTime = generateValidTime(time: order.beginAt)
                let validTimeString = Util.getFullTimeString(millis: validTime)
                let title = "Note"
                let msg = "Dear valued customer, this time slot is currently unavailable. The next available time slot is \(validTimeString). Would you like to book this slot?";
                let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    DispatchQueue.main.async {
                        order.beginAt = validTime
                        order.endAt = order.beginAt + self.curMenu!.getDuration()*1000
                        let date = Date(timeIntervalSince1970: TimeInterval(validTime/1000))
                        self.updateDate(date: date)
                        self.updateTime(date: date)
                        self.makeOrder(order: order)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                
                let title = "Confirmation"
                let msg = "Dear valued customer, Would you like to book this slot?";
                let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    DispatchQueue.main.async {
                        self.makeOrder(order: order)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
}

extension BookingVC: CarTypeDelegate, WashTypeDelegate, MenuListDelegate {
    func didLoaded(cars: [Car]) {
        setupCarTypes()
    }
    func didLoaded(washes: [Wash]) {
        setupWashTypes()
    }
    func didLoaded(menuList: [Menu]) {
        print("loaded Menu List")
        self.menuList = menuList
        self.updatePrice()
    }
}

extension BookingVC: WWCalendarTimeSelectorProtocol {
    func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, date: Date) {
        updateDate(date: date)
    }
    
    func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, dates: [Date]) {
        print("Selected Multiple Dates \n\(dates)\n---")
    }
}

extension BookingVC: GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("Place name \(place.name)")
        //print("Place address \(place.formattedAddress)")
        //print("Place attributions \(place.attributions)")
        
        lblAddress.text = place.formattedAddress
        
        let name = place.formattedAddress ?? place.name
        let lat = place.coordinate.latitude
        let lng = place.coordinate.longitude
        
        self.curLcoation = Location(name, lat: lat, lng: lng)
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        lblAddress.text = "No place selected"
        self.curLcoation = nil
    }
}

extension BookingVC: NotificationBannerDelegate, BottomAlertDelegate {
    func notificationBannerWillAppear(_ banner: BaseNotificationBanner) {
        
    }
    
    func notificationBannerDidAppear(_ banner: BaseNotificationBanner) {
        
    }
    
    func notificationBannerWillDisappear(_ banner: BaseNotificationBanner) {
        
    }
    
    func notificationBannerDidDisappear(_ banner: BaseNotificationBanner) {
        
    }
    
    func didClickOK() {
    
        if !hasTap, hasPlug {
            washTypeDropDown.selectionAction?(3, washNames[3])
            washTypeDropDown.selectRow(at: 3)
        } else if hasTap, !hasPlug {
            washTypeDropDown.selectionAction?(2, washNames[2])
            washTypeDropDown.selectRow(at: 2)
        } else if !hasTap, !hasPlug {
            washTypeDropDown.selectionAction?(2, washNames[2])
            washTypeDropDown.selectRow(at: 2)
        }
        
        btnWashType.isEnabled = false
        banner?.dismiss()
        self.view.isUserInteractionEnabled = true
    }
    
    func didClickCancel() {
        
        washTypeDropDown.selectionAction?(0, washNames[0])
        washTypeDropDown.selectRow(at: 0)
        btnTapYes.isSelected = true
        btnPlugYes.isSelected = true
        hasTap = true
        hasPlug = true
        
        banner?.dismiss()
        self.view.isUserInteractionEnabled = true
    }
}
