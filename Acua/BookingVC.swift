//
//  BookingVC.swift
//  Acua
//
//  Created by AHero on 5/3/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import DropDown

class BookingVC: UIViewController {

    @IBOutlet weak var btnCarType: UIButton!
    @IBOutlet weak var btnWashType: UIButton!
    
    let carTypeDropDown = DropDown()
    let washTypeDropDown = DropDown()
    
    var carNames : [String] = []
    var washNames : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDropDown()
    }
    
    private func setupDropDown() {
        carTypeDropDown.anchorView = btnCarType
        washTypeDropDown.anchorView = btnWashType
        // Will set a custom with instead of anchor view width
        //        dropDown.width = 100
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        carTypeDropDown.bottomOffset = CGPoint(x: 0, y: btnCarType.bounds.height)
        washTypeDropDown.bottomOffset = CGPoint(x: 0, y: btnWashType.bounds.height)
        
        for car in AppManager.shared.carTypes {
            carNames.append(car.getName())
        }
        
        for wash in AppManager.shared.washTypes {
            washNames.append(wash.getName())
        }
        
        carTypeDropDown.dataSource = carNames
        washTypeDropDown.dataSource = washNames
        
        // Action triggered on selection
        carTypeDropDown.selectionAction = { [weak self] (index, item) in
            self?.btnCarType.setTitle(item, for: .normal)
        }
        
        washTypeDropDown.selectionAction = { [weak self] (index, item) in
            self?.btnWashType.setTitle(item, for: .normal)
        }
        
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
    
}
