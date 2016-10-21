//
//  SpriteKitBrick.swift
//  Test Game
//
//  Created by Justin Anderson on 10/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation
import SceneKit

public class SceneKitBrick: Brick {

    var dataSource: SceneKitBrickDataSource

    public init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, dataSource: SceneKitBrickDataSource) {
        self.dataSource = dataSource
        super.init(identifier, width: width, height: height, backgroundColor:backgroundColor, backgroundView:backgroundView)
    }
}

public protocol SceneKitBrickDataSource {
    func configureSceneKitBrick(cell: SceneKitBrickCell)
}

public class SceneKitBrickCell: BrickCell, Bricklike {
    public typealias BrickType = SceneKitBrick
    
    @IBOutlet weak public var gameView: SCNView!
    
    override public func updateContent() {
        super.updateContent()
        brick.dataSource.configureSceneKitBrick(self)
    }
    
}
