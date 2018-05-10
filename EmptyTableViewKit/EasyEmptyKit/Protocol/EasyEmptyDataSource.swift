//
//  EasyEmptyKitDataSource.swift
//  EasyEmptyKit
//
//  Created by Apple on 2018/5/10.
//  Copyright © 2018年 Apple. All rights reserved.
//

import Foundation

protocol EasyEmptyDataSource : class{
    func imageForEmpty(in view: UIView) -> UIImage?

    func titleForEmpty(in view: UIView) -> NSAttributedString?
    
    func buttonTitleForEmpty(forState state: UIControlState, in view: UIView) -> NSAttributedString?

    func buttonBackgroundColorForEmpty(in view: UIView) -> UIColor
    
    func sectionsToIgnore(in view: UIView) -> [Int]?
    
    func descriptionForEmpty(in view: UIView) -> NSAttributedString?
}
