//
//  SpriteKitBrick.swift
//  Test Game
//
//  Created by Justin Anderson on 10/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation
import SpriteKit

public class SpriteKitBrick: Brick {

    var dataSource: SpriteKitBrickDataSource

    public init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, dataSource: SpriteKitBrickDataSource) {
        self.dataSource = dataSource
        super.init(identifier, width: width, height: height, backgroundColor:backgroundColor, backgroundView:backgroundView)
    }
}

public protocol SpriteKitBrickDataSource {
    func configureSpriteKitBrick(cell: SpriteKitBrickCell)
}

public class SpriteKitBrickCell: BrickCell, Bricklike {
    public typealias BrickType = SpriteKitBrick
    
    @IBOutlet weak public var gameView: SKView!
    
    public override func updateContent() {
        super.updateContent()
        brick.dataSource.configureSpriteKitBrick(self)
    }
    
}
