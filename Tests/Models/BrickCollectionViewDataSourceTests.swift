//
//  BrickDataSourceTests.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class BrickCollectionViewDataSourceTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        unlockFatalError()
    }

    func testNoBrickCollectionView() {
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), collectionViewLayout: UICollectionViewFlowLayout())
        let brickView = BrickCollectionView()
//        brickView.setSection(BrickSection(bricks: [ DummyBrick() ]))
        collectionView.dataSource = brickView

        expectFatalError("Only BrickCollectionViews are supported") {
            collectionView.layoutSubviews()
        }
    }

    func testFatalErrorForBrick() {
        let brickView = BrickCollectionView()
        let indexPath = NSIndexPath(forItem: 1, inSection: 1)
        brickView.setSection(BrickSection(bricks: [ DummyBrick() ]))

        expectFatalError("Brick not found at indexPath: SECTION - \(indexPath.section) - ITEM: \(indexPath.item). This should never happen") {
            brickView.brick(at: indexPath)
        }
    }

}
