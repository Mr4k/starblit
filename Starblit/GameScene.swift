//
//  GameScene.swift
//  Starblit
//
//  Created by Peter Stefek on 10/8/16.
//  Copyright (c) 2016 Peter Stefek. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let width = 9
    let height = 12
    let blockImageSize:CGFloat = 184;
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        //For now set up a level here
        backgroundColor = .white
        let level = Level(width: 9,height: 12)
        print(level.buildLevel())
        for i in 0..<level.width{
            for j in 0..<level.height{
                if level.blocks[i][j] > 0{
                    addBlock(x: i, y: j)
                }
            }
        }
        addPlayer(x: 0, y: 0)
        addGoal(x: 7, y: 4)
        
    }
    
    func addPlayer(x:Int,y:Int){
        let sprite = SKSpriteNode(imageNamed:"Block")
        let blockSize = min(size.width / CGFloat(width), size.height / CGFloat(height))
        sprite.xScale = blockSize / blockImageSize
        sprite.yScale = blockSize / blockImageSize
        sprite.position = CGPoint(x:CGFloat(x) * blockSize + blockSize/2, y:CGFloat(y) * blockSize + blockSize/2)
        sprite.color = .red
        sprite.colorBlendFactor = 1
        self.addChild(sprite)
    }
    
    func addGoal(x:Int,y:Int){
        let sprite = SKSpriteNode(imageNamed:"Block")
        let blockSize = min(size.width / CGFloat(width), size.height / CGFloat(height))
        sprite.xScale = blockSize / blockImageSize
        sprite.yScale = blockSize / blockImageSize
        sprite.position = CGPoint(x:CGFloat(x) * blockSize + blockSize/2, y:CGFloat(y) * blockSize + blockSize/2)
        sprite.color = .cyan
        sprite.colorBlendFactor = 1
        self.addChild(sprite)
    }
    
    func addBlock(x:Int,y:Int){
        let sprite = SKSpriteNode(imageNamed:"Block")
        let blockSize = min(size.width / CGFloat(width), size.height / CGFloat(height))
        sprite.xScale = blockSize / blockImageSize
        sprite.yScale = blockSize / blockImageSize
        sprite.position = CGPoint(x:CGFloat(x) * blockSize + blockSize/2, y:CGFloat(y) * blockSize + blockSize/2)
        //sprite.position = CGPoint(x:50,y:50)
        sprite.color = .black
        sprite.colorBlendFactor = 1
        self.addChild(sprite)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.location(in: self)
            
            let sprite = SKSpriteNode(imageNamed:"Spinner")
            
            sprite.xScale = 0.25
            sprite.yScale = 0.25
            sprite.position = location
            sprite.color = .green
            sprite.colorBlendFactor = 1
            
            let action = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: 1)
            
            sprite.run(SKAction.repeatForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
