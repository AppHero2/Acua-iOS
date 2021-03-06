//
//  AuthProfileVC.swift
//  Acua
//
//  Created by AHero on 5/4/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import Material

class AuthProfileVC: UIViewController {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var evFirstName: TextField!
    @IBOutlet weak var evLastName: TextField!
    @IBOutlet weak var evEmail: ErrorTextField!
    
    @IBOutlet weak var btnDone: UIButton!
    
    let currentUser = Auth.auth().currentUser
    var existUser : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnDone.layer.cornerRadius = AppConst.BTN_CORNER_RADIUS
        
        evEmail.delegate = self
        evEmail.isClearIconButtonEnabled = true
        evEmail.addTarget(self, action: #selector(emailFieldDidChange), for: .editingChanged)
        evFirstName.delegate = self
        evFirstName.isClearIconButtonEnabled = true
        evLastName.delegate = self
        evLastName.isClearIconButtonEnabled = true
        
        imgProfile.layer.masksToBounds = false
        imgProfile.layer.cornerRadius = imgProfile.frame.size.height/2
        imgProfile.clipsToBounds = true
        
        checkExistUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func emailFieldDidChange(tv:ErrorTextField) {
        if !Util.isValidEmail(testStr: tv.text!) {
            evEmail.isErrorRevealed = true
        } else {
            evEmail.isErrorRevealed = false
        }
    }
    
    private func checkExistUser() {
        if currentUser == nil {
            return
        }
        
        SVProgressHUD.show()
        let query = DatabaseRef.shared.userRef.queryOrdered(byChild: "uid").queryEqual(toValue: currentUser!.uid)
        query.observeSingleEvent(of: .value, with: { (snapshot:DataSnapshot) in
            SVProgressHUD.dismiss()
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                self.existUser = User(data: rest.value as! [String:Any])
                self.evFirstName.text = self.existUser!.firstname
                self.evLastName.text = self.existUser!.lastname
                self.evEmail.text = self.existUser!.email
                
                self.imgProfile.sd_setImage(with: URL(string: self.existUser!.photo ?? ""), placeholderImage: #imageLiteral(resourceName: "ic_profile_person"))
            }
            
        }) { (error:Error) in
            SVProgressHUD.dismiss()
            print(error.localizedDescription)
        }
    }
    
    private func isValidateRegisterInfo() -> Bool {
        let email = evEmail.text ?? ""
        let firstname = evFirstName.text ?? ""
        let lastname = evLastName.text ?? ""
        
        if email.isEmpty {
            Util.showMessagePrompt(title: "Error", message: "Email Address should not be empty", vc: self)
            return false
        }
        
        if !Util.isValidEmail(testStr: email) {
            Util.showMessagePrompt(title: "Error", message: "Invalid Email", vc: self)
            return false
        }
        
        if firstname.isEmpty {
            Util.showMessagePrompt(title: "Error", message: "First Name should not be empty", vc: self)
            return false
        }
        
        if lastname.isEmpty {
            Util.showMessagePrompt(title: "Error", message: "Last Name should not be empty", vc: self)
            return false
        }
        
        return true
    }
    
    @IBAction func onClickProfile(_ sender: Any) {
        let actionsheet = TOActionSheet()
        actionsheet.style = .dark
        actionsheet.contentstyle = .default
        actionsheet.addButton(withTitle: NSLocalizedString("Camera", comment: "Camera")) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }
        actionsheet.addButton(withTitle: NSLocalizedString("Album", comment: "Album")) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
        actionsheet.show(from: imgProfile, in: self.view)
    }
    
    @IBAction func onClickDone(_ sender: Any) {
        if isValidateRegisterInfo() {
            
            let termsVC = self.storyboard!.instantiateViewController(withIdentifier: "AuthTermsVC") as! AuthTermsVC
            
            if existUser != nil {
                existUser!.firstname = evFirstName.text
                existUser!.lastname = evLastName.text
                existUser!.email = evEmail.text
                
                termsVC.user = existUser
            } else {
                var userData : [String:Any] = [:]
                userData["uid"] = currentUser!.uid
                userData["firstname"] = evFirstName.text
                userData["lastname"] = evLastName.text!
                userData["email"] = evEmail.text!
                userData["phone"] = currentUser!.phoneNumber
                userData["userType"] = existUser != nil ? existUser!.userType : 0
                let user = User(data: userData)
                
                termsVC.user = user
            }
            
            self.present(termsVC, animated: true, completion: {})
        }
    }
}

extension AuthProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            let croppedImage = Util.resizeImage(image: pickedImage, newWidth: 150)
            
            indicator.startAnimating()
            SVProgressHUD.show()
            Util.uploadImage(image: croppedImage, uid: self.currentUser!.uid, completion: { (url: String?) in
                let fireUser = Auth.auth().currentUser!
                if url != nil {
                    DatabaseRef.shared.userRef.child(fireUser.uid).child("photo").setValue(url!)
                    self.imgProfile.image = croppedImage
                } else {
                    print("photo url is empty")
                }
                self.indicator.stopAnimating()
                SVProgressHUD.dismiss()
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension AuthProfileVC: TextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
