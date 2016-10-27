//
//  GameScene.swift
//  Starblit
//
//  Created by Peter Stefek on 10/8/16.
//  Copyright (c) 2016 Peter Stefek. All rights reserved.
//

import SpriteKit

extension String {
    var hexColor: UIColor {
        let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return .clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

class GameScene: SKScene {
    
    let width = 12
    let height = 18
    //screen padding
    let padding = 0.1
    var screenWidth:CGFloat = 0
    var screenHeight:CGFloat = 0
    let blockImageSize:CGFloat = 128;
    let player = SKSpriteNode(imageNamed:"White")
    var playerPos:(x:Int,y:Int) = (0,0)
    var playerInvert = 0
    var shouldInvert = false
    var playerCanMove:Bool = true
    var altas = SKTextureAtlas(named: "Sprites")
    var spinners:[SKSpriteNode] = []
    var spinnersBackgroundBlocks:[SKSpriteNode] = []
    
    let level = Level(width: 12,height: 18)
    var stars:[SKSpriteNode] = []
    var timePassed:Double = 0
    var root:SKNode = SKNode()
    var oldRoot = SKNode()
    var stage = SKNode()
    var screenShake:Double = 0
    var exitDirection:Int = 2
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        //For now set up a level here
        screenWidth = size.width * CGFloat(1-padding)
        screenHeight = size.height * CGFloat(1-padding)
        
        print(level.buildLevel(start:selectFromRectOutline(width: width - 1, height: height - 1,side:exitDirection),
                               end:selectFromRectOutline(width: width - 1, height: height - 1, side:0)))
        addStars()
        initLevel()
        stage.addChild(root)
        self.addChild(stage)
        
        //initalize our swipes
        //tinder
        for gestureDirection in [UISwipeGestureRecognizerDirection.right,UISwipeGestureRecognizerDirection.left,UISwipeGestureRecognizerDirection.up,UISwipeGestureRecognizerDirection.down]{
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipe))
            swipe.direction = gestureDirection
            self.view?.addGestureRecognizer(swipe)
        }
        
        
    }
    
    func selectFromRectOutline(width:Int,height:Int, side:Int) -> (x:Int,y:Int){
        switch side%4{
            case 2:
                return (width - 1, Int(arc4random_uniform(UInt32(height))))
            case 0:
                return (0, Int(arc4random_uniform(UInt32(height))))
            case 1:
                return (Int(arc4random_uniform(UInt32(height))), 0)
            case 3:
                return (Int(arc4random_uniform(UInt32(height))), width - 1)
            default:
                return (0,0)
        }
        let xOrY = arc4random_uniform(2) > 0
        if xOrY {
            return (Int(arc4random_uniform(2)) * width,Int(arc4random_uniform(UInt32(height))))
        } else {
            return (Int(arc4random_uniform(UInt32(width))), Int(arc4random_uniform(2)) * height)
        }
    }
    
    func initLevel(){
        //backgroundColor = "#484D6D".hexColor
        backgroundColor = .black
        layoutLevel()
        addPlayer(x: level.startPos.x, y: level.startPos.y)
        playerPos = (level.startPos.x, y: level.startPos.y)
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
    
    func scaleToScreen(x:Int,y:Int) -> CGPoint{
        let blockSize = min(screenWidth / CGFloat(width), screenHeight / CGFloat(height))
        let paddingW = screenWidth - min(screenWidth / CGFloat(width), screenHeight / CGFloat(height)) * CGFloat(width)
        let paddingH = screenHeight - min(screenWidth / CGFloat(width), screenHeight / CGFloat(height)) * CGFloat(width)
        let sx = CGFloat(x) * blockSize + blockSize/2 + paddingW/2 + size.width * CGFloat(padding/2.0)
        return CGPoint(x: sx, y:CGFloat(y) * blockSize + blockSize/2 + paddingH/2)
    }
    
    func addPlayer(x:Int,y:Int) {
        let blockSize = min(screenWidth / CGFloat(width), screenHeight / CGFloat(height))
        player.xScale = blockSize / blockImageSize * 0.8
        player.yScale = blockSize / blockImageSize * 0.8
        player.position = scaleToScreen(x: x, y: y)
        player.color = .red
        player.colorBlendFactor = 1
        root.addChild(player)
    }
    
    func movePlayer(direction:Int){
        if !playerCanMove {return}
        let newPoint = level.getNeighbors(x: playerPos.x, y: playerPos.y)[direction]
        playerPos = newPoint
        playerCanMove = false
        let cgPoint = scaleToScreen(x: newPoint.x, y: newPoint.y)
        let dist = max(abs(cgPoint.x-player.position.x),abs(cgPoint.y-player.position.y))
        let action = SKAction.move(to: cgPoint, duration: (0.0012 * Double(dist)))
        action.timingMode = .easeIn
        player.run(action, completion: {self.playerFinishedMoving(dist:Double(dist))})
    }
    
    
    func playerFinishedMoving(dist:Double){
        playerCanMove = true
        if playerPos.x < 0 || playerPos.x>=width || playerPos.y < 0 || playerPos.y >= height{
            playerPos = level.startPos
            player.position = scaleToScreen(x: level.startPos.x, y: level.startPos.y)
        } else if playerPos == level.endPos{
            let rootTranslations:[CGPoint] = [CGPoint(x:size.width,y:0), CGPoint(x:-size.width,y:0), CGPoint(x:0,y:size.height),CGPoint(x:0,y:-size.height)]
            exitDirection = (exitDirection + 2) % 4
            root.position.x = -rootTranslations[exitDirection].x
            root.position.y = -rootTranslations[exitDirection].y
            level.clear()
            clearBlocks()
            root.position.x = rootTranslations[exitDirection].x
            root.position.y = rootTranslations[exitDirection].y
            level.buildLevel(start:selectFromRectOutline(width: width - 1, height: height - 1, side:exitDirection),
                             end:selectFromRectOutline(width: width - 1, height: height - 1, side:(exitDirection + 2) % 2))
            initLevel()
            playerPos = level.startPos
            player.position = scaleToScreen(x: level.startPos.x, y: level.startPos.y)
        }
        screenShake=min(dist/40.0,7)
    }
    
    func addGoal(x:Int,y:Int){
        let sprite = SKSpriteNode(imageNamed:"White")
        let blockSize = min(screenWidth / CGFloat(width), screenHeight / CGFloat(height))
        sprite.xScale = blockSize / blockImageSize * 0.8
        sprite.yScale = blockSize / blockImageSize * 0.8
        /*sprite.position = CGPoint(x:CGFloat(x) * blockSize + blockSize/2, y:CGFloat(y) * blockSize + blockSize/2)*/
        sprite.position = scaleToScreen(x: x, y: y)
        sprite.color = .cyan
        sprite.colorBlendFactor = 1
        //blocks.append(sprite)
        root.addChild(sprite)
    }
    
    func addBlock(x:Int,y:Int){
        let sprite = SKSpriteNode(texture:SKTexture(imageNamed: "Block"))
        let blockSize = min(screenWidth / CGFloat(width), screenHeight / CGFloat(height))
        sprite.xScale = blockSize / blockImageSize
        sprite.yScale = blockSize / blockImageSize
        sprite.position = scaleToScreen(x: x, y: y)
        //sprite.color = .black
        //sprite.colorBlendFactor = 1
        let neighbors = level.adjacentBlocks(x: x, y: y)
        sprite.zPosition = -2
        root.addChild(sprite)
        for i in 0...3{
            if neighbors[i] > 0 {continue}
            let outline = SKSpriteNode(texture:SKTexture(imageNamed: "Outline"))
            let blockSize = min(screenWidth / CGFloat(width), screenHeight / CGFloat(height))
            outline.xScale = blockSize / blockImageSize
            outline.yScale = blockSize / blockImageSize
            outline.position = scaleToScreen(x: x, y: y)
            outline.zRotation = CGFloat.pi * CGFloat(0.5 * Double(i)) + CGFloat.pi/CGFloat(2)
            outline.zPosition = 1
            root.addChild(outline)
        }
    }
    
    func addStars(){
        for i in 1...30{
            let sprite = SKSpriteNode(texture:SKTexture(imageNamed: "White"))
            let blockSize = min(screenWidth / CGFloat(width), screenHeight / CGFloat(height))
            sprite.xScale = blockSize / blockImageSize * 0.04
            sprite.yScale = blockSize / blockImageSize * 0.04
            sprite.position = CGPoint(x:CGFloat(arc4random_uniform(UInt32(size.width))),y:CGFloat(arc4random_uniform(UInt32(size.height))))
            sprite.color = .white
            sprite.colorBlendFactor = 1
            sprite.zPosition = -3
            self.addChild(sprite)
            stars.append(sprite)
        }
    }
    
    func clearBlocks(){
        oldRoot = root.copy() as! SKNode
        root.removeAllChildren()
        root.addChild(oldRoot)
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if abs(root.position.x) > 0.01{
            root.position.x = root.position.x / CGFloat(1.2)
        } else {
            root.position.x = 0
        }
        if abs(root.position.y) > 0.01{
            root.position.y = root.position.y / CGFloat(1.2)
        } else {
            root.position.y = 0
        }
        screenShake = max(screenShake - 0.5,0)
        stage.position = CGPoint(x:CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * CGFloat(screenShake/2)-CGFloat(screenShake),y:CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * CGFloat(screenShake/2)-CGFloat(screenShake))
        timePassed+=0.01
        for i in 0...(stars.count - 1){
            stars[i].position = CGPoint(x:stars[i].position.x+CGFloat(sin(timePassed + Double(i)) * 10)/CGFloat(i+100),y:stars[i].position.y+CGFloat(cos(timePassed + Double(i)) * 10)/CGFloat(i+100))
        }
    }
}
