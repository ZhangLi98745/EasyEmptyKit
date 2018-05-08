//
//  DelegateProtocol.swift
//  EmptyTableViewKit
//
//  Created by Apple on 2018/5/7.
//  Copyright © 2018年 Apple. All rights reserved.
//

import Foundation

public protocol EmptyTableViewDelegate : class {
    
    /// 空数据按钮点击调用
    ///
    /// - Parameters:
    ///   - button: 点击的按钮
    ///   - view: 空白视图的父视图
    func emptyButton(_ button: UIButton, tappedIn view: UIView)
    
    /// 空白区域点击
    ///
    /// - Parameters:
    ///   - emptyView: 点击的视图
    ///   - view: 点击视图的父视图
    func emptyView(_ emptyView: UIView, tappedIn view: UIView)

    
}

public extension EmptyTableViewDelegate {
    func emptyButton(_ button: UIButton, tappedIn view: UIView) {
    }
    func emptyView(_ emptyView: UIView, tappedIn view: UIView) {
    }
}
