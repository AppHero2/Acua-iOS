//
//  RatingVC.swift
//  Acua
//
//  Created by AHero on 6/20/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import Toaster

protocol RatingVCDelegate {
    func onSubmitted(score:Double, content:String)
    func onCancelled()
}

class RatingVC: UIViewController {

    public var delegate : RatingVCDelegate?
    var score : Int = 4
    
    @IBOutlet weak var ratingStar: FloatRatingView!
    @IBOutlet weak var lblRatingStatus: UILabel!
    @IBOutlet weak var tvRatingContent: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ratingStar.delegate = self
        tvRatingContent.placeholder = "Please write your comment here ..."
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        if let content = tvRatingContent.text {
            delegate?.onSubmitted(score: ratingStar.rating, content: content)
        } else {
            Toast.init(text: "Please type your feedback").show()
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        delegate?.onCancelled()
    }

}

extension RatingVC: FloatRatingViewDelegate {
    
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Double) {
        
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        if rating == 1.0 {
            lblRatingStatus.text = "Very Bad"
        } else if rating == 2.0 {
            lblRatingStatus.text = "Not Good"
        } else if rating == 3.0 {
            lblRatingStatus.text = "Quite OK"
        } else if rating == 4.0 {
            lblRatingStatus.text = "Very Good"
        } else if rating == 5.0 {
            lblRatingStatus.text = "Excellent !!!"
        }
    }
    
}
