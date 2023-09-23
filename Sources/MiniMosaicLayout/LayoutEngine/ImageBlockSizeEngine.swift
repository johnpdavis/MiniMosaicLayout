//
//  ImageBlockSizeEngine.swift
//  MosaicLayoutEngine
//
//  Created by John Davis on 5/16/22.
//

import CoreGraphics
import Foundation

class ImageBlockSizeEngine {
    // Provided on init
    let canvasWidth: CGFloat
    let canvasHeight: CGFloat
    
    let numberOfColumns: Int
    let numberOfRows: Int

    let pixelSizeOfBlock: CGSize
    
    internal init(canvasWidth: CGFloat, 
                  canvasHeight: CGFloat,
                  numberOfColumns: Int,
                  numberOfRows: Int,
                  pixelSizeOfBlock: CGSize) {
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.numberOfColumns = numberOfColumns
        self.numberOfRows = numberOfRows
        self.pixelSizeOfBlock = pixelSizeOfBlock
    }
    
    func calculateBlockSize(of sizeProviding: LayoutSizeProviding) -> ImageBlockSize {
        if sizeProviding.height > sizeProviding.width {
            return calculateBlockSizePrioritizeHeight(of: sizeProviding)
        } else {
            return calculateBlockSizePrioritizeWidth(of: sizeProviding)
        }
    }
    
    func calculateBlockSizePrioritizeHeight(of sizeProviding: LayoutSizeProviding) -> ImageBlockSize {
        let height = calculateBlockHeight(of: sizeProviding)
        let width = calculateBlockWidth(of: sizeProviding, forHeight: height)
        
        return ImageBlockSize(width: width, height: height, sizeProvider: sizeProviding)
    }
    
    func calculateBlockSizePrioritizeWidth(of sizeProviding: LayoutSizeProviding) -> ImageBlockSize {
        let width = calculateBlockWidth(of: sizeProviding)
        let height = calculateBlockHeight(of: sizeProviding, forWidth: width)
        
        return ImageBlockSize(width: width, height: height, sizeProvider: sizeProviding)
    }
    
    func reduce(imageBlockSize: ImageBlockSize) {
        imageBlockSize.reduce()
        //recalculate the height now.
        let height = self.calculateBlockHeight(of: imageBlockSize.sizeProvider, forWidth: imageBlockSize.width)
        imageBlockSize.height = height
    }

    func forceWidth(_ width: Int, of imageBlockSize: ImageBlockSize) {
        imageBlockSize.width = width
        let height = self.calculateBlockHeight(of: imageBlockSize.sizeProvider, forWidth: imageBlockSize.width)
        imageBlockSize.height = height
    }
    
    func forceHeight(_ height: Int, of imageBlockSize: ImageBlockSize) {
        imageBlockSize.height = height
        let width = self.calculateBlockWidth(of: imageBlockSize.sizeProvider, forHeight: height)
        imageBlockSize.width = width
    }
    
    func calculateBlockWidth(of sizeProviding: LayoutSizeProviding) -> Int {
        // Divide by zero prevention
        guard sizeProviding.width > 0 && sizeProviding.height > 0 else {
            return 1
        }

        var widthBlocks = Int(round(sizeProviding.width)) / Int(round(pixelSizeOfBlock.width))
        
        //************************************************************************
        // first we determine the widthblocks of the asset.
        //************************************************************************
        //prevent 0 returned width.
        if widthBlocks < 1 {
            widthBlocks = 1
        }
        
        // prevent exceding the available size
        if widthBlocks > numberOfColumns {
            widthBlocks = numberOfColumns
        }
        
        return widthBlocks
    }
    
    func calculateBlockHeight(of sizeProviding: LayoutSizeProviding) -> Int {
        // Divide by zero prevention
        guard sizeProviding.width > 0 && sizeProviding.height > 0 else {
            return 1
        }
        
        //what's the width to height ratio.
        let whRatio = sizeProviding.width / sizeProviding.height
        
        var heightBlocks = Int(round(sizeProviding.height)) / Int(round(pixelSizeOfBlock.height))
        
        //prevent 0 returned height.
        if heightBlocks < 1 {
            heightBlocks = 1
        }
        
        // prevent exceding the available size
        if heightBlocks > numberOfRows {
            heightBlocks = numberOfRows
        }
        
        return heightBlocks
    }
    
    func calculateBlockHeight(of sizeProviding: LayoutSizeProviding, forWidth blockWidth: Int) -> Int {
        let height = sizeProviding.height
        let width = sizeProviding.width
        
        guard width > 0 else {
            return 1
        }
        
        let ratioWH = Double(width) / Double(height)
        var heightBlocks: Int = 0

        let pixelWidth = floor( Double(pixelSizeOfBlock.width) * Double(blockWidth))
        let pixelheightForBlockWidth = pixelWidth / ratioWH

        heightBlocks = Int(round(pixelheightForBlockWidth / Double(pixelSizeOfBlock.height)))
        
        if heightBlocks < 1 {
            heightBlocks = 1
        }
        
        if heightBlocks > numberOfRows {
            heightBlocks = numberOfRows
        }
        
        return heightBlocks
    }
    
    func calculateBlockWidth(of sizeProviding: LayoutSizeProviding, forHeight blockHeight: Int) -> Int {
        let height = sizeProviding.height
        let width = sizeProviding.width
        
        guard height > 0 else {
            return 1
        }
        
        let ratioWH = Double(width) / Double(height)
        var widthBlocks: Int = 0
        
        let pixelHeight = floor(Double(pixelSizeOfBlock.height) * Double(blockHeight))
        let pixelWidthForBlockHeight = pixelHeight * ratioWH

        widthBlocks = Int(round(pixelWidthForBlockHeight / Double(pixelSizeOfBlock.width)))
        
        if widthBlocks < 1 {
            widthBlocks = 1
        }
        
        if widthBlocks > numberOfColumns {
            widthBlocks = numberOfColumns
        }
        
        return widthBlocks
    }
}
