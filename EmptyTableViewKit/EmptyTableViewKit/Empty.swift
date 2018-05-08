//
//  Empty.swift
//  EmptyTableViewKit
//
//  Created by Apple on 2018/5/7.
//  Copyright © 2018年 Apple. All rights reserved.
//

import Foundation
public final class Empty<Base> {
    public let base : Base
    public init (_ base : Base ) {
        self.base = base
    }
}

public protocol EmptyCompatible {
    associatedtype CompatibleType
    var ept : CompatibleType { get }
    
}

public extension EmptyCompatible {
    public var ept : Empty<Self> {
        get {
            return Empty(self)
        }
    }
}

extension UIScrollView : EmptyCompatible {}
