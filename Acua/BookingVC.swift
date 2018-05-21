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

protocol CarTypeDelegate {
    func didLoaded(cars:[Car])
}
protocol WashTypeDelegate {
    func didLoaded(washes:[Wash])
}

class BookingVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnCarType: UIButton!
    @IBOutlet weak var btnWashType: UIButton!
    
    @IBOutlet weak var btnTapYes: ISRadioButton!
    @IBOutlet weak var btnPlugYes: ISRadioButton!
    
    @IBOutlet weak var icCalendar: UIImageView!
    @IBOutlet weak var icTimer: UIImageView!
    @IBOutlet weak var icLocation: UIImageView!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    let carTypeDropDown = DropDown()
    let washTypeDropDown = DropDown()
    
    var carNames : [String] = []
    var washNames : [String] = []
    
    fileprivate var curDate: Date = Date()
    fileprivate var curTime: Int = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDropDown()
        
        btnTapYes.isSelected = true
        btnPlugYes.isSelected = true
        
        Util.setImageTintColor(imgView: icCalendar)
        Util.setImageTintColor(imgView: icTimer)
        Util.setImageTintColor(imgView: icLocation)
        
        AppManager.shared.carTypeDelegate = self
        AppManager.shared.washTypeDelegate = self
        
        setupDateLabel()
        setupTimeLabel()
    }
    
    private func setupDropDown() {
        carTypeDropDown.anchorView = btnCarType
        washTypeDropDown.anchorView = btnWashType
        
        carTypeDropDown.bottomOffset = CGPoint(x: 0, y: btnCarType.bounds.height)
        washTypeDropDown.bottomOffset = CGPoint(x: 0, y: btnWashType.bounds.height)
        
        setupCarTypes()
        setupWashTypes()
    }
    
    private func setupCarTypes() {
        for car in AppManager.shared.carTypes {
            carNames.append(car.getName())
        }
        carTypeDropDown.dataSource = carNames
        carTypeDropDown.selectionAction = { [weak self] (index, item) in
            self?.btnCarType.setTitle(item, for: .normal)
        }
    }
    
    private func setupWashTypes(){
        for wash in AppManager.shared.washTypes {
            washNames.append(wash.getName())
        }
        washTypeDropDown.dataSource = washNames
        washTypeDropDown.selectionAction = { [weak self] (index, item) in
            self?.btnWashType.setTitle(item, for: .normal)
        }
    }

    private func setupDateLabel() {
        lblDate.text = Util.getComplexTimeString(date: curDate)
    }
    
    private func setupTimeLabel() {
        let seconds: Int = curTime % 60
        let minutes: Int = (curTime / 60) % 60
        lblTime.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickCarType(_ sender: Any) {
        carTypeDropDown.show()
    }
    
    @IBAction func onClickWashType(_ sender: Any) {
        washTypeDropDown.show()
    }
    
    @IBAction func onClickTap(_ sender: ISRadioButton) {
        
    }
    
    @IBAction func onClickPlug(_ sender: ISRadioButton) {
        
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
        let selector = UIStoryboard(name: "WWCalendarTimeSelector", bundle: nil).instantiateInitialViewController() as! WWCalendarTimeSelector
        selector.delegate = self
        selector.optionCurrentDate = curDate
        selector.optionStyles.showDateMonth(false)
        selector.optionStyles.showMonth(false)
        selector.optionStyles.showYear(false)
        selector.optionStyles.showTime(true)
        
        present(selector, animated: true, completion: nil)
        
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
    
}

extension BookingVC: CarTypeDelegate, WashTypeDelegate {
    func didLoaded(cars: [Car]) {
        setupCarTypes()
    }
    func didLoaded(washes: [Wash]) {
        setupWashTypes()
    }
}

extension BookingVC: WWCalendarTimeSelectorProtocol {
    func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, date: Date) {
        print("Selected \n\(date)\n---")
        curDate = date
//        dateLabel.text = date.stringFromFormat("d' 'MMMM' 'yyyy', 'h':'mma")
    }
    
    func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, dates: [Date]) {
        print("Selected Multiple Dates \n\(dates)\n---")
        if let date = dates.first {
            curDate = date
//            dateLabel.text = date.stringFromFormat("d' 'MMMM' 'yyyy', 'h':'mma")
        }
        else {
//            dateLabel.text = "No Date Selected"
        }
    }
}

extension BookingVC: GMSPlacePickerViewControllerDelegate{
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("Place name \(place.name)")
//        print("Place address \(place.formattedAddress)")
//        print("Place attributions \(place.attributions)")
        
        lblAddress.text = place.formattedAddress
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
        lblAddress.text = "No place selected"
    }
}
