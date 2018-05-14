//
//  EasyEmptyKit.swift
//  EasyEmptyKit
//
//  Created by Apple on 2018/5/10.
//  Copyright © 2018年 Apple. All rights reserved.
//

import Foundation

struct EasyEmptyKitModel {
    var title : String?
    var imageName : String?
    var buttonTitle : String?
    var buttonColor : UIColor?
//    var emptyViewTapped : () -> Void
    var emptyButtonPress : (UIButton) -> Void 
}

protocol EasyEmptyKitProtocol : class {

    /// 提供视图的文字和图片信息
    ///
    /// - Returns: 文字图片信息模型
    func emptyTableViewData() -> EasyEmptyKitModel?
}


