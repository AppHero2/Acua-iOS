//
//  AuthProfileVC.swift
//  Acua
//
//  Created by AHero on 5/4/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

class AuthProfileVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func onClickProfile () {
        let actionsheet = TOActionSheet()
        actionsheet.style = .dark
        actionsheet.contentstyle = .default
        actionsheet.addButton(withTitle: NSLocalizedString("profile_camera", comment: "Camera")) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }
        actionsheet.addButton(withTitle: NSLocalizedString("profile_album", comment: "Album")) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
//        actionsheet.show(from: self.btnProfile, in: self.navigationController?.view)
    }

    func uploadProfile(image:UIImage) -> Void {
        //TODO: upload profile to firebase storage
    }
}

extension AuthProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            let croppedImage = Utils.resizeImage(image: pickedImage, newWidth: 150)
            uploadProfile(image: croppedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
}
