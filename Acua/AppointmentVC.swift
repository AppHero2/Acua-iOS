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

class AppointmentVC: UIViewController {

    var orderList : [Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AppManager.shared.orderListDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AppointmentVC: OrderListDelegate {
    func didLoaded(orderList: [Order]) {
        self.orderList = orderList
    }
}
