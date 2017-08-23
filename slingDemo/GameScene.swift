//
//  GameScene.swift
//  slingDemo
//
//  Created by Jackson Utsch on 8/22/17.
//  Copyright © 2017 Jackson Utsch. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let aSling = sling(initPosition: location, strength: 20)
            addChild(aSling)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            for case let child as sling in children {
                child.dragMoved(newLocation: location)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            for case let child as sling in children {
                child.dragEnded(endLocation: location)
            }
        }
    }
}
