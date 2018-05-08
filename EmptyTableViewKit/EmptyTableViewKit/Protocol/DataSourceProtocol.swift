//
//  DataSourceProtocol.swift
//  EmptyTableViewKit
//
//  Created by Apple on 2018/5/7.
//  Copyright © 2018年 Apple. All rights reserved.
//

import Foundation

public protocol EmptyTableViewKitDataSource : class {
    
    /// 空白状态下列表显示的默认图片
    ///
    /// - Parameter view: 图片父视图
    /// - Returns: 显示的图片对象
    func imageForEmpty(in view: UIView) -> UIImage?

    /// 空白状态下的想要显示的文字
    ///
    /// - Parameter view: 文本的父视图
    /// - Returns: 显示的富文本
    func titleForEmpty(in view: UIView) -> NSAttributedString?
    
    /// 按钮的显示文字
    ///
    /// - Parameters:
    ///   - state: 按钮的状态
    ///   - view: 按钮的父视图
    /// - Returns: 显示的富文本对象
    func buttonTitleForEmpty(forState state: UIControlState, in view: UIView) -> NSAttributedString?
    
    /// 按钮的背景颜色
    ///
    /// - Parameter view: 按钮的父视图
    /// - Returns: 按钮的颜色
    func buttonBackgroundColorForEmpty(in view: UIView) -> UIColor
    
    func sectionsToIgnore(in view: UIView) -> [Int]?
    
    func descriptionForEmpty(in view: UIView) -> NSAttributedString?
}

public extension EmptyTableViewKitDataSource {
    
    func imageForEmpty(in view: UIView) -> UIImage? {
        return nil
    }
    
    func titleForEmpty(in view: UIView) -> NSAttributedString? {
        return nil
    }
    
    func buttonTitleForEmpty(forState state: UIControlState, in view: UIView) -> NSAttributedString? {
        return nil
    }

    func buttonBackgroundColorForEmpty(in view: UIView) -> UIColor {
        return UIColor.clear
    }
    func sectionsToIgnore(in view: UIView) -> [Int]? {
        return nil
    }
    
    func descriptionForEmpty(in view: UIView) -> NSAttributedString? {
        return nil
    }

}
