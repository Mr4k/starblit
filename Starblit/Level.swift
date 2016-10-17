//
//  Level.swift
//  Starblit
//
//  Created by Peter Stefek on 10/9/16.
//  Copyright © 2016 Peter Stefek. All rights reserved.
//

import Foundation

/**
*This class is responsible for holding and generating levels
**/

class Level{
    //change to data structure
    //a block is a number
    //the first bit represents background color
    //the second bit represents whether or not it is the finish
    var blocks:[[Int]] = []
    var width:Int = 0
    var height:Int = 0
    var startPos:(x:Int,y:Int,invert:Int) = (0,0,0)
    var endPos:(x:Int,y:Int,invert:Int) = (8,8,0)
    
    init(width:Int, height:Int) {
        blocks = [[Int]](repeating:[Int](repeating: 0, count: height), count: width)
        self.width = width
        self.height = height
    }
    
    func clear(){
        blocks = [[Int]](repeating:[Int](repeating: 0, count: height), count: width)
    }
    
    func buildLevel() -> Int{
        //these values are for testing right now and will be parameterized later
        //this is the most basic generation strategy
        let maxTries = 10000;
        var tries = maxTries;
        //make the end the end
        blocks[endPos.x][endPos.y] ^= (1 << 1)
        var dist = canReach(startX: startPos.x, startY: startPos.y, endX: endPos.x, endY: endPos.y)
        while dist < 12 {
            let coords:(x:Int,y:Int) = (Int(arc4random_uniform(UInt32(width))),
                                        Int(arc4random_uniform(UInt32(height))))
            //flip the color of the block at coords
            blocks[coords.x][coords.y] ^= 1
            dist = canReach(startX: startPos.x, startY: startPos.y, endX: endPos.x, endY: endPos.y)
            tries = tries - 1;
            if tries < 0{
                return -1
            }
        }
        
        
        //this might be a little ugly
        print("Found in \(maxTries-tries) tries")
        return canReach(startX: startPos.x, startY: startPos.y, endX: endPos.x, endY: endPos.y)
    }
    
    func toggleBlock(x:Int, y:Int){
        
    }
    
    func printLevel(){
        print("Level:")
        for i in 0..<width{
            for j in 0..<height{
                print(blocks[i][j], terminator:"")
            }
            print("")
        }
    }
    
    func getNeighbors(x:Int,y:Int,invert:Int) -> [(x:Int,y:Int,invert:Int)] {
        //get neighboring blocks
        var neighbors:[(x:Int,y:Int,invert:Int)] = [(width,y,invert),(-1,y,invert),(x,-1,invert),(x,height,invert)]
        //right
        var xx = x;
        var yy = y;
        while xx + 1 < width{
            //check if the block next to us is solid
            if blocks[xx + 1][yy] & 1 == 1 - invert{
                //in the special case where we are right next to it we can invert dimensions
                if xx == x{
                    neighbors[0] = (xx+1,yy,1-invert)
                } else {
                    neighbors[0] = (xx,yy,invert)
                }
                break
            } else /*the block next to us is passable*/{
                //if the block is the finish add it
                if blocks[xx+1][yy] & 2 > 0{
                    neighbors[0] = (xx+1, yy, invert)
                    break
                }
            }
            xx += 1
        }
        //left
        xx = x
        yy = y
        while xx - 1 > -1{
            //check if the block next to us is solid
            if blocks[xx - 1][yy] & 1 == 1 - invert{
                //in the special case where we are right next to it we can invert dimensions
                if xx == x{
                    neighbors[1] = (xx-1,yy,1-invert)
                } else {
                    neighbors[1] = (xx,yy,invert)
                }
                break
            } else /*the block next to us is passable*/{
                //if the block is the finish add it
                if blocks[xx-1][yy] & 2 > 0{
                    neighbors[1] = (xx-1, yy, invert)
                    break
                }
            }
            xx -= 1
        }
        //up
        xx = x
        yy = y
        while yy - 1 > -1{
            //check if the block next to us is solid
            if blocks[xx][yy - 1] & 1 == 1 - invert{
                //in the special case where we are right next to it we can invert dimensions
                if yy == y{
                    neighbors[2] = (xx,yy - 1,1-invert)
                } else {
                    neighbors[2] = (xx,yy,invert)
                }
                break
            } else /*the block next to us is passable*/{
                //if the block is the finish add it
                if blocks[xx][yy - 1] & 2 > 0{
                    neighbors[2] = (xx, yy - 1, invert)
                    break
                }
            }
            yy -= 1
        }
        //down
        xx = x
        yy = y
        while yy + 1 < height{
            //check if the block next to us is solid
            if blocks[xx][yy + 1] & 1 == 1 - invert{
                //in the special case where we are right next to it we can invert dimensions
                if yy == y{
                    neighbors[3] = (xx,yy + 1,1-invert)
                } else {
                    neighbors[3] = (xx,yy,invert)
                }
                break
            } else /*the block next to us is passable*/{
                //if the block is the finish add it
                if blocks[xx][yy + 1] & 2 > 0{
                    neighbors[3] = (xx, yy + 1, invert)
                    break
                }
            }
            yy += 1
        }
        return neighbors
    }
    
    func canReach(startX:Int,startY:Int,endX:Int,endY:Int) -> Int{
        //use a breadth first search
        //our state is an 3 tuple
        var states:[[[Int]]] = [[[Int]]](repeating:[[Int]](repeating:[Int](repeating: -1, count: height), count: width), count:2)
        var queue:[(x:Int,y:Int,invert:Int,step:Int)] = []
        queue.append((startX,startY,0,0))
        while queue.count > 0{
            let state = queue.remove(at: 0)
            //print(state)
            if state.0 == endX && state.1 == endY{
                return state.3
            }
            if states[state.2][state.0][state.1] > -1{
                continue
            } else {
                states[state.2][state.0][state.1] = state.3
                //check for neighboring blocks
                let neighbors = getNeighbors(x: state.0, y: state.1, invert: state.invert).filter({$0.x < width && $0.x > -1 && $0.y > -1 && $0.y < height && states[$0.invert][$0.x][$0.y] < 0}).map({($0.x,$0.y,$0.invert,state.3+1)})
                for neighbor in neighbors{
                    queue.append(neighbor)
                }
            }
        }
        return -1
    }
    
}
