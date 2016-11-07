//
//  Dust.swift
//  Starblit
//
//  Created by Peter Stefek on 11/7/16.
//  Copyright © 2016 Peter Stefek. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class Dust : SKNode {
    var size:Double = 0
    var direction:CGVector = CGVector.zero
    var mspeed: CGFloat = CGFloat(0)
    var decayRate:Double = 0
    var kill:Bool = false;
    
    func setup(position:CGPoint, direction:CGVector){
        self.decayRate = min(max(Double(arc4random_uniform(10000))/Double(10000) * 0.1,0.05),0.1)
        self.direction = direction
        self.position = position
        self.size = min(max(Double(arc4random_uniform(10000))/Double(10000) * 0.2,0.05),0.2)
        self.mspeed = CGFloat(arc4random_uniform(10000))/CGFloat(10000) * 0.75
        
        let frontPart:SKSpriteNode = SKSpriteNode(imageNamed: "Circle")
        frontPart.xScale = CGFloat(0.9)
        frontPart.yScale = CGFloat(0.9)
        frontPart.color = .space
        frontPart.zPosition = 11
        frontPart.colorBlendFactor = 1
        
        let backPart:SKSpriteNode = SKSpriteNode(imageNamed: "Circle")
        backPart.xScale = CGFloat(1)
        backPart.yScale = CGFloat(1)
        backPart.color = .white
        backPart.zPosition = 10
        
        addChild(frontPart)
        addChild(backPart)
        self.xScale = CGFloat(size)
        self.yScale = CGFloat(size)
        self.position = position
    }
    
    func update(deltaTime:Double) {
        self.size -= self.decayRate * 0.11
        self.position.x += self.direction.dx * self.mspeed
        self.position.y += self.direction.dy * self.mspeed
        self.xScale = CGFloat(size)
        self.yScale = CGFloat(size)
        if size <= 0 {
            kill = true
        }
    }
}
