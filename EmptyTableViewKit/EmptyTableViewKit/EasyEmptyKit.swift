//
//  EasyEmptyKit.swift
//  EasyEmptyKit
//
//  Created by Apple on 2018/5/10.
//  Copyright © 2018年 Apple. All rights reserved.
//

import Foundation
import UIKit

/// Keys
private var datasourceKey: Void?
private var delegateKey: Void?
private var emptyViewKey: Void?
private var customViewKey: Void?
private var datasourceMakerKey: Void?
private let emptyImageViewAnimationKey = "emptyImageViewAnimationKey"
private var reloadTimeKey = "reloadTimeKey"


extension UITableView {
    static func swizzle(originSelector : Selector , to newSelector : Selector) -> Void {
        let originSel = class_getInstanceMethod(self, originSelector)
        let newSel = class_getInstanceMethod(self, newSelector)
        let didAddMethod = class_addMethod(self, originSelector, method_getImplementation(newSel!), method_getTypeEncoding(newSel!))
        if didAddMethod {
            class_replaceMethod(self, newSelector, method_getImplementation(originSel!), method_getTypeEncoding(originSel!))
        } else {
            method_exchangeImplementations(originSel!, newSel!)
        }
    }
    
    static let swizzleIfNeed: () = {
        UITableView.swizzle(originSelector: #selector(reloadData), to: #selector(swizzle_reloadData))
        UITableView.swizzle(originSelector: #selector(endUpdates), to: #selector(swizzle_endUpdates))
    }()
    
    @objc fileprivate func swizzle_reloadData(){
        self.reloadTime += 1
        swizzle_reloadData()
        ept_reloadData()
    }
    
    @objc fileprivate func swizzle_endUpdates(){
        swizzle_endUpdates()
        ept_reloadData()
    }
    
    @objc fileprivate func ept_reloadData() {
        let ret = setupEmptyView(withItemsCount: self.itemsCount)
        if ret == false {
            return
        }
        
        self.emptyView?.didTappedButton = {
            [weak self] button in
            guard let strongSelf = self else {
                return
            }
            strongSelf.emptyDelegate?.emptyTableViewData()?.emptyButtonPress(button)
        }

//        self.emptyView?.didTappedEmptyView = { [weak self] in
//            guard let strongSelf = self else {
//                return
//            }
//            strongSelf.emptyDelegate?.emptyTableViewData()?.emptyViewTapped()
//        }
    }
    
    weak var emptyDelegate : EasyEmptyKitProtocol? {
        get {
            return objc_getAssociatedObject(self, &delegateKey) as? EasyEmptyKitProtocol
        }
        set {
            UITableView.swizzleIfNeed
            objc_setAssociatedObject(self, &delegateKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    fileprivate var emptyView : EmptyBackView? {
        get {
            if let view = objc_getAssociatedObject(self, &emptyViewKey) as? EmptyBackView {
                return view
            }
            let emptyV = Bundle.main.loadNibNamed("EmptyBackView", owner: self, options: nil)?.last as! EmptyBackView
            emptyV.isHidden = true
            objc_setAssociatedObject(self, &emptyViewKey, emptyV, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return emptyV
        }
        set {
            objc_setAssociatedObject(self, &emptyViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var itemsCount : Int {
        if let dataSource = self.dataSource {
            let sections = dataSource.numberOfSections?(in: self) ?? 1
            
            return itemsCount(in: sections, with: { (section) -> Int in
                return dataSource.tableView(self, numberOfRowsInSection: sections)
            })
        }
        return 0
    }
    
    fileprivate var reloadTime : Int {
        get {
            if let num = objc_getAssociatedObject(self, &reloadTimeKey) {
                return num as! Int
            }
            return 0
        }
        set {
            objc_setAssociatedObject(self, &reloadTimeKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    fileprivate func itemsCount(in sections: Int, with transform: (Int) -> Int) -> Int {
        var items = 0
        for sectionIndex in 0..<sections {
            items += transform(sectionIndex)
        }
        return items
    }
    
    fileprivate func invalidata() {
        guard let emptyView = objc_getAssociatedObject(self, &emptyViewKey) as? EmptyBackView else {
            return
        }
        emptyView.removeFromSuperview()
        self.emptyView = nil
        self.isScrollEnabled = true
    }
    
    fileprivate func setupEmptyView(withItemsCount itemCount : Int) -> Bool {
        
        
        if (self.emptyDelegate != nil && itemCount != 0) {
            invalidata()
            return false
        }
        
        
        if self.reloadTime == 1 {
            invalidata()
            return false
        }
        
        guard let view = emptyView else {
            invalidata()
            return false
        }
        
        if view.superview == nil {
            if self.subviews.count > 1 {
                self.insertSubview(view, at: 0)
            } else {
                self.addSubview(view)
            }
            
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraint(NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
            let inset = self.contentInset
            self.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: -inset.left - inset.right))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: .height , relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: -inset.top - inset.bottom))
        }
        
        guard let model = emptyDelegate?.emptyTableViewData() else {
            return false
        }

        view.isUserInteractionEnabled = true
        view.backgroundColor = .clear

        view.isHidden = false
        view.clipsToBounds = true
        view.param = model;
        return true
    }
}
