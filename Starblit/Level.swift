//
//  Level.swift
//  Starblit
//
//  Created by Peter Stefek on 10/9/16.
//  Copyright © 2016 Peter Stefek. All rights reserved.
//

import Foundation

/**
*This class is responisble for holding and generating levels
**/

class Level{
    var blocks:[[Int]] = []
    var width:Int = 0
    var height:Int = 0
    var startPos:(x:Int,y:Int) = (0,0)
    var endPos:(x:Int,y:Int) = (8,8)
    
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
        let maxTries = 100000;
        var tries = maxTries;
        while canReach(startX: startPos.x, startY: startPos.y, endX: endPos.x, endY: endPos.y) < 10 {
            toggleBlock(x: Int(arc4random_uniform(UInt32(width))), y: Int(arc4random_uniform(UInt32(height))))
            blocks[endPos.x][endPos.y] = 2
            blocks[startPos.x][startPos.y] = 0
            tries = tries - 1;
            if tries < 0{
                return -1
            }
        }
        //this might be a little ugly
        blocks[startPos.x][startPos.y] = 0
        print("Found in \(maxTries-tries) tries")
        return canReach(startX: startPos.x, startY: startPos.y, endX: endPos.x, endY: endPos.y)
    }
    
    func toggleBlock(x:Int, y:Int){
        blocks[x][y] = 1 - blocks[x][y]
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
    
    func getNeighbors(x:Int,y:Int) -> [(x:Int,y:Int)] {
        //get neighboring blocks
        var neighbors:[(x:Int,y:Int)] = [(width,y),(-1,y),(x,-1),(x,height)]
        //right
        var xx = x;
        var yy = y;
        while xx + 1 < width{
            if blocks[xx + 1][yy] == 1{
                if blocks[xx][yy] == 0{
                    neighbors[0] = (xx,yy)
                }
                break
            } else if blocks[xx + 1][yy] == 2{
                neighbors[0] = (xx + 1,yy)
            }
            xx += 1
        }
        //left
        xx = x
        yy = y
        while xx - 1 > -1{
            if blocks[xx - 1][yy] == 1{
                if blocks[xx][yy] == 0{
                    neighbors[1] = ((xx,yy))
                }
                break
            }
            else if blocks[xx - 1][yy] == 2{
                neighbors[1] = (xx - 1,yy)
                break
            }
            xx -= 1
        }
        //up
        xx = x
        yy = y
        while yy - 1 > -1{
            if blocks[xx][yy - 1] == 1{
                if blocks[xx][yy] == 0{
                    neighbors[2] = ((xx,yy))
                }
                break
            } else if blocks[xx][yy - 1] == 2{
                neighbors[2] = (xx,yy - 1)
                break
            }
            yy -= 1
        }
        //down
        xx = x
        yy = y
        while yy + 1 < height{
            //print(xx,yy + 1)
            if blocks[xx][yy + 1] == 1{
                if blocks[xx][yy] == 0{
                    neighbors[3] = (xx,yy)
                }
                break
            }
            else if blocks[xx][yy + 1] == 2{
                neighbors[3] = (xx,yy + 1)
                break
            }
            yy += 1
        }
        return neighbors
    }
    
    func canReach(startX:Int,startY:Int,endX:Int,endY:Int) -> Int{
        //use a breadth first search
        //our state is an 3 tuple
        var states:[[Int]] = [[Int]](repeating:[Int](repeating: -1, count: height), count: width)
        var queue:[(x:Int,y:Int,step:Int)] = []
        queue.append((startX,startY,0))
        while queue.count > 0{
            let state = queue.remove(at: 0)
            //print(state)
            if state.0 == endX && state.1 == endY{
                return state.2
            }
            if states[state.0][state.1] > -1{
                continue
            } else {
                states[state.0][state.1] = state.2
                //check for neighboring blocks
                let neighbors = getNeighbors(x: state.0, y: state.1).filter({$0.x < width && $0.x > -1 && $0.y > -1 && $0.y < height && states[$0.x][$0.y] < 0}).map({($0.x,$0.y,state.2+1)})
                for neighbor in neighbors{
                    queue.append(neighbor)
                }
            }
        }
        return -1
    }
    
}
