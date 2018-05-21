//
//  Util.swift
//  Acua
//
//  Created by AHero on 5/15/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import FirebaseStorage

class Util {

    static public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static public var primaryColor: UIColor {
        return UIColor(red: 33/255, green: 137/255, blue: 190/255, alpha: 1.0)
    }
    
    static func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    static func showMessagePrompt(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
            }}))
        vc.present(alert, animated: true, completion: nil)
    }
    
    static public func setImageTintColor(imgView: UIImageView){
        imgView.image = imgView.image!.withRenderingMode(.alwaysTemplate)
        imgView.tintColor = Util.primaryColor
    }
    
    static func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static public func uploadImage(image: UIImage, uid:String, completion: @escaping (_ url: String?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("profile").child("\(uid).png")
        if let uploadData = UIImagePNGRepresentation(image) {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    completion(nil)
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                print("size: ", size)
                // You can also access to download URL after upload.
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        completion(nil)
                        return
                    }
                    
                    completion(downloadURL.absoluteString)
                }
            }
        }
    }
    
    static public func getComplexTimeString(date: Date) -> String{
        let dateformater = DateFormatter()
        dateformater.dateFormat = "MMMM"
        let month_name = dateformater.string(from: date).capitalized
        
        dateformater.dateFormat = "EEEE"
        let week_name = dateformater.string(from: date).capitalized
        
        dateformater.dateFormat = "dd"
        let day = dateformater.string(from: date)
        
        dateformater.dateFormat = "yyyy"
        let year = dateformater.string(from: date)
        
        let full = week_name + " " + day + " " + month_name + " " + year
        return full
    }
    
    static public func getTimeString() {
        
    }
}
