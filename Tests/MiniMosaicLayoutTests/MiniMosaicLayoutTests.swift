import XCTest
@testable import MiniMosaicLayout

final class MiniMosaicLayoutTests: XCTestCase {
    func testFlushPlacementsReachCanvasBottomWhenOriginalPageDoesNotFillRows() throws {
        let engine = MiniMosaicEngine(
            canvasWidth: 200,
            canvasHeight: 400,
            numberOfColumns: 2,
            numberOfRows: 4,
            interItemSpacing: 0,
            guttersOnOutside: false,
            bottomEdgeBehavior: .flush,
            sizeables: [
                CGSize(width: 100, height: 100),
                CGSize(width: 100, height: 100),
                CGSize(width: 100, height: 100),
                CGSize(width: 100, height: 100)
            ]
        )

        let frames = engine.computePlacements()

        XCTAssertEqual(frames.count, 4)
        XCTAssertEqual(frames.values.map(\.maxY).max(), 400)
    }

    func testBestCandidatePrefersLeastDistortionBeforePlacedItemCount() throws {
        let leastDistortedPage = PageState(numberOfColumns: 2)
        leastDistortedPage.setSlot(BlockSlot(originColumn: 0, originRow: 0, blockSize: BlockSize(width: 1, height: 4)), for: 0)
        leastDistortedPage.setSlot(BlockSlot(originColumn: 1, originRow: 0, blockSize: BlockSize(width: 1, height: 4)), for: 1)

        let moreDistortedPage = PageState(numberOfColumns: 2)
        moreDistortedPage.setSlot(BlockSlot(originColumn: 0, originRow: 0, blockSize: BlockSize(width: 1, height: 3)), for: 0)
        moreDistortedPage.setSlot(BlockSlot(originColumn: 1, originRow: 0, blockSize: BlockSize(width: 1, height: 3)), for: 1)
        moreDistortedPage.setSlot(BlockSlot(originColumn: 0, originRow: 3, blockSize: BlockSize(width: 1, height: 1)), for: 2)
        moreDistortedPage.setSlot(BlockSlot(originColumn: 1, originRow: 3, blockSize: BlockSize(width: 1, height: 1)), for: 3)

        let leastDistortedCandidate = MiniMosaicEngine.PageCandidate(
            page: leastDistortedPage,
            originalBlockSizes: [
                0: BlockSize(width: 1, height: 4),
                1: BlockSize(width: 1, height: 4)
            ]
        )
        let moreDistortedCandidate = MiniMosaicEngine.PageCandidate(
            page: moreDistortedPage,
            originalBlockSizes: [
                0: BlockSize(width: 1, height: 3),
                1: BlockSize(width: 1, height: 3),
                2: BlockSize(width: 1, height: 3),
                3: BlockSize(width: 1, height: 3)
            ]
        )

        let bestCandidate = MiniMosaicEngine.bestCandidate(
            from: [moreDistortedCandidate, leastDistortedCandidate],
            numberOfRows: 4
        )

        XCTAssertTrue(bestCandidate?.page === leastDistortedPage)
    }
}
