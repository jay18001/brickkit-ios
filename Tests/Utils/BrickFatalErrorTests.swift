//
//  BrickFatalErrorTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/21/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

private let brickFrame: CGRect = CGRect(x: 0, y: 0, width: 320, height: 480)

class ZBrickFatalErrorTests: XCTestCase {

    // Because of issues with Travis not running the expectFatalError tests, we have them all in one test
    func testAllFatalErrors() {
        // func testNoBrickCollectionView() {
            expectFatalError("Only BrickCollectionViews are supported") {
                let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), collectionViewLayout: UICollectionViewFlowLayout())
                let brickView = BrickCollectionView()
                //        brickView.setSection(BrickSection(bricks: [ DummyBrick() ]))
                collectionView.dataSource = brickView

                collectionView.layoutSubviews()
            }
        //}

        // func testFatalErrorForBrick() {
            expectFatalError {
                let brickView = BrickCollectionView()
                let indexPath = NSIndexPath(forItem: 1, inSection: 1)
                brickView.setSection(BrickSection(bricks: [ DummyBrick() ]))

                brickView.brick(at: indexPath)
            }
        //}

        // func testRawValue() {
            expectFatalError("Only Ratio and Fixed are allowed") {
                let auto = BrickDimension.Auto(estimate: .Fixed(size: 30))
                BrickDimension._rawValue(for: 100, in: UIView(), with: auto)
            }
        //}

        // func testCalculateSectionsIfNeededWithoutDataSource() {
            expectFatalError("No dataSource was set for BrickFlowLayout") {
                let brickFlowLayout = BrickFlowLayout()
                brickFlowLayout.calculateSectionsIfNeeded()
            }
        //}

        // func testCalculateZIndexWithoutCollectionView() {
            expectFatalError {
                let brickFlowLayout = BrickFlowLayout()
                brickFlowLayout.calculateZIndex()
            }
        //}

        // func testCalculateSectionsWithoutCollectionView() {
            expectFatalError {
                let brickFlowLayout = BrickFlowLayout()
                brickFlowLayout.calculateSections()
            }
        //}

        // func testCalculateSectionWithoutCollectionView() {
            expectFatalError {
                let brickFlowLayout = BrickFlowLayout()
                brickFlowLayout.calculateSection(for: 5, with: nil, containedInWidth: 320, at: CGPoint.zero)
            }
        //}

        // func testUpdateHeightWithoutDataSource() {
            expectFatalError {
                let brickFlowLayout = BrickFlowLayout()
                brickFlowLayout.updateHeight(NSIndexPath(forItem: 0, inSection: 0), newHeight: 320)
            }
        //}


        // Mark: - BrickLayoutSectionTests

        // func testNoInvalidateWithoutDataSource() {
            expectFatalError {
                let dataSource  = FixedBrickLayoutSectionDataSource(widthRatios: [], heights: [], edgeInsets: UIEdgeInsetsZero, inset: 0)
                let section = BrickLayoutSection(
                    sectionIndex: 0,
                    sectionAttributes: nil,
                    numberOfItems: 0,
                    origin: CGPoint.zero,
                    sectionWidth: 0,
                    dataSource: dataSource)

                section.dataSource = nil

                section.invalidate(at: 0, updatedAttributes: nil)
            }
        //}

        /// Repeat count on a BrickSection is not allowed
        // func testRepeatCountOnSection() {
            expectFatalError {
                let section = BrickSection(bricks: [
                    BrickSection("Section", bricks: [
                        Brick("Brick"),
                        ])
                    ])

                let fixed = FixedRepeatCountDataSource(repeatCountHash: ["Section": 5])
                section.repeatCountDataSource = fixed

                let collection: CollectionInfo = CollectionInfo(index: 0, identifier: "")
                section.currentSectionCounts(in: collection)
            }
        //}

        // func testWithoutRegisteringBrick() {
            expectFatalError {
                let dummyBrick = DummyBrick("Brick 1")
                let brickView = BrickCollectionView(frame: brickFrame)
                let section = BrickSection(bricks: [
                    dummyBrick
                    ])
                brickView.setSection(section)
                brickView.layoutSubviews()
            }
        //}

        // func testCantSetTextOfButtonBrickWithWrongDataSource() {
            expectFatalError {
                let buttonBrick = ButtonBrick(dataSource: FixedButtonDataSource())
                buttonBrick.title = "Hello World"
            }
        //}

        // func testCantGetTextOfButtonBrickWithWrongDataSource() {
            expectFatalError {
                let buttonBrick = ButtonBrick(dataSource: FixedButtonDataSource())
                let _ = buttonBrick.title
            }
        //}

        // func testCantSetConfigureCellBlockOfButtonBrickWithWrongDataSource() {
            expectFatalError {
                let buttonBrick = ButtonBrick(dataSource: FixedButtonDataSource())
                buttonBrick.configureButtonBlock = { cell in
                }
            }
        //}

        // func testCantGetConfigureCellBlockOfButtonBrickWithWrongDataSource() {
            expectFatalError {
                let buttonBrick = ButtonBrick(dataSource: FixedButtonDataSource())
                let _ = buttonBrick.configureButtonBlock
            }
        //}

        // func testCantSetTextOfLabelBrickWithWrongDataSource() {
            expectFatalError {
                let labelBrick = LabelBrick(dataSource: FixedLabelDataSource())
                labelBrick.text = "Hello World"
            }
        //}

        // func testCantGetTextOfLabelBrickWithWrongDataSource() {
            expectFatalError {
                let labelBrick = LabelBrick(dataSource: FixedLabelDataSource())
                let _ = labelBrick.text
            }
        //}

        // func testCantSetConfigureCellBlockOfLabelBrickWithWrongDataSource() {
            expectFatalError {
                let labelBrick = LabelBrick(dataSource: FixedLabelDataSource())
                labelBrick.configureCellBlock = { cell in
                }
            }
        //}

        // func testCantGetConfigureCellBlockOfLabelBrickWithWrongDataSource() {
            expectFatalError {
                let labelBrick = LabelBrick(dataSource: FixedLabelDataSource())
                let _ = labelBrick.configureCellBlock
            }
        //}

        // func testWithoutCollectionView() {

            expectFatalError {
                let layout = BrickFlowLayout()
                let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .Horizontal(.Center))
                layout.behaviors.insert(snapBehavior)
                layout.targetContentOffsetForProposedContentOffset(CGPoint.zero, withScrollingVelocity: CGPoint.zero)
            }

        //}

        // func testSetWrongCollectionViewLayout() {
            expectFatalError("BrickCollectionView: the layout needs to be of type `BrickLayout`") {
                let brickView = BrickCollectionView(frame: brickFrame)
                brickView.collectionViewLayout = UICollectionViewFlowLayout()
            }
        //}

        // func testRegisterBrickNoNibOrClass() {
            expectFatalError("Nib or cell class not found") {
                let brickView = BrickCollectionView(frame: brickFrame)
                brickView.registerBrickClass(DummyBrickWithNoNib.self)
            }
        //}

        // func testFatalErrorForBrickInfo() {
            expectFatalError {
                let brickView = BrickCollectionView(frame: brickFrame)
                brickView.registerBrickClass(DummyBrick.self)
                brickView.setSection(BrickSection(bricks: [ DummyBrick() ]))

                let indexPath = NSIndexPath(forItem: 1, inSection: 1)

                brickView.brickInfo(at: indexPath)
            }
        //}
        
        // func testCalculateSectionThatDoesntExist() {
            expectFatalError {
                let brickView = BrickCollectionView(frame: brickFrame)

                brickView.registerBrickClass(DummyBrick.self)

                let section = BrickSection(bricks: [
                    DummyBrick("DummyBrick")
                    ]
                )
                brickView.setSection(section)
                brickView.layoutSubviews()

                let flow = brickView.collectionViewLayout as! BrickFlowLayout
                flow.calculateSection(for: 5, with: nil, containedInWidth: 0, at: CGPoint.zero)
            }
        //}

    }
}
