//
//  EasyEmptyKit.swift
//  EasyEmptyKit
//
//  Created by Apple on 2018/5/10.
//  Copyright © 2018年 Apple. All rights reserved.
//

import Foundation

protocol EasyEmptyDelegate : class {
    func emptyButtonPress(button: UIButton)

    func emptyViewTapped()
    
//    func emptyViewIsDisplay() -> Bool
}

//extension EasyEmptyDelegate {
//    func emptyButtonPress(button: UIButton)
//    
//    func emptyViewTapped()
//    
//    func emptyViewIsDisplay() -> Bool
//}
