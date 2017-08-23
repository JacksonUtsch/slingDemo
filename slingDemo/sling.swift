//
//  sling.swift
//  slingDemo
//
//  Created by Jackson Utsch on 8/22/17.
//  Copyright © 2017 Jackson Utsch. All rights reserved.
//

import SpriteKit

public let dev = true

struct identifiers {
    static let sling = "sling"
}

public func distance(a: CGPoint, b: CGPoint) -> CGFloat {
    let xDist = a.x - b.x
    let yDist = a.y - b.y
    return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
}

/// - TODO: scale per device, make limiting rather than linear
public func getForce(startPoint:CGPoint, endPoint:CGPoint) -> CGVector {
    let dist = distance(a:startPoint, b:endPoint)
    var xQuad:CGFloat? = CGFloat((startPoint.x - endPoint.x)/abs(startPoint.x - endPoint.x))
    var yQuad:CGFloat? = CGFloat((startPoint.y - endPoint.y)/abs(startPoint.y - endPoint.y))
    
    // covers over 0 exception
    if xQuad?.isNaN == true { xQuad = 0 }
    if yQuad?.isNaN == true { yQuad = 0 }
    
    let x1 = -xQuad! * abs(endPoint.x - (startPoint.x))
    let y1 = (-yQuad! * abs(endPoint.y - (startPoint.y)))
    let xf = dist * x1 / 10
    let yf = dist * y1 / 10
    return CGVector(dx: xf, dy: yf)
}

class sling:SKShapeNode {

    private var dongle:SKShapeNode!
    private var range = SKShapeNode()
    private var band = SKShapeNode()
    
    private var initPosition:CGPoint!
    private var strength:CGFloat!
    
    private var shot = false
    
    struct prefs {
        static let radius:CGFloat = 25
        static let color:UIColor = UIColor.red
        static let dongleColor:UIColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(initPosition:CGPoint, strength: CGFloat) {
        super.init()
        self.initPosition = initPosition
        self.strength = strength
        
        let strengthToRadius = strength /// - TODO: equate radius rather than directly set to strength
        path = CGPath(ellipseIn: CGRect(origin: CGPoint(x:-strengthToRadius, y:-strengthToRadius), size: CGSize(width: strengthToRadius * 2, height: strengthToRadius * 2)), transform: nil)
        position = initPosition
        physicsBody = SKPhysicsBody(polygonFrom: path!)
        physicsBody?.friction = 1.0
        physicsBody?.isDynamic = false
        
        dongle = SKShapeNode(circleOfRadius: strengthToRadius)
        dongle.fillColor = prefs.dongleColor
        addChild(dongle)
        
        band.strokeColor = UIColor.white
        band.lineWidth = 3
        addChild(band)
        
        range.fillColor = UIColor.white
        addChild(range)
    }
    
    // updates node
    func dragMoved(newLocation:CGPoint) {
        if shot == false {
            let dist = distance(a:newLocation, b:position)
            if dist / strength < strength * 2 {
                dongle.position.x = newLocation.x - position.x
                dongle.position.y = newLocation.y - position.y
                
                range.path = CGPath(ellipseIn: CGRect(origin: CGPoint(x:-(dist / strength)/2, y:-(dist / strength)/2), size: CGSize(width: dist / strength, height: dist / strength)), transform: nil)
                
                let bPath = CGMutablePath()
                bPath.move(to: CGPoint(x: 0, y: 0))
                bPath.addLine(to: CGPoint(x: newLocation.x - position.x, y: newLocation.y - position.y))
                band.path = bPath
            }
        }
    }
    
    func dragEnded(endLocation:CGPoint) {
        if shot == false {
            band.removeFromParent()
            dongle.removeFromParent()
            physicsBody?.isDynamic = true
            
            let forceVector = getForce(startPoint:endLocation, endPoint:position)
            physicsBody?.applyForce(forceVector)
            if dev == true { print("force applied(dx:\(Int(forceVector.dx.rounded())), dy:\(Int(forceVector.dy.rounded())))") } // rounded values
            shot = true
        }
    }
}
