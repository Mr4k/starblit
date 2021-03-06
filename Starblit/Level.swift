//
//  Level.swift
//  Starblit
//
//  Created by Peter Stefek on 10/9/16.
//  Copyright © 2016 Peter Stefek. All rights reserved.
//

import Foundation

extension Array
{
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<10
        {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
}

/**
*This class is responsible for holding and generating levels
**/

class Level {
    //change to data structure
    //a block is a number
    //the first bit represents background color
    //the second bit represents whether or not it is the finish
    var blocks:[[Int]] = []
    var width:Int = 0
    var height:Int = 0
    var startPos:(x:Int,y:Int) = (1,0)
    var endPos:(x:Int,y:Int) = (5,4)
    
    init(width:Int, height:Int) {
        blocks = [[Int]](repeating:[Int](repeating: 0, count: height), count: width)
        self.width = width
        self.height = height
    }
    
    init(width:Int, height:Int, start:(x:Int,y:Int), end:(x:Int,y:Int)) {
        blocks = [[Int]](repeating:[Int](repeating: 0, count: height), count: width)
        self.width = width
        self.height = height
        self.startPos = start
        self.endPos = end
    }
    
    func clear(){
        blocks = [[Int]](repeating:[Int](repeating: 0, count: height), count: width)
    }
    
    func buildLevel(start:(x:Int,y:Int),end:(x:Int,y:Int)) -> Float{
        startPos = start
        endPos = end
        return buildLevel()
    }
    
    func buildLevel() -> Float{
        //this is the most basic generation strategy
        let maxTries = 3000;
        var tries = maxTries;
        //make the end the end
        blocks[endPos.x][endPos.y] = 2
        //var path = getPath(startX: startPos.x, startY: startPos.y, endX: endPos.x, endY: endPos.y)
        while buildLevelStep() < 100000 {
            tries = tries - 1;
            if tries < 0{
                break;
            }
        }
        
        
        //this might be a little ugly
        print("Found in \(maxTries-tries) tries")
        postProcess()
        return evalLevel(path: getPath(startX: startPos.x, startY: startPos.y, endX: endPos.x, endY: endPos.y))
    }
    
    func buildLevelStep() -> Float{
        //this is the a basic generation strategy
        //make the end the end
        let equalEvalThres = Float(0.5)
        blocks[endPos.x][endPos.y] = 2
        let path = getPath(startX: startPos.x, startY: startPos.y, endX: endPos.x, endY: endPos.y)
        let coords:(x:Int,y:Int) = (Int(arc4random_uniform(UInt32(width))),
                                    Int(arc4random_uniform(UInt32(height))))
        //flip the color of the block at coords
        blocks[coords.x][coords.y] ^= 1
        blocks[startPos.x][startPos.y] = 0
        blocks[endPos.x][endPos.y] = 2
        let newpath = getPath(startX: startPos.x, startY: startPos.y, endX: endPos.x, endY: endPos.y)
        let oldeval = evalLevel(path: path)
        let neweval = evalLevel(path: newpath)
        if oldeval > neweval{
            blocks[coords.x][coords.y] ^= 1
        } else if abs(oldeval - neweval) < equalEvalThres && arc4random_uniform(10) > 5 {
            blocks[coords.x][coords.y] ^= 1
        }
        blocks[startPos.x][startPos.y] = 0
        blocks[endPos.x][endPos.y] = 2
        
        
        //this might be a little ugly
        return evalLevel(path: getPath(startX: startPos.x, startY: startPos.y, endX: endPos.x, endY: endPos.y))
    }
    
    func postProcessStep(){
        
    }
    
    //heuristic for how interesting a level is
    func evalLevel(path:(path:[(x:Int,y:Int)], branchingFactor:Float)) -> Float{
        var manhattenDistance = 0;
        let stepsToSolve = path.path.count
        if stepsToSolve == 0{
            return -1
        }
        var lastStep = path.path[0]
        for step in path.path{
            manhattenDistance += abs(lastStep.x - step.x) + abs(lastStep.y - step.y)
            lastStep = step;
        }
        let blockCount = blocks.flatMap({$0.map({min($0,1)})}).reduce(0,{$0+$1})
        //print("dist:\(manhattenDistance) steps:\(stepsToSolve) branch:\(path.branchingFactor)")
        /*return (Float(manhattenDistance * 8) + Float(stepsToSolve) * 0.1 + path.branchingFactor)/(Float(blockCount)+0.001)*/
        return Float(manhattenDistance+1)/Float(stepsToSolve) * Float(manhattenDistance + stepsToSolve)
    }
    
    func postProcess(){
        //clean up the unimportant blocks
        let postProcessThreshold = Float(0.8)
        var numSteps = getPath(startX: startPos.x, startY: startPos.y, endX: endPos.x, endY: endPos.y).path.count
        var xmaps:[Int] = [Int]()
        xmaps+=0...(width-1)
        var ymaps:[Int] = [Int]()
        ymaps+=0...(height-1)
        xmaps.shuffle()
        ymaps.shuffle()
        print("about to post process with \(numSteps) steps")
        for i in 0..<width{
            for j in 0..<height{
                let oldval = blocks[xmaps[i]][ymaps[j]]
                blocks[xmaps[i]][ymaps[j]] = 0
                let newVal = getPath(startX: startPos.x, startY: startPos.y, endX: endPos.x, endY: endPos.y).path.count
                if newVal < numSteps{
                    blocks[xmaps[i]][ymaps[j]] = oldval
                } else {
                    numSteps = newVal
                }
            }
        }
        let score = evalLevel(path: getPath(startX: startPos.x, startY: startPos.y, endX: endPos.x, endY: endPos.y))
        print("finished post process with \(numSteps) steps")
        print("finished post process with score: \(score)")
    }
    
    func adjacentBlocks(x:Int,y:Int) -> [Int]{
        var neighbors:[Int] = [0,0,0,0]
        for i in 0...3{
            let coords = radialSearch(i: i, startx: x, starty: y)
            if coords.x == x && coords.y == y{
                continue
            }
            neighbors[i] = blocks[coords.x][coords.y]
        }
        return neighbors
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
            //check if the block next to us is solid
            if blocks[xx + 1][yy] & 1 == 1{
                neighbors[0] = (xx,yy)
                break
            } else /*the block next to us is passable*/{
                //if the block is the finish add it
                if blocks[xx+1][yy] & 2 > 0{
                    neighbors[0] = (xx+1, yy)
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
            if blocks[xx - 1][yy] & 1 == 1{
                neighbors[1] = (xx,yy)
                break
            } else /*the block next to us is passable*/{
                //if the block is the finish add it
                if blocks[xx-1][yy] & 2 > 0{
                    neighbors[1] = (xx-1, yy)
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
            if blocks[xx][yy - 1] & 1 == 1{
                    neighbors[2] = (xx,yy)
                break
            } else /*the block next to us is passable*/{
                //if the block is the finish add it
                if blocks[xx][yy - 1] & 2 > 0{
                    neighbors[2] = (xx, yy - 1)
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
            if blocks[xx][yy + 1] & 1 == 1{
                    neighbors[3] = (xx,yy)
                break
            } else /*the block next to us is passable*/{
                //if the block is the finish add it
                if blocks[xx][yy + 1] & 2 > 0{
                    neighbors[3] = (xx, yy + 1)
                    break
                }
            }
            yy += 1
        }
        return neighbors
    }
    
    /*func getNeighbors(x:Int,y:Int) -> [(x:Int,y:Int)] {
        radialSearch(i: <#T##Int#>, startx: <#T##Int#>, starty: <#T##Int#>)
    }*/
    
    func getPath(startX:Int,startY:Int,endX:Int,endY:Int) -> (path:[(x:Int,y:Int)], branchingFactor:Float){
        //use a breadth first search
        //our state is an 3 tuple
        var states:[[Int]] = [[Int]](repeating:[Int](repeating: -1, count: height), count: width)
        var queue:[(x:Int,y:Int,step:Int)] = []
        queue.append((startX,startY,0))
        var pathLength = -1
        var finishState:(x:Int,y:Int) = (0,0)
        while queue.count > 0{
            let state = queue.remove(at: 0)
            //print(state)
            if state.0 == endX && state.1 == endY{
                finishState = (state.x,state.y)
                pathLength = state.2
                break;
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
        
        var branchingFactor:Float = 0
        for i in 0..<width{
            for j in 0..<height{
                branchingFactor += Float(states[i][j]) + 1
            }
        }
        branchingFactor /= Float(pathLength)
        
        //reconstruct the solution
        var path:[(x:Int,y:Int)] = []
        var step = pathLength
        var currentState = finishState
        while step > 0{
            path.append(currentState)
            var i = 0
            var coords = radialSearch(i: i, startx: currentState.x, starty: currentState.y)
            while states[coords.x][coords.y] != step - 1{
                i += 1
                coords = radialSearch(i: i, startx: currentState.x, starty: currentState.y)
            }
            currentState = (coords.x,coords.y)
            step -= 1;
        }
        return (path,branchingFactor)
    }
    
    func radialSearch(i:Int,startx:Int,starty:Int) -> (x:Int,y:Int) {
        let dist = (i/4 + 1)
        switch i%4{
        case 2:
            return (min(startx + dist,width - 1),starty)
        case 0:
            return (max(startx - dist,0),starty)
        case 1:
            return (startx,max(starty - dist,0))
        case 3:
            return (startx,min(starty + dist,height - 1))
        default:
            return (0,0)
        }
    }
    
}
