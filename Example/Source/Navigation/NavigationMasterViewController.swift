//
//  NavigationMasterViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/22/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//
import BrickKit

/// ViewController that is responsible to show all the navigation items
class NavigationMasterViewController: BrickViewController {

    /// Reference to the label brick used for a navigation item
    var navItemBrick: LabelBrick!

    var dataSource: NavigationDataSource {
        return (self.navigationController as! NavigationViewController).dataSource
    }

    /// Index of a selected brick. If set, the bricks will show full width
    var indexOfSelectedBrick: Int? {
        didSet {
            if indexOfSelectedBrick != nil {
                brickCollectionView.section.edgeInsets = UIEdgeInsets.zero
                navItemBrick.width = .ratio(ratio: 1)

                #if os(iOS)
                let height = navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.size.height
                #else
                let height = navigationController!.navigationBar.frame.height
                #endif
                navItemBrick.height = .fixed(size: height)
            } else {
                brickCollectionView.section.edgeInsets = Constants.brickPatternEdgeInsets
                navItemBrick.width = .fixed(size: Constants.brickWidth)
                navItemBrick.height = .fixed(size: Constants.brickHeight)
            }
        }
    }

    // Mark: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        // Status bar should be above the title bar brick
        let imageView = UIImageView(image: Constants.inAppLogo.withRenderingMode(.alwaysTemplate))
        #if os(tvOS)
            imageView.tintColor = .brickPurple3
            
            collectionView?.delegate = self
            setNeedsFocusUpdate()
        #else
            imageView.tintColor = .brickGray1
        #endif
        self.navigationItem.titleView = imageView

        #if os(iOS)
        // Set the backbar button to empty string
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        #endif

        // Setup background
        self.view.backgroundColor = UIColor.white
        collectionView?.backgroundColor = .brickPattern

        // Setup hide behavior
        brickCollectionView.layout.hideBehaviorDataSource = self

        // Register Bricks
        registerNib(LabelBrickNibs.Chevron, forBrickWithIdentifier: NavigationIdentifiers.navItemBrick)
        registerBrickClass(LabelBrick.self)

        // Behaviors
        let offsetBehavior = OffsetLayoutBehavior(dataSource: self)
        self.layout.behaviors.insert(offsetBehavior)

        navItemBrick = LabelBrick(NavigationIdentifiers.navItemBrick, width: .fixed(size: Constants.brickWidth), height: .fixed(size: Constants.brickHeight), backgroundColor: .brickPurple3, dataSource: self)

        navItemBrick.brickCellTapDelegate = self

        let section = BrickSection(NavigationIdentifiers.navItemSection, bricks: [
            navItemBrick,
            ], inset: Constants.brickInset, edgeInsets: Constants.brickPatternEdgeInsets
        )

        section.repeatCountDataSource = self

        setSection(section)
    }

}

#if os(tvOS)
//MARK: - UICollectionViewDelegate
extension NavigationMasterViewController {
    func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> IndexPath? {
        
        let index = IndexPath(item: 0, section: 1)
        
        if let cell = brickCollectionView.cellForItem(at: index) as? FocusableBrickCell {
            _ = cell.willFocus()
        }
        
        return index
    }
}
#endif

// Mark: - BrickCellTapDelegate
extension NavigationMasterViewController: BrickCellTapDelegate {

    func didTapBrickCell(_ brickCell: BrickCell) {
        let index = brickCell.index
        dataSource.selectedItem = self.dataSource.item(for: index)

        let navigationDetailViewController = NavigationDetailViewController()
        navigationDetailViewController.navItem = self.dataSource.selectedItem
        navigationController?.pushViewController(navigationDetailViewController, animated: true)
    }

}

// MARK: - LabelBrickCellDataSource
extension NavigationMasterViewController: LabelBrickCellDataSource {

    func configureLabelBrickCell(_ cell: LabelBrickCell) {
        let text = dataSource.item(for: cell.index).title

        cell.label.text = text.uppercased()
        cell.label.textColor = Theme.textColorForNavigationTitle
        cell.label.font = Theme.fontForNavigationTitle
        cell.label.textAlignment = .left

        cell.imageView?.tintColor = UIColor.white

        cell.edgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

}

// MARK: - BrickRepeatCountDataSource
extension NavigationMasterViewController: BrickRepeatCountDataSource {

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        switch identifier {
        case NavigationIdentifiers.navItemBrick: return dataSource.numberOfItems
        default: return 1
        }
    }
    
}

// MARK: - OffsetLayoutBehaviorDataSource
extension NavigationMasterViewController: OffsetLayoutBehaviorDataSource {

    func offsetLayoutBehavior(_ behavior: OffsetLayoutBehavior, sizeOffsetForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize? {
        return nil
    }

    func offsetLayoutBehaviorWithOrigin(_ behavior: OffsetLayoutBehavior, originOffsetForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize? {

        guard identifier == NavigationIdentifiers.navItemBrick else {
            return nil
        }

        guard indexOfSelectedBrick == nil else {
            #if os(iOS)
                let height = navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.size.height
            #else
                let height = navigationController!.navigationBar.frame.height
            #endif

            return CGSize(width: 0, height: -height)
        }

        let width = (collectionViewLayout as! BrickFlowLayout).contentSize.width
        let numberOfBrickPerRow = Constants.numberOfBricksPerRow(for: width)

        let mod = indexPath.item / numberOfBrickPerRow

        if mod % 2 == 0 {
            return CGSize.zero
        } else {
            return CGSize(width: Constants.brickOffset, height: 0)
        }
    }

}

// MARK: - HideBehavior
extension NavigationMasterViewController: HideBehaviorDataSource {

    func hideBehaviorDataSource(shouldHideItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {

        switch identifier {
        case NavigationIdentifiers.navItemBrick:
            if let selectedIndex = indexOfSelectedBrick {
                return selectedIndex != indexPath.item
            } else {
                return false
            }
        default: return false
        }

    }

}
