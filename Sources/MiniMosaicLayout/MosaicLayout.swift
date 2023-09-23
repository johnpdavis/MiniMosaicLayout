//
//  MosaicLayout.swift
//  ViewKitUI
//
//  Created by John Davis on 6/13/23.
//  Copyright © 2023 John Davis. All rights reserved.
//

import Foundation
import SwiftUI

public class MiniMosaicLayoutModel: ObservableObject {
    public let canvasWidth: CGFloat
    public let canvasHeight: CGFloat
    
    public let numberOfColumns: Int
    public let numberOfRows: Int
    
    public let interItemSpacing: CGFloat
    public let sizeables: [LayoutSizeProviding]
    
    public init(canvasWidth: CGFloat, 
                canvasHeight: CGFloat, 
                numberOfColumns: Int,
                numberOfRows: Int,
                interItemSpacing: CGFloat,
                sizeables: [LayoutSizeProviding]) {
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.numberOfColumns = numberOfColumns
        self.numberOfRows = numberOfRows
        self.interItemSpacing = interItemSpacing
        self.sizeables = sizeables
    }
    
    var miniMosaicLayoutEngine: MiniMosaicEngine {
        MiniMosaicEngine(canvasWidth: canvasWidth,
                         canvasHeight: canvasHeight,
                         numberOfColumns: numberOfColumns,
                         numberOfRows: numberOfRows,
                         interItemSpacing: interItemSpacing,
                         sizeables: sizeables)
    }
}

public struct MiniMosaicLayout: Layout {
    public struct MosaicCache {
        let frames: [Int: CGRect]
    }
    
    let model: MiniMosaicLayoutModel
    
    public init(model: MiniMosaicLayoutModel) {
        self.model = model
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout MosaicCache) -> CGSize {
        return CGSize(width: model.canvasWidth, height: model.canvasHeight)
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout MosaicCache) {
        print("Bounds: \(bounds)")
        for index in subviews.indices {
            guard index >= 0, index < cache.frames.count else {
                subviews[index].place(at: .zero, proposal: ProposedViewSize(.zero))
                continue
            }
            
            let cachedFrame = cache.frames[index] ?? .zero
            
            let placementProposal = ProposedViewSize(width: cachedFrame.width, height: cachedFrame.height)
            let origin = cachedFrame.origin
            
//            print("\(placementProposal) @ \(origin)")
            subviews[index].place(at: origin,
                                  proposal: placementProposal)
        }
    }
    
    public func makeCache(subviews: Subviews) -> MosaicCache {
        let frames = model.miniMosaicLayoutEngine.computePlacements()
        return MosaicCache(frames: frames)
    }
}
