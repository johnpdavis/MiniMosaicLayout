//
//  ImageBlockSize.swift
//  MosaicLayoutEngine
//
//  Created by John Davis on 5/17/22.
//

import Foundation

public class ImageBlockSize: BlockSize {
    public let sizeProvider: LayoutSizeProviding
    
    public init(width: Int, height: Int, sizeProvider: LayoutSizeProviding) {
        self.sizeProvider = sizeProvider
        super.init(width: width, height: height)
    }
}
