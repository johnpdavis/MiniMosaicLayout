//
//  MosaicLayout.swift
//  ViewKitUI
//
//  Created by John Davis on 6/13/23.
//  Copyright © 2023 John Davis. All rights reserved.
//

import Foundation
import SwiftUI

class MiniMosaicLayoutModel: ObservableObject {
    let canvasWidth: CGFloat
    let canvasHeight: CGFloat
    
    let numberOfColumns: Int
    let numberOfRows: Int
    
    let interItemSpacing: CGFloat
    let sizeables: [LayoutSizeProviding]
    
    init(canvasWidth: CGFloat, canvasHeight: CGFloat, numberOfColumns: Int, numberOfRows: Int, interItemSpacing: CGFloat, sizeables: [LayoutSizeProviding]) {
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.numberOfColumns = numberOfColumns
        self.numberOfRows = numberOfRows
        self.interItemSpacing = interItemSpacing
        self.sizeables = sizeables
    }

    var miniMosaicLayoutImage: MiniMosaicEngine {
        MiniMosaicEngine(canvasWidth: canvasWidth,
                         canvasHeight: canvasHeight,
                         numberOfColumns: numberOfColumns,
                         numberOfRows: numberOfRows,
                         interItemSpacing: interItemSpacing,
                         sizeables: sizeables)
    }
}

struct MiniMosaicLayout: Layout {
    struct MosaicCache {
        let frames: [Int: CGRect]
    }
    
    var pageWidth: CGFloat
    
    let model: MiniMosaicLayoutModel
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout MosaicCache) -> CGSize {
        return CGSize(width: model.canvasWidth, height: model.canvasHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout MosaicCache) {
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
    
    func makeCache(subviews: Subviews) -> MosaicCache {
        let frames = model.miniMosaicLayoutImage.computePlacements()
        return MosaicCache(frames: frames)
    }
}
