//
//  SpriteKitBrickContoller.swift
//  BrickKit-Example
//
//  Created by Justin Anderson on 10/21/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import SpriteKit
import BrickKit

class SpriteKitBrickContoller: BrickViewController {
    
    override class var title: String {
        return "SpriteKit Bricks"
    }
    override class var subTitle: String {
        return "SpriteKit bricks"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.yellowColor()
        
        self.brickCollectionView.registerBrickClass(SpriteKitBrick.self)
        
        var bricks = [Brick]()
        
        bricks.append(SpriteKitBrick("gameBrick", width: .Ratio(ratio: 1), height: .Fixed(size: 350), dataSource: self))
        bricks.append(SpriteKitBrick("gameBrick", width: .Ratio(ratio: 1), height: .Fixed(size: 350), dataSource: self))
        
        self.setSection(BrickSection(bricks: bricks))
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
}

extension SpriteKitBrickContoller: SpriteKitBrickDataSource {
    func configureSpriteKitBrick(cell: SpriteKitBrickCell) {
        //self.gameView = cell.gameView
        
        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = cell.gameView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
    }
}


