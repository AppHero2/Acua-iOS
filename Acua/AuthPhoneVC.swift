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
    
    private var verificationID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        phoneTextField.parentViewController = self
        phoneTextField.font = UIFont.systemFont(ofSize: 25, weight: .bold)

        let items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(dismissKeyboard(_:))),
        ]
        phoneTextField.textFieldInputAccessoryView = getCustomTextFieldInputAccessoryView(with: items)
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        verificationCodeView.isHidden = true
        verificationCodeView.delegate = self
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
        } else {
            imgCheck.image = #imageLiteral(resourceName: "ic_false")
        }
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
                self.showMessagePrompt(message: error.localizedDescription)
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            self.verificationID = verificationID
            self.phoneTextField.isHidden = true
            self.verificationCodeView.isHidden = false
            
            SVProgressHUD.dismiss()
        }
    }
    
    func signInWith(verificationCode:String) {
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode)
        
        SVProgressHUD.show()
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                self.showMessagePrompt(message: error.localizedDescription)
                return
            }
            
            SVProgressHUD.dismiss()
            
            let authProfileVC = self.storyboard!.instantiateViewController(withIdentifier: "AuthProfileVC")
            self.present(authProfileVC, animated: true, completion: {})
        }
    }
    
    func showMessagePrompt(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onClickNext(_ sender: Any) {
        /*let authProfileVC = self.storyboard!.instantiateViewController(withIdentifier: "AuthProfileVC")
        self.present(authProfileVC, animated: true, completion: {}) */
        
        /*let appDelegateTemp = UIApplication.shared.delegate as? AppDelegate
        appDelegateTemp?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()*/
        if verificationCodeView.isHidden {
            if isValidatePhoneNumber() {
                let phoneNumber : String = phoneTextField.getFormattedPhoneNumber()!
                requestVerificationCode(phoneNumber: phoneNumber)
            } else {
                // show alert
                self.showMessagePrompt(message: "Invalid Phone Number")
            }
        } else {
            self.signInWith(verificationCode: verificationCodeView.getVerificationCode())
        }
        
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
