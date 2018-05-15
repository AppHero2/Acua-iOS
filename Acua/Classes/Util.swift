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
}
