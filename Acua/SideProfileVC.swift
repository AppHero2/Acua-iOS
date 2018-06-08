//
//  SideProfileVC.swift
//  Acua
//
//  Created by AHero on 5/23/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import Toaster
import Material
import Firebase
import SVProgressHUD

class SideProfileVC: UIViewController {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tvFirstName: TextField!
    @IBOutlet weak var tvLastName: TextField!
    @IBOutlet weak var tvEmail: TextField!
    @IBOutlet weak var tvPhone: TextField!
    
    @IBOutlet weak var btnDone: UIButton!
    
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentUser = AppManager.shared.getUser()
        
        btnDone.layer.cornerRadius = AppConst.BTN_CORNER_RADIUS
        
        tvFirstName.delegate = self
        tvFirstName.isClearIconButtonEnabled = true
        tvLastName.delegate = self
        tvLastName.isClearIconButtonEnabled = true
        tvPhone.isEnabled = false
        tvEmail.isEnabled = false
        
        imgProfile.layer.masksToBounds = false
        imgProfile.layer.cornerRadius = imgProfile.frame.size.height/2
        imgProfile.clipsToBounds = true
        
        if self.currentUser != nil {
            tvFirstName.text = self.currentUser!.firstname
            tvLastName.text = self.currentUser!.lastname
            tvPhone.text = self.currentUser!.phone
            tvEmail.text = self.currentUser!.email
            
            if self.currentUser!.photo != nil {
                self.indicator.startAnimating()
                ImageLoader.sharedLoader.imageForUrl(urlString: self.currentUser!.photo!, completionHandler: { (image, url) in
                    self.imgProfile.image = image
                    self.indicator.stopAnimating()
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let userId = self.currentUser!.idx
        self.currentUser?.firstname = tvFirstName.text
        self.currentUser?.lastname = tvLastName.text
        DatabaseRef.shared.userRef.child(userId).child("firstname").setValue(self.currentUser!.firstname)
        DatabaseRef.shared.userRef.child(userId).child("lastname").setValue(self.currentUser!.lastname)
       
        AppManager.shared.saveUser(user: self.currentUser!)
        
        Toast(text: "Updated User Data").show()
    }
}

extension SideProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            let croppedImage = Util.resizeImage(image: pickedImage, newWidth: 150)
            
            indicator.startAnimating()
            SVProgressHUD.show()
            Util.uploadImage(image: croppedImage, uid: self.currentUser!.idx, completion: { (url: String?) in
                let fireUser = Auth.auth().currentUser!
                if url != nil {
                    DatabaseRef.shared.userRef.child(fireUser.uid).child("photo").setValue(url!)
                    self.imgProfile.image = croppedImage
                    Toast(text: "Updated User Profile").show()
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

extension SideProfileVC: TextFieldDelegate {
    
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
