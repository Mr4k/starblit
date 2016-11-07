//
//  Helpers.swift
//  Starblit
//
//  Created by Peter Stefek on 11/7/16.
//  Copyright © 2016 Peter Stefek. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

func randomCGFloat(min:Double,max:Double) -> CGFloat{
    return CGFloat(Float(arc4random())/Float(UINT32_MAX)) * CGFloat(max-min) + CGFloat(min)
}

//biased random
func randomCGVector() -> CGVector{
    let vec:CGVector = CGVector(dx: randomCGFloat(min: -1, max: 1), dy: randomCGFloat(min: -1, max : 1))
    return vec.normalized()
    
}

func selectCGPointFromRectOutline(origin:CGPoint,width:Double,height:Double, side:Int) -> CGPoint{
    switch side % 4{
    case 2:
        return CGPoint(x:origin.x+CGFloat(width), y:origin.y+randomCGFloat(min: 0, max: height))
    case 0:
        return CGPoint(x:origin.x, y:origin.y+randomCGFloat(min: 0, max: height))
    case 1:
        return CGPoint(x:origin.x + randomCGFloat(min: 0, max: width), y:origin.y)
    case 3:
        return CGPoint(x:origin.x + randomCGFloat(min: 0, max: width), y:origin.y+CGFloat(height))
    default:
        return CGPoint(x:0,y:0)
    }
}

func randomCGPoint(){
    
}
