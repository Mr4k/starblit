//
//  GameScene.swift
//  Starblit
//
//  Created by Peter Stefek on 10/8/16.
//  Copyright (c) 2016 Peter Stefek. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        /*let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        
        self.addChild(myLabel)*/
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
