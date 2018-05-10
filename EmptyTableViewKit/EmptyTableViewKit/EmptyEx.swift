//
//  EmptyEx.swift
//  EmptyTableViewKit
//
//  Created by Apple on 2018/5/7.
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

fileprivate extension UIScrollView {
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

    @objc fileprivate func ept_reloadData() {
        guard ept.setupEmptyView(withItemsCount: ept.itemsCount) else {
            return
        }
        ept.emptyView?.didTappedButton = {
            [weak self] button in
            guard let strongSelf = self else {
                return
            }
            strongSelf.ept.delegate?.emptyButton(button, tappedIn: strongSelf)
        }

        ept.emptyView?.didTappedEmptyView = { [weak self] view in
            guard let strongSelf = self else {
                return
            }
            strongSelf.ept.delegate?.emptyView(view, tappedIn: strongSelf)
        }
    }
    
}

extension UITableView {
    static let swizzleIfNeed: () = {
        UITableView.swizzle(originSelector: #selector(reloadData), to: #selector(swizzle_reloadData))
        UITableView.swizzle(originSelector: #selector(endUpdates), to: #selector(swizzle_endUpdates))
    }()
    
    @objc fileprivate func swizzle_reloadData(){
        swizzle_reloadData()
        ept_reloadData()
    }
    
    @objc fileprivate func swizzle_endUpdates(){
        swizzle_endUpdates()
        ept_reloadData()
    }
}

extension UICollectionView {
    static let swizzleIfNeed : () = {
        UICollectionView.swizzle(originSelector: #selector(reloadData), to: #selector(swizzle_reloadData))
    }()
    
    @objc fileprivate func swizzle_reloadData(){
        swizzle_reloadData()
        ept_reloadData()
    }
}

public extension Empty where Base : UIScrollView {
    weak var dataSource : EmptyTableViewKitDataSource? {
        get {
            return objc_getAssociatedObject(base, &datasourceKey) as? EmptyTableViewKitDataSource
        }
        set {
            UITableView.swizzleIfNeed
            UICollectionView.swizzleIfNeed
            objc_setAssociatedObject(base, &datasourceKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    weak var delegate : EmptyTableViewDelegate? {
        get {
            UITableView.swizzleIfNeed
            UICollectionView.swizzleIfNeed
            return objc_getAssociatedObject(base, &delegateKey) as? EmptyTableViewDelegate
        }
        set {
            objc_setAssociatedObject(base, &delegateKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    fileprivate var customView : UIView? {
        get {
            return objc_getAssociatedObject(base, &customViewKey) as? UIView
        }
        set {
            objc_setAssociatedObject(base, &customViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var emptyView : EmptyView? {
        get {
            if let view = objc_getAssociatedObject(base, &emptyViewKey) as? EmptyView {
                return view
            }
            let emptyV = EmptyView()
            emptyV.isHidden = true
            objc_setAssociatedObject(base, &emptyViewKey, emptyV, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return emptyV
        }
        set {
            objc_setAssociatedObject(base, &emptyViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var itemsCount : Int {
        if let tableView = base as? UITableView,let dataSource = tableView.dataSource {
            let sections = dataSource.numberOfSections?(in: tableView) ?? 1
            return itemsCount(in: sections, with: { (section) -> Int in
                return dataSource.tableView(tableView, numberOfRowsInSection: sections)
            })
        }
        
        if let tableView = base as? UICollectionView,let dataSource = tableView.dataSource {
            let sections = dataSource.numberOfSections?(in: tableView) ?? 1
            return itemsCount(in: sections, with: { (section) -> Int in
                return dataSource.collectionView(tableView, numberOfItemsInSection: sections)
            })
        }
        return 0
    }
    
    fileprivate var reloadTime : Int? {
        get {
            return objc_getAssociatedObject(base, &reloadTimeKey) as? Int
        }
        set {
            objc_setAssociatedObject(base, &reloadTimeKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

public extension Empty where Base : UIScrollView {
    func reloadData() -> Void {
        base.ept_reloadData()
    }
    
    fileprivate func itemsCount(in sections: Int, with transform: (Int) -> Int) -> Int {
        var items = 0
        for sectionIndex in 0..<sections {
            if let sectionsToIgnore = dataSource?.sectionsToIgnore(in: base), sectionsToIgnore.contains(sectionIndex) {
                continue
            }
            items += transform(sectionIndex)
        }
        return items
    }
    
    fileprivate func invalidata() {
        guard let emptyView = objc_getAssociatedObject(base, &emptyViewKey) as? EmptyView else {
            return
        }
        emptyView.prepareForReuse()
        emptyView.removeFromSuperview()
        self.emptyView = nil
        base.isScrollEnabled = true
    }
    
    fileprivate func setupEmptyView(withItemsCount itemCount : Int) -> Bool {
        guard let dataSource = dataSource,itemCount == 0 else {
            invalidata()
            return false
        }
        
        if let shoudldDisplay = delegate?.emptyViewIsDisplay(), shoudldDisplay == false {
            invalidata()
            return false
        }
        
        guard let view = emptyView else {
            invalidata()
            return false
        }
        
        if view.superview == nil {
            if base is UITableView && base is UICollectionView && base.subviews.count > 1 {
                base.insertSubview(view, at: 0)
            } else {
                base.addSubview(view)
            }
            
            view.translatesAutoresizingMaskIntoConstraints = false
            base.addConstraint(NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: base, attribute: .left, multiplier: 1, constant: 0))
            base.addConstraint(NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: base, attribute: .right, multiplier: 1, constant: 0))
            base.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: base, attribute: .top, multiplier: 1, constant: 0))
            base.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: base, attribute: .bottom, multiplier: 1, constant: 0))
            let inset = base.contentInset
            base.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: base, attribute: .width, multiplier: 1, constant: -inset.left - inset.right))
            base.addConstraint(NSLayoutConstraint(item: view, attribute: .height , relatedBy: .equal, toItem: base, attribute: .height, multiplier: 1, constant: -inset.top - inset.bottom))
        }
        
        view.prepareForReuse()
        view.customView = nil
        view.titleLabel.attributedText = dataSource.titleForEmpty(in: base)
        view.detailLabel.attributedText = dataSource.descriptionForEmpty(in: base)
        let img = dataSource.imageForEmpty(in: base)
        view.imageView.image = img?.withRenderingMode(.alwaysOriginal)
        
        view.button.setAttributedTitle(dataSource.buttonTitleForEmpty(forState: .normal, in: base), for: .normal)
        view.button.setAttributedTitle(dataSource.buttonTitleForEmpty(forState: .highlighted, in: base), for: .highlighted)
        view.button.setAttributedTitle(dataSource.buttonTitleForEmpty(forState: .selected, in: base), for: .selected)
        view.button.backgroundColor = dataSource.buttonBackgroundColorForEmpty(in: base)

        view.isUserInteractionEnabled = true
        view.backgroundColor = .clear
        view.verticalSpace = 10
        view.verticalOffset = 0
        view.horizontalSpace = 20
        view.minimumButtonWidth = 120
        view.fadeInOnDisplay = true
        view.isHidden = true
        view.clipsToBounds = true
        view.autoInset = true
        view.setupConstraints()
        return true
    }
  
}
