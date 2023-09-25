//
//  LayoutSizeProviding.swift
//  MosaicLayoutEngine
//
//  Created by John Davis on 5/16/22.
//

import CoreGraphics
#if os(macOS)
import AppKit
#else
import UIKit
#endif


public protocol LayoutSizeProviding {
    var sizeForLayout: CGSize { get }
}

extension LayoutSizeProviding {
    var width: CGFloat {
        return sizeForLayout.width
    }
    
    var height: CGFloat {
        return sizeForLayout.height
    }
}

#if os(macOS)
extension NSImage: LayoutSizeProviding {
    public var sizeForLayout: CGSize { size }
}

#else
extension UIImage: LayoutSizeProviding {
    public var sizeForLayout: CGSize { size }
}

#endif


extension CGSize: LayoutSizeProviding {
    public var sizeForLayout: CGSize { self }
}
