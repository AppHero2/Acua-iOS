//
//  AuthPhoneVC.swift
//  Acua
//
//  Created by AHero on 5/3/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import CTKFlagPhoneNumber
import KWVerificationCodeView

class AuthPhoneVC: UIViewController {

    @IBOutlet weak var verificationCodeView: KWVerificationCodeView!
    @IBOutlet weak var phoneNumberView: UIView!
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var phoneTextField: CTKFlagPhoneNumberTextField!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblResend: UILabel!
    
    private var verificationID: String!
    
    var countdownTimer: Timer!
    var totalTime = 180
    
    override func viewDidLoad() {
        super.viewDidLoad()

        phoneTextField.parentViewController = self
        phoneTextField.borderStyle = .none
        phoneTextField.textColor = Util.primaryColor

        let items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(dismissKeyboard(_:))),
        ]
        phoneTextField.textFieldInputAccessoryView = getCustomTextFieldInputAccessoryView(with: items)
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        verificationCodeView.isHidden = true
        verificationCodeView.delegate = self
        
        btnNext.layer.cornerRadius = AppConst.BTN_CORNER_RADIUS
        lblResend.isHidden = true
        
        if Device.IS_3_5_INCHES() {
            phoneTextField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        } else if Device.IS_4_INCHES() {
            phoneTextField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        } else if Device.IS_4_7_INCHES() {
            phoneTextField.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        } else if Device.IS_5_5_INCHES() {
            phoneTextField.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        } else {
            phoneTextField.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        validate()
    }
    
    @objc func dismissKeyboard(_ sender: Any) {
        phoneTextField.resignFirstResponder()
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
        
        if isValidatePhoneNumber() {
            imgCheck.image = #imageLiteral(resourceName: "ic_true")
            phoneTextField.resignFirstResponder()
        } else {
            imgCheck.image = #imageLiteral(resourceName: "ic_false")
        }
        
        imgCheck.image = imgCheck.image!.withRenderingMode(.alwaysTemplate)
        imgCheck.tintColor = Util.primaryColor
    }
    
    func isValidatePhoneNumber() -> Bool {
        if phoneTextField.getFormattedPhoneNumber() != nil,
            phoneTextField.getCountryPhoneCode() != nil {
            return true
        } else {
            return false
        }
    }
    
    func requestVerificationCode(phoneNumber:String) {
        SVProgressHUD.show()
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                Util.showMessagePrompt(title: "Error", message: error.localizedDescription, vc: self)
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            self.verificationID = verificationID
            SVProgressHUD.dismiss()
            
            self.startTimer()
        }
    }
    
    func signInWith(verificationCode:String) {
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode)
        
        SVProgressHUD.show()
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                Util.showMessagePrompt(title: "Error", message: error.localizedDescription, vc: self)
                return
            }
            
            SVProgressHUD.dismiss()
            
            self.countdownTimer.invalidate()
            self.countdownTimer = nil
            
            let authProfileVC = self.storyboard!.instantiateViewController(withIdentifier: "AuthProfileVC")
            self.present(authProfileVC, animated: true, completion: {})
        }
    }
    
    @IBAction func onClickNext(_ sender: Any) {
        if verificationCodeView.isHidden {
            if isValidatePhoneNumber() {
                let phoneNumber : String = phoneTextField.getFormattedPhoneNumber()!
                requestVerificationCode(phoneNumber: phoneNumber)
            } else {
                // show alert
                Util.showMessagePrompt(title:"Note", message: "Invalid Phone Number", vc: self)
            }
        } else {
//            self.signInWith(verificationCode: verificationCodeView.getVerificationCode())
        }
        
    }
    
    
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
        phoneTextField.isHidden = true
        verificationCodeView.isHidden = false
        lblResend.isHidden = false
    }
    
    @objc func updateTime() {
        lblResend.text = "Resend in \(timeFormatted(totalTime))"
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
        }
    }
    
    func endTimer() {
        countdownTimer.invalidate()
        
        phoneTextField.isHidden = false
        verificationCodeView.isHidden = true
        lblResend.isHidden = true
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension AuthPhoneVC: KWVerificationCodeViewDelegate {
    func didChangeVerificationCode() {
        if verificationCodeView.hasValidCode() {
            let code = verificationCodeView.getVerificationCode()
            self.signInWith(verificationCode: code)
        } else {
            print(verificationCodeView.getVerificationCode())
        }
    }
}
