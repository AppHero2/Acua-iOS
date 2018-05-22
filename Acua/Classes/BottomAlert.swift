//
//  BottomAlert.swift
//  Acua
//
//  Created by AHero on 5/21/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit

protocol BottomAlertDelegate {
    func didClickOK()
    func didClickCancel()
}

class BottomAlert: UIView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnCANCEL: UIButton!
    
    public var delegate: BottomAlertDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let view = loadViewFromNib()!
        view.frame = bounds
        
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth,
                                 UIViewAutoresizing.flexibleHeight]
        self.addSubview(view)
        
        btnOK.layer.cornerRadius = AppConst.BTN_CORNER_RADIUS
        btnCANCEL.layer.cornerRadius = AppConst.BTN_CORNER_RADIUS
    }

    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    @IBAction func onClickOK(_ sender: Any) {
        delegate?.didClickOK()
    }
    
    @IBAction func onClickCANCEL(_ sender: Any) {
        delegate?.didClickCancel()
    }
}
