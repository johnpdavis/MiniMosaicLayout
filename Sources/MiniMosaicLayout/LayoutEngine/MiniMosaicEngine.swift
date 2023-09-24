//
//  MiniMosaicEngine.swift
//  MiniMosaic
//
//  Created by John Davis on 9/21/23.
//

import Foundation

class MiniMosaicEngine {

    let canvasWidth: CGFloat
    let canvasHeight: CGFloat
    
    let numberOfColumns: Int
    let numberOfRows: Int
    
    let interItemSpacing: CGFloat
    let guttersOnOutside: Bool
    let sizeables: [LayoutSizeProviding]
    
    let imageBlockSizeEngine: ImageBlockSizeEngine
    
    public lazy var pageLayoutEngine: PageLayoutEngine = {
        PageLayoutEngine(canvasWidth: canvasWidth,
                         canvasHeight: canvasHeight,
                         numberOfColumns: numberOfColumns,
                         numberOfRows: numberOfRows,
                         pixelSizeOfBlock: imageBlockSizeEngine.pixelSizeOfBlock,
                         interItemSpacing: interItemSpacing)
    }()
    
    init(canvasWidth: CGFloat,
         canvasHeight: CGFloat,
         numberOfColumns: Int,
         numberOfRows: Int,
         interItemSpacing: CGFloat,
         guttersOnOutside: Bool,
         sizeables: [LayoutSizeProviding]) {
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.numberOfColumns = numberOfColumns
        self.numberOfRows = numberOfRows
        self.interItemSpacing = interItemSpacing
        self.guttersOnOutside = guttersOnOutside
        self.sizeables = sizeables
        
        let columnWidth: CGFloat = {
            guard numberOfColumns > 0 else { return 1 }
            let outsideExtra = guttersOnOutside ? 2 : 0
            let gutterTotal = CGFloat(numberOfColumns + outsideExtra) * interItemSpacing
            return (canvasWidth - gutterTotal) / CGFloat(numberOfColumns)
        }()
        
        let rowHeight: CGFloat = {
            guard numberOfRows > 0 else { return 1 }
            let outsideExtra = guttersOnOutside ? 2 : 0
            let gutterTotal = CGFloat(numberOfRows + outsideExtra) * interItemSpacing
            return (canvasHeight - gutterTotal) / CGFloat(numberOfRows)
        }()
        
        self.imageBlockSizeEngine = ImageBlockSizeEngine(canvasWidth: canvasWidth,
                                                         canvasHeight: canvasHeight, 
                                                         numberOfColumns: numberOfColumns,
                                                         numberOfRows: numberOfRows,
                                                         pixelSizeOfBlock: CGSize(width: columnWidth, height: rowHeight))
    }
    
    var frames: [CGRect] = []
    
    func computePlacements() -> [Int: CGRect] {
//        let blockSizes = sizeables.map {
//            imageBlockSizeEngine.calculateBlockSize(of: $0)
//        }
        print("Columns: \(numberOfColumns) Rows: \(numberOfRows)")
//        print(blockSizes)
        
        // Compute pages with image represenations that change progressively.
        
        let maxDimension = max(numberOfRows, numberOfColumns)
        
        var sizeableVariants: [[LayoutSizeProviding]] = []

        (1...(maxDimension)).reversed().forEach { iteration in
            let ratio: CGFloat = CGFloat(iteration) / CGFloat(maxDimension)
            print(ratio)
            let normalizedSizables = sizeables.map { sizeable in
                let ratio = sizeable.width / sizeable.height
                if sizeable.width > sizeable.height {
                    if sizeable.width > canvasWidth {
                        return CGSize(width: canvasWidth, height: canvasWidth / ratio)
                    } else {
                        return CGSize(width: sizeable.width, height: sizeable.height)
                    }
                } else {
                    if sizeable.height > canvasHeight {
                        return CGSize(width: canvasHeight * ratio, height: canvasHeight)
                    } else {
                        return CGSize(width: sizeable.width, height: sizeable.height)
                    }
                }
            }
            
            let ratioedSizables = normalizedSizables.map { CGSize(width: $0.width * ratio, height: $0.height * ratio) }
            print(ratioedSizables)
            sizeableVariants.append(ratioedSizables)
        }
        
        let pages = sizeableVariants.map { pageLayoutEngine.layoutPageWithItems($0) }
        let pagesThatFillTheMosaic = pages.filter { page in
            !page.columnSizes.contains(where: { $0.height < numberOfRows })
        }
        
        let pagesToInvestigate = pagesThatFillTheMosaic.isEmpty ? pages : pagesThatFillTheMosaic
        
        // Now that we have pages that likely fill the canvas. we need to pick the "best"
        // Lets try the one that has the most elements?
        
//        let bestPage = pagesToInvestigate.max { left, right in
//            print("\(left.itemBlockSlots.count) vs. \(right.itemBlockSlots.count)")
//            return left.itemBlockSlots.count >= right.itemBlockSlots.count
//        }
        
        let bestPage = pagesToInvestigate.sorted(by:  { $0.itemBlockSlots.count <= $1.itemBlockSlots.count }).last
        
//        let page = pageLayoutEngine.layoutPageWithItems(sizeables)
//        print(page.itemBlockSlots)
        
        guard let page = bestPage else { return [:] }
        let frames = layoutSizes(for: sizeables, inPage: page)
        return frames
    }
    
    public func layoutSizes(for itemSizes: [LayoutSizeProviding], inPage page: PageState) -> [Int: CGRect] {
        let pageMinY: CGFloat = 0
        var itemFrames: [Int: CGRect] = [:]
        page.itemBlockSlots.forEach { index, slot in
            let blockSizeHeight = imageBlockSizeEngine.pixelSizeOfBlock.height
            let blockSizeWidth = imageBlockSizeEngine.pixelSizeOfBlock.width
            
            let gutterExtra = guttersOnOutside ? 1 : 0
            
            let localOffsetX: CGFloat = (CGFloat(slot.originColumn) * blockSizeWidth) + (interItemSpacing * CGFloat(slot.blockSize.width + gutterExtra))
            let localOffsetY: CGFloat =  (CGFloat(slot.originRow) * blockSizeHeight) + (interItemSpacing * CGFloat(slot.blockSize.height + gutterExtra))
            
            let width = blockSizeWidth * CGFloat(slot.blockSize.width) - (interItemSpacing * CGFloat(slot.blockSize.width - gutterExtra))
            let height = (blockSizeHeight * CGFloat(slot.blockSize.height)) - (interItemSpacing * CGFloat(slot.blockSize.height - gutterExtra))
            
            let frame = CGRect(x: localOffsetX, y: localOffsetY + pageMinY, width: width, height: height)
            
            itemFrames[index] = frame
        }
        
        return itemFrames
    }
}
