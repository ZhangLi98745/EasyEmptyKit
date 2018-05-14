//
//  EmptyBackView.swift
//  SwiftGOSKI
//
//  Created by Apple on 2018/5/14.
//  Copyright © 2018年 Apple. All rights reserved.
//

import UIKit

class EmptyBackView: UIView {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    var didTappedButton : ((UIButton) -> Void)?
    var didTappedEmptyView : (() ->())?

    var param : EasyEmptyKitModel? {
        willSet(newParam) {
            if let name = newParam?.imageName {
                imgView.image = UIImage.init(named: name)
            }
            if let title = newParam?.title {
                titleLabel.text = title
            }
            if let btnTitle = newParam?.buttonTitle {
                button.setTitle(btnTitle, for: .normal)
            }
            if let btnColor = newParam?.buttonColor {
                button.backgroundColor = btnColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.addTarget(self, action:#selector(buttonPressAction) , for: .touchUpInside)
    }
    
    @objc func buttonPressAction() {
        if didTappedButton != nil {
            self.didTappedButton!(button)
        }
    }
    
//    @objc func emptyViewTapped() {
//        if didTappedEmptyView != nil {
//            didTappedEmptyView!()
//        }
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.layer.cornerRadius = button.frame.size.height / 2
        button.layer.masksToBounds = true
    }
}
