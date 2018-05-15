//
//  AuthProfileVC.swift
//  Acua
//
//  Created by AHero on 5/4/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import Firebase

class AuthProfileVC: UIViewController {

    @IBOutlet weak var imgProfile: UIImageView!

    let currentUser = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()


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
}

extension AuthProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            let croppedImage = Utils.resizeImage(image: pickedImage, newWidth: 150)
            Util.uploadImage(image: croppedImage, uid: self.currentUser!.uid, completion: { (url: String?) in
                if url != nil {
                    print("url: ", url)
                }
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
}
