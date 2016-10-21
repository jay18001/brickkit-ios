//
//  BrickCollectionViewTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class BrickCollectionViewTests: XCTestCase {

    var brickView: BrickCollectionView!

    override func setUp() {
        super.setUp()

        brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    override func tearDown() {
        super.tearDown()
        unlockFatalError()
    }

    func testDeinit() {
        brickView = CustomBrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        expectationForNotification("CustomBrickCollectionView.deinit", object: nil, handler: nil)
        brickView = nil
        waitForExpectationsWithTimeout(5, handler: nil)
        XCTAssertNil(brickView)
    }

    func testDeinitWithBehaviors() {
        brickView = CustomBrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let snapBehavior = SetZIndexLayoutBehavior(dataSource: FixedSetZIndexLayoutBehaviorDataSource(indexPaths: [:]))
        brickView.layout.behaviors = [snapBehavior]
        expectationForNotification("CustomBrickCollectionView.deinit", object: nil, handler: nil)
        brickView = nil
        waitForExpectationsWithTimeout(5, handler: nil)
        XCTAssertNil(brickView)
    }

    func testRegisterBrickWithNib() {
        brickView.registerBrickClass(DummyBrick.self)
        brickView.setSection(BrickSection(bricks: [
            DummyBrick()
            ]))
        brickView.layoutSubviews()

        let cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? DummyBrickCell
        XCTAssertNotNil(cell)
    }


    func testRegisterBrickWithClass() {
        brickView.registerBrickClass(DummyBrickWithoutNib.self)
        brickView.setSection(BrickSection(bricks: [
            DummyBrickWithoutNib()
            ]))
        brickView.layoutSubviews()

        let cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? DummyBrickWithoutNibCell
        XCTAssertNotNil(cell)
    }

    func testBrickInfo() {
        brickView.registerBrickClass(DummyBrick.self)
        brickView.setSection(BrickSection(bricks: [
            DummyBrick("Brick1")
            ]))
        brickView.layoutSubviews()

        let brickInfo = brickView.brickInfo(at: NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(brickInfo.brick.identifier, "Brick1")
        XCTAssertEqual(brickInfo.index, 0)
        XCTAssertEqual(brickInfo.collectionIndex, 0)
    }

    func testBrickInfoRepeatCount() {
        brickView.registerBrickClass(DummyBrick.self)
        let section = BrickSection(bricks: [
            DummyBrick("Brick1"),
            DummyBrick("Brick2"),
            ])
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 5, "Brick2": 5])
        section.repeatCountDataSource = repeatCountDataSource
        brickView.setSection(section)

        let brickInfo1 = brickView.brickInfo(at: NSIndexPath(forItem: 3, inSection: 1))
        XCTAssertEqual(brickInfo1.brick.identifier, "Brick1")
        XCTAssertEqual(brickInfo1.index, 3)
        XCTAssertEqual(brickInfo1.collectionIndex, 0)

        let brickInfo2 = brickView.brickInfo(at: NSIndexPath(forItem: 8, inSection: 1))
        XCTAssertEqual(brickInfo2.brick.identifier, "Brick2")
        XCTAssertEqual(brickInfo2.index, 3)
        XCTAssertEqual(brickInfo2.collectionIndex, 0)
    }

    func testBrickInfoCollectionBrick() {
        brickView.registerBrickClass(CollectionBrick.self)

        let collectionSection = BrickSection(bricks: [
            DummyBrick("Brick1")
            ])

        let section = BrickSection(bricks: [
            CollectionBrick("CollectionBrick", dataSource: CollectionBrickCellModel(section: collectionSection) { cell in
                cell.brickCollectionView.registerBrickClass(DummyBrick.self)
                })
            ])

        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CollectionBrickCell
        let collectionBrickView = cell!.brickCollectionView

        let brickInfo = collectionBrickView.brickInfo(at: NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(brickInfo.brick.identifier, "Brick1")
        XCTAssertEqual(brickInfo.index, 0)
        XCTAssertEqual(brickInfo.collectionIndex, 0)
        XCTAssertEqual(brickInfo.collectionIdentifier, "CollectionBrick")
    }

    func testBrickInfoCollectionBrickRepeatCount() {
        brickView.registerBrickClass(CollectionBrick.self)

        let collectionSection = BrickSection(bricks: [
            DummyBrick("Brick1", height: .Fixed(size: 10))
            ])

        let section = BrickSection(bricks: [
            CollectionBrick("CollectionBrick", dataSource: CollectionBrickCellModel(section: collectionSection) { cell in
                cell.brickCollectionView.registerBrickClass(DummyBrick.self)
                })
            ])
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["CollectionBrick": 5])
        section.repeatCountDataSource = repeatCountDataSource

        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 3, inSection: 1)) as? CollectionBrickCell
        let collectionBrickView = cell!.brickCollectionView

        let brickInfo = collectionBrickView.brickInfo(at: NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(brickInfo.brick.identifier, "Brick1")
        XCTAssertEqual(brickInfo.index, 0)
        XCTAssertEqual(brickInfo.collectionIndex, 3)
        XCTAssertEqual(brickInfo.collectionIdentifier, "CollectionBrick")
    }

    func testIndexPathsForBricksWithIdentifier() {
        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Section1", bricks: [
            DummyBrick("Brick1"),
            BrickSection("Section2", bricks: [
                DummyBrick("Brick1"),
                DummyBrick("Brick2")
                ])
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()
        XCTAssertEqual(brickView.indexPathsForBricksWithIdentifier("Section1"), [NSIndexPath(forItem: 0, inSection: 0)])
        XCTAssertEqual(brickView.indexPathsForBricksWithIdentifier("Section2"), [NSIndexPath(forItem: 1, inSection: 1)])
        XCTAssertEqual(brickView.indexPathsForBricksWithIdentifier("Brick1"), [NSIndexPath(forItem: 0, inSection: 1), NSIndexPath(forItem: 0, inSection: 2)])
        XCTAssertEqual(brickView.indexPathsForBricksWithIdentifier("Brick2"), [NSIndexPath(forItem: 1, inSection: 2)])
        XCTAssertEqual(brickView.indexPathsForBricksWithIdentifier("Brick3"), [])
    }

    func testReloadBricks() {
        brickView.registerBrickClass(DummyBrick.self)
        let brick = DummyBrick(width: .Ratio(ratio: 1/10))
        let section = BrickSection(bricks: [
            brick
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        var cell: DummyBrickCell?
        cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? DummyBrickCell
        XCTAssertEqual(cell?.frame.width, 32)
        XCTAssertEqual(cell?.frame.height, 64)

        brick.width = .Ratio(ratio: 1/5)

        let expectation = expectationWithDescription("Invalidate Bricks")

        brickView.invalidateBricks() { completed in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(500, handler: nil)

        brickView.layoutSubviews()

        cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? DummyBrickCell
        cell?.layoutIfNeeded()
        XCTAssertEqual(cell?.frame.width, 64)
        XCTAssertEqual(cell?.frame.height, 128)
    }

    func testReloadBricksWithBehaviors() {
        let offsetDataSource = FixedMultipleOffsetLayoutBehaviorDataSource(originOffsets: ["DummyBrick": CGSize(width: 10, height: 10)], sizeOffsets: nil)
        brickView.layout.behaviors.insert(OffsetLayoutBehavior(dataSource: offsetDataSource))

        brickView.registerBrickClass(DummyBrick.self)
        let brick = DummyBrick("DummyBrick")
        let section = BrickSection(bricks: [
            brick
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        var cell: DummyBrickCell?
        cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? DummyBrickCell
        XCTAssertEqual(cell?.frame.origin.x, 10)
        XCTAssertEqual(cell?.frame.origin.y, 10)

        offsetDataSource.originOffsets?["DummyBrick"]?.width = 100
        offsetDataSource.originOffsets?["DummyBrick"]?.height = 100

        let expectation = expectationWithDescription("Invalidate Bricks")

        brickView.invalidateBricks() { completed in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)

        brickView.layoutIfNeeded()

        cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? DummyBrickCell
        XCTAssertEqual(cell?.frame.origin.x, 100)
        XCTAssertEqual(cell?.frame.origin.y, 100)
    }

    func testCustomBrickWithSameIdentifier() {
        brickView.registerNib(UINib(nibName: "DummyBrick100", bundle: DummyBrick.bundle), forBrickWithIdentifier: "DummyBrick")
        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick("DummyBrick")
            ]
        )
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? DummyBrickCell
        XCTAssertEqual(cell?.frame, CGRect(x: 0, y: 0, width: 320, height: 100))
    }

    func testInvalidateRepeatCountForCollectionBrick() {
        brickView.registerBrickClass(CollectionBrick.self)

        let collectionSection = BrickSection(bricks: [
            DummyBrick("Brick1", height: .Fixed(size: 10))
            ])
        let fixed = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 0])
        collectionSection.repeatCountDataSource = fixed

        let section = BrickSection(bricks: [
            CollectionBrick("CollectionBrick", dataSource: CollectionBrickCellModel(section: collectionSection) { cell in
                cell.brickCollectionView.registerBrickClass(DummyBrick.self)
                })
            ])

        brickView.setSection(section)
        brickView.layoutSubviews()

        var cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CollectionBrickCell
        XCTAssertNil(cell?.frame)

        fixed.repeatCountHash["Brick1"] = 10
        brickView.reloadBricksWithIdentifiers(["CollectionBrick"], shouldReloadCell: true)
        brickView.layoutIfNeeded()

        cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CollectionBrickCell
        XCTAssertEqual(cell?.frame, CGRect(x: 0, y: 0, width: 320, height: 100))

    }

    func testRepeatCountMakesLabelGoTooBig() {
        brickView.registerBrickClass(LabelBrick.self)
        let section = BrickSection("Section", bricks: [
            BrickSection("RepeatSection", bricks: [
                LabelBrick("BrickIdentifiers.repeatLabel", width: .Ratio(ratio: 0.5), height: .Auto(estimate: .Fixed(size: 50)), text: "BRICK")
                ]),
            LabelBrick("BrickIdentifiers.titleLabel", text: "TITLE"),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        let fixed = FixedRepeatCountDataSource(repeatCountHash: ["BrickIdentifiers.repeatLabel": 1])
        section.repeatCountDataSource = fixed

        brickView.setSection(section)
        brickView.layoutSubviews()

        var cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))

        XCTAssertEqualWithAccuracy(cell?.frame.height ?? 0, 16.5, accuracy:  0.5)

        fixed.repeatCountHash = ["BrickIdentifiers.repeatLabel": 2]

        brickView.invalidateRepeatCounts(true)
        brickView.layoutIfNeeded()

        cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqualWithAccuracy(cell?.frame.height ?? 0, 16.5, accuracy:  0.5)
        
        fixed.repeatCountHash = ["BrickIdentifiers.repeatLabel": 1]

        brickView.invalidateRepeatCounts(true)
        brickView.layoutIfNeeded()

        cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqualWithAccuracy(cell?.frame.height ?? 0, 16.5, accuracy:  0.5)
        
    }

    func testWithImageInCollectionBrick() {
        brickView.registerBrickClass(CollectionBrick.self)

        let image: UIImage = UIImage(named: "image0", inBundle: NSBundle(forClass: self.classForCoder), compatibleWithTraitCollection: nil)!

        let section1 = BrickSection(bricks: [
            ImageBrick(width: .Ratio(ratio: 1/4), height: .Ratio(ratio: 1), dataSource: ImageBrickModel(image: image, contentMode: .ScaleAspectFill)),
            ])

        let section = BrickSection(backgroundColor: .whiteColor(), bricks: [
            CollectionBrick("Collection 1", backgroundColor: .orangeColor(), scrollDirection: .Horizontal, dataSource: CollectionBrickCellModel(section: section1, configureHandler: { (brickCollectionCell) in
                brickCollectionCell.brickCollectionView.registerBrickClass(ImageBrick.self)
            })),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 320, height: 80))
    }

    func testWithImagesInCollectionBrick() {
        brickView.registerBrickClass(CollectionBrick.self)

        let image: UIImage = UIImage(named: "image0", inBundle: NSBundle(forClass: self.classForCoder), compatibleWithTraitCollection: nil)!

        let section1 = BrickSection(bricks: [
            ImageBrick(width: .Ratio(ratio: 1/4), height: .Ratio(ratio: 1), dataSource: ImageBrickModel(image: image, contentMode: .ScaleAspectFill)),
            ])

        let section2 = BrickSection(bricks: [
            ImageBrick(width: .Ratio(ratio: 1/2), height: .Ratio(ratio: 1), dataSource: ImageBrickModel(image: image, contentMode: .ScaleAspectFill)),
            ])

        let section = BrickSection(backgroundColor: .whiteColor(), bricks: [
            CollectionBrick("Collection 1", backgroundColor: .orangeColor(), scrollDirection: .Horizontal, dataSource: CollectionBrickCellModel(section: section1, configureHandler: { (brickCollectionCell) in
                brickCollectionCell.brickCollectionView.registerBrickClass(ImageBrick.self)
            })),
            CollectionBrick("Collection 2", backgroundColor: .orangeColor(), scrollDirection: .Horizontal, dataSource: CollectionBrickCellModel(section: section2, configureHandler: { (brickCollectionCell) in
                brickCollectionCell.brickCollectionView.registerBrickClass(ImageBrick.self)
            })),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 320, height: 80))
        let cell2 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 0, y: 80, width: 320, height: 160))
    }
}
