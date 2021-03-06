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
    
    static public func setImageTintColor(imgView: UIImageView, color: UIColor){
        imgView.image = imgView.image!.withRenderingMode(.alwaysTemplate)
        imgView.tintColor = color
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
    
    static public func checkAvailableTimeRange(milis: Int) -> Bool {
        let date = Date(timeIntervalSince1970: TimeInterval(milis / 1000))
        let hour = Calendar.current.component(.hour, from: date)
        if AppConst.SERVICE_TIME_START <= hour, hour < AppConst.SERVICE_TIME_END {
            return true
        } else {
            return false
        }
    }
    
    static public func getDate(year:Int, month:Int, day:Int, hour:Int, minute:Int, second:Int) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        let time = calendar.date(from: dateComponents)
        return time ?? Date()
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
    
    static public func getSimpleDateString(millis: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(millis/1000))
        let dateformater = DateFormatter()
        dateformater.dateFormat = "dd-MM-yyyy HH:mm"
        let string = dateformater.string(from: date)
        return string
    }
    
    static public func getSimpleTimeString(millis: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(millis/1000))
        let dateformater = DateFormatter()
        dateformater.dateFormat = "HH:mm"
        let string = dateformater.string(from: date)
        return string
    }
    
    static public func getFullTimeString(millis: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(millis/1000))
        let dateformater = DateFormatter()
        dateformater.dateFormat = "MMMM"
        let month_name = dateformater.string(from: date).capitalized
        
        dateformater.dateFormat = "dd"
        let day = dateformater.string(from: date)
        
        dateformater.dateFormat = "yyyy"
        let year = dateformater.string(from: date)
        
        dateformater.dateFormat = "HH:mm"
        let hour = dateformater.string(from: date)
        let full = "\(hour) on \(day) \(month_name) \(year)"
        
        return full
    }
    
    static public func getYesdayFormatDate(millis: Int) -> String {
        let now = Date(timeIntervalSince1970: TimeInterval(millis/1000))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        let time = "\(dateFormatter.string(from: now)), \(timeFormatter.string(from: now))"
        return time
    }
    
    static public func getRemainFormatDate(millis: Int) -> String {
        if millis <= 0 {
            return "Not engaged"//"00:00:00"
        } else {
            let years = millis / (86400 * 365)
            let days = (millis / 86400)
            let hours = (millis % 86400) / 3600
            let minutes = (millis % 3600) / 60
            let seconds = (millis % 3600) % 60
            if days == 0 {
                return String(format:"%02d:%02d:%02d", hours, minutes, seconds)
            } else if years == 0 {
                return String(format:"%d days %02d:%02d:%02d",days, hours, minutes, seconds)
            } else {
                return String(format:"%d yrs %d days %02d:%02d:%02d",days, hours, minutes, seconds)
            }
            
        }
    }
    
    static public func getISO8601() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
    
    static public func md5(_ string: String) -> String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate()
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        return hexString
    }
}

extension Bundle {
    var releaseVersionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    var buildVersionNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
