//
//  GameScene.swift
//  Starblit
//
//  Created by Peter Stefek on 10/8/16.
//  Copyright (c) 2016 Peter Stefek. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let width = 10
    let height = 12
    let blockImageSize:CGFloat = 184;
    let player = SKSpriteNode(imageNamed:"Block")
    var playerPos:(x:Int,y:Int,z:Int) = (0,0,0)
    var playerInvert = 0
    var shouldInvert = false
    var playerCanMove:Bool = true
    var backgroundSprite:SKSpriteNode = SKSpriteNode(imageNamed:"Block")
    var spinners:[SKSpriteNode] = []
    var spinnersBackgroundBlocks:[SKSpriteNode] = []
    
    let level = Level(width: 10,height: 12)
    var blocks:[SKSpriteNode] = []
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        //For now set up a level here
        print(level.buildLevel())
       initLevel()
        
        //initalize our swipes
        //tinder
        for gestureDirection in [UISwipeGestureRecognizerDirection.right,UISwipeGestureRecognizerDirection.left,UISwipeGestureRecognizerDirection.up,UISwipeGestureRecognizerDirection.down]{
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipe))
            swipe.direction = gestureDirection
            self.view?.addGestureRecognizer(swipe)
        }
        
        
    }
    
    func initLevel(){
        backgroundSprite.xScale = 15
        backgroundSprite.yScale = 15
        backgroundSprite.colorBlendFactor = 1
        backgroundSprite.zPosition = -2
        self.addChild(backgroundSprite)
        backgroundColor = .white
        layoutLevel()
        addPlayer(x: level.startPos.x, y: level.startPos.y)
        playerPos = (level.startPos.x, y: level.startPos.y, 0)
    }
    
    func layoutLevel(){
        for i in 0..<level.width{
            for j in 0..<level.height{
                if level.blocks[i][j] == 1{
                    addBlock(x: i, y: j)
                }
            }
        }
        addGoal(x: level.endPos.x, y: level.endPos.y)
    }
    
    func swipe(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                movePlayer(direction: 0)
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
                movePlayer(direction: 2)
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                movePlayer(direction: 1)
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                movePlayer(direction: 3)
            default:
                break
            }
        }
    }
    
    func scaleToScreen(val:Int)->CGFloat{
        let blockSize = min(size.width / CGFloat(width), size.height / CGFloat(height))
        return CGFloat(val) * blockSize + blockSize/2
    }
    
    func addPlayer(x:Int,y:Int) {
        let blockSize = min(size.width / CGFloat(width), size.height / CGFloat(height))
        player.xScale = blockSize / blockImageSize * 0.8
        player.yScale = blockSize / blockImageSize * 0.8
        player.position = CGPoint(x:scaleToScreen(val: x), y:scaleToScreen(val: y))
        player.color = .red
        player.colorBlendFactor = 1
        self.addChild(player)
    }
    
    func movePlayer(direction:Int){
        if !playerCanMove {return}
        let newPoint = level.getNeighbors(x: playerPos.x, y: playerPos.y, invert:playerPos.z)[direction]
        playerPos = newPoint
        playerCanMove = false
        let cgPoint = CGPoint(x:scaleToScreen(val: newPoint.x),y:scaleToScreen(val: newPoint.y))
        let dist = max(abs(cgPoint.x-player.position.x),abs(cgPoint.y-player.position.y))
        let action = SKAction.move(to: cgPoint, duration: (0.0012 * Double(dist)))
        action.timingMode = .easeIn
        player.run(action, completion: playerFinishedMoving)
    }
    
    func invertWorld(){
        let action = SKAction.colorize(with: [UIColor.black,UIColor.white][playerInvert], colorBlendFactor: 1, duration: 0.1)
        let bkaction = SKAction.colorize(with: [UIColor.black,UIColor.white][1-playerInvert], colorBlendFactor: 1, duration: 0.1)
        for block in blocks{
            block.run(action, completion: invertComplete)
        }
        backgroundSprite.run(bkaction)
    }
    
    func invertComplete(){
        playerCanMove = true
    }
    
    func playerFinishedMoving(){
        playerCanMove = true
        if playerPos.x < 0 || playerPos.x>=width || playerPos.y < 0 || playerPos.y >= height{
            playerPos = level.startPos
            player.position = CGPoint(x:scaleToScreen(val: level.startPos.x),y:scaleToScreen(val: level.startPos.y))
        } else if playerPos == level.endPos{
            level.clear()
            clearBlocks()
            level.buildLevel()
            initLevel()
            playerPos = level.startPos
            player.position = CGPoint(x:scaleToScreen(val: level.startPos.x),y:scaleToScreen(val: level.startPos.y))
        } else if level.blocks[playerPos.x][playerPos.y] == 3{
                playerInvert = 1 - playerInvert
                invertWorld()
                playerCanMove = false
        }
    }
    
    func addGoal(x:Int,y:Int){
        let sprite = SKSpriteNode(imageNamed:"Block")
        let blockSize = min(size.width / CGFloat(width), size.height / CGFloat(height))
        sprite.xScale = blockSize / blockImageSize * 0.8
        sprite.yScale = blockSize / blockImageSize * 0.8
        sprite.position = CGPoint(x:CGFloat(x) * blockSize + blockSize/2, y:CGFloat(y) * blockSize + blockSize/2)
        sprite.color = .cyan
        sprite.colorBlendFactor = 1
        //blocks.append(sprite)
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
        blocks.append(sprite)
        self.addChild(sprite)
    }
    
    func clearBlocks(){
        removeAllChildren()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            /*let location = touch.location(in: self)
            
            let sprite = SKSpriteNode(imageNamed:"Spinner")
            
            sprite.xScale = 0.25
            sprite.yScale = 0.25
            sprite.position = location
            sprite.color = .green
            sprite.colorBlendFactor = 1
            
            let action = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: 1)
            
            sprite.run(SKAction.repeatForever(action))
            
            self.addChild(sprite)*/
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}