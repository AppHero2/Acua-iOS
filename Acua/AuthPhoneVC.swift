//
//  AuthPhoneVC.swift
//  Acua
//
//  Created by AHero on 5/3/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import CTKFlagPhoneNumber

class AuthPhoneVC: UIViewController {

    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var phoneTextField: CTKFlagPhoneNumberTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        phoneTextField.parentViewController = self
        phoneTextField.font = UIFont.systemFont(ofSize: 25, weight: .bold)

        let items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: nil),
        ]
        phoneTextField.textFieldInputAccessoryView = getCustomTextFieldInputAccessoryView(with: items)
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        validate()
    }
    
    private func getCustomTextFieldInputAccessoryView(with items: [UIBarButtonItem]) -> UIToolbar {
        let toolbar: UIToolbar = UIToolbar()
        
        toolbar.barStyle = UIBarStyle.default
        toolbar.items = items
        toolbar.sizeToFit()
        
        return toolbar
    }
    
    func validate() {
        
        guard let text = phoneTextField.text, !text.isEmpty else {
            imgCheck.image = nil
            return
        }
        
        if isValidate() {
            imgCheck.image = #imageLiteral(resourceName: "ic_true")
        } else {
            imgCheck.image = #imageLiteral(resourceName: "ic_false")
        }
    }
    
    func isValidate() -> Bool {
        if phoneTextField.getFormattedPhoneNumber() != nil,
            phoneTextField.getCountryPhoneCode() != nil {
            return true
        } else {
            return false
        }
    }
}

extension AuthPhoneVC : UITextFieldDelegate {
    
}
