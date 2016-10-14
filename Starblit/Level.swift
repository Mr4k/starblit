//
//  Level.swift
//  Starblit
//
//  Created by Peter Stefek on 10/9/16.
//  Copyright © 2016 Peter Stefek. All rights reserved.
//

import Foundation

class Level{
    var blocks:[[Int]] = []
    var width:Int = 0
    var height:Int = 0
    
    init(width:Int, height:Int) {
        blocks = [[Int]](repeating:[Int](repeating: 0, count: height), count: width)
        self.width = width
        self.height = height
    }
    
    func buildLevel() -> Int{
        let startX = 0
        let startY = 0;
        let endX = 7;
        let endY = 4;
        let maxTries = 100000;
        var tries = maxTries;
        //blocks[8][0] = 1
        //blocks[7][5] = 1
        //return canReach(startX: startX, startY: startY, endX: endX, endY: endY) > -1;
        while canReach(startX: startX, startY: startY, endX: endX, endY: endY) < 14 {
            toggleBlock(x: Int(arc4random_uniform(UInt32(width))), y: Int(arc4random_uniform(UInt32(height))))
            tries = tries - 1;
            if tries < 0{
                return -1
            }
        }
        print("Found Level in n tries")
        print(maxTries - tries)
        print("Length:")
        print(canReach(startX: startX, startY: startY, endX: endX, endY: endY))
        return canReach(startX: startX, startY: startY, endX: endX, endY: endY)
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
                //right
                var xx = state.0;
                var yy = state.1;
                while xx + 1 < width{
                    if blocks[xx + 1][yy] == 1{
                        if blocks[xx][yy] == 0{
                            //states[xx][yy] = state.2
                            queue.append((xx,yy,state.2 + 1))
                        }
                        break
                    }
                    xx += 1
                }
                //left
                xx = state.0
                yy = state.1
                while xx - 1 > 0{
                    if blocks[xx - 1][yy] == 1{
                        if blocks[xx][yy] == 0{
                            //states[xx][yy] = state.2
                            queue.append((xx,yy,state.2 + 1))
                        }
                        break
                    }
                    xx -= 1
                }
                //up
                xx = state.0
                yy = state.1
                while yy - 1 > 0{
                    if blocks[xx][yy - 1] == 1{
                        if blocks[xx][yy] == 0{
                            //states[xx][yy] = state.2
                            queue.append((xx,yy,state.2 + 1))
                        }
                        break
                    }
                    yy -= 1
                }
                //down
                xx = state.0
                yy = state.1
                while yy + 1 < height{
                    //print(xx,yy + 1)
                    if blocks[xx][yy + 1] == 1{
                        if blocks[xx][yy] == 0{
                            //states[xx][yy] = state.2
                            queue.append((xx,yy,state.2 + 1))
                        }
                        break
                    }
                    yy += 1
                }
            }
        }
        return -1
    }
    
}
