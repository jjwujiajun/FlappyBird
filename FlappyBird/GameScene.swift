//
//  GameScene.swift
//  FlappyBird
//
//  Created by Jiajun on 20/2/16.
//  Copyright (c) 2016 Pewteroid. All rights reserved.
//

import SpriteKit

struct PhysicsCat {
    static let Bird: UInt32 = 0x1 << 1
    static let Ground: UInt32 = 0x1 << 2
    static let Pipe: UInt32 = 0x1 << 3
    static let Score: UInt32 = 0x1 << 4
    static let Coin: UInt32 = 0x1 << 5
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ground = SKSpriteNode()
    var bird = SKSpriteNode()
    var pipePair = SKNode()
    
    var moveAndRemovePipeSequence = SKAction()
    
    var gameStarted = false
    var score = 0
    let scoreLabel = SKLabelNode()
    
    var birdDied = false
    var restartBtn = SKSpriteNode()
    
    func restartScene() {
        self.removeAllChildren()
        self.removeAllActions()
        birdDied = false
        gameStarted = false
        score = 0
        createScene()
    }
    
    func createScene() {
        self.physicsWorld.contactDelegate = self
        
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 0.9)
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = "AngryBirds"
        scoreLabel.fontColor = SKColor.blackColor()
        scoreLabel.fontSize = 60
        scoreLabel.zPosition = 4
        self.addChild(scoreLabel)
        
        for i in 0..<2 {
            let bg = SKSpriteNode(imageNamed: "angrybirdBG")
            bg.setScale(self.frame.height / bg.frame.height)
            bg.anchorPoint = CGPointZero
            bg.position = CGPoint(x: bg.size.width * CGFloat(i), y: 0)
            bg.name = "bg"
            
            bg.zPosition = 0
            self.addChild(bg)
        }
        
        ground = SKSpriteNode(imageNamed: "ground")
        ground.setScale(0.5)
        ground.position = CGPoint(x: self.frame.width / 2, y: ground.frame.height / 2)
        
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.categoryBitMask = PhysicsCat.Ground
        ground.physicsBody?.collisionBitMask = PhysicsCat.Bird
        ground.physicsBody?.contactTestBitMask = PhysicsCat.Bird
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.dynamic = false
        
        ground.zPosition = 3
        self.addChild(ground)
        
        bird = SKSpriteNode(imageNamed: "bird")
        bird.setScale(0.350)
        bird.position = CGPoint(x: self.frame.width / 2 - bird.frame.width/3*2, y: self.frame.height / 2)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.frame.height / 2.45)
        bird.physicsBody?.categoryBitMask = PhysicsCat.Bird
        bird.physicsBody?.collisionBitMask = PhysicsCat.Ground | PhysicsCat.Pipe
        bird.physicsBody?.contactTestBitMask = PhysicsCat.Ground | PhysicsCat.Pipe | PhysicsCat.Score | PhysicsCat.Coin
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.dynamic = true
        
        bird.zPosition = 2
        self.addChild(bird)
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        createScene()
    }
    
    func createRestartBtn() {
        restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.setScale(0)
        restartBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBtn.zPosition = 5
        self.addChild(restartBtn)
        
        restartBtn.runAction(SKAction.scaleTo(0.5, duration: 0.5))
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask == PhysicsCat.Score && contact.bodyB.categoryBitMask == PhysicsCat.Bird) ||
           (contact.bodyA.categoryBitMask == PhysicsCat.Bird && contact.bodyB.categoryBitMask == PhysicsCat.Score) {
            score++
            scoreLabel.text = "\(score)"
        }
        
        if (contact.bodyA.categoryBitMask == PhysicsCat.Pipe && contact.bodyB.categoryBitMask == PhysicsCat.Bird) ||
            (contact.bodyA.categoryBitMask == PhysicsCat.Bird && contact.bodyB.categoryBitMask == PhysicsCat.Pipe) {
                
                enumerateChildNodesWithName("pipePair", usingBlock: {
                    (node, error) in
                    
                    node.speed = 0
                    self.removeAllActions()
                })
                
                if !birdDied {
                    birdDied = true
                    createRestartBtn()
                    bird.texture = SKTexture(imageNamed: "bird_shocked")
                    bird.setScale(0.3)
                }
        }
        
        if (contact.bodyA.categoryBitMask == PhysicsCat.Coin && contact.bodyB.categoryBitMask == PhysicsCat.Bird) ||
            (contact.bodyA.categoryBitMask == PhysicsCat.Bird && contact.bodyB.categoryBitMask == PhysicsCat.Coin) {
                score++
                scoreLabel.text = "\(score)"
                
                if contact.bodyA.categoryBitMask == PhysicsCat.Coin {
                    contact.bodyA.node?.removeFromParent()
                } else {
                    contact.bodyB.node?.removeFromParent()
                }
        }
    }
    
    func createPipes() {
        
        pipePair = SKNode() // needed to keep changing references SKNodes. there are multiple  pipePairs existing at the same time.
        pipePair.name = "pipePair"
        
        let topPipe = SKSpriteNode(imageNamed: "pipe")
        let btmPipe = SKSpriteNode(imageNamed: "pipe")
        let scoreNode = SKSpriteNode()
        
        let pipeImageScale:CGFloat = 0.75
        topPipe.setScale(pipeImageScale)
        btmPipe.setScale(pipeImageScale)
        topPipe.zRotation = CGFloat(M_PI)
        
        let pipeGap: CGFloat = 425
        topPipe.position = CGPoint(x: self.frame.width, y: self.frame.height / 2 + pipeGap)
        btmPipe.position = CGPoint(x: self.frame.width, y: self.frame.height / 2 - pipeGap)
        
        topPipe.physicsBody = SKPhysicsBody(rectangleOfSize: topPipe.size)
        topPipe.physicsBody?.categoryBitMask = PhysicsCat.Pipe
        topPipe.physicsBody?.collisionBitMask = PhysicsCat.Bird
        topPipe.physicsBody?.contactTestBitMask = PhysicsCat.Bird
        topPipe.physicsBody?.affectedByGravity = false
        topPipe.physicsBody?.dynamic = false
        
        btmPipe.physicsBody = SKPhysicsBody(rectangleOfSize: btmPipe.size)
        btmPipe.physicsBody?.categoryBitMask = PhysicsCat.Pipe
        btmPipe.physicsBody?.collisionBitMask = PhysicsCat.Bird
        btmPipe.physicsBody?.contactTestBitMask = PhysicsCat.Bird
        btmPipe.physicsBody?.affectedByGravity = false
        btmPipe.physicsBody?.dynamic = false

        scoreNode.size = CGSize(width: 1, height: pipeGap * 2)
        scoreNode.position = CGPoint(x: self.frame.width, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
        scoreNode.physicsBody?.categoryBitMask = PhysicsCat.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCat.Bird
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.dynamic = false
        
        if CGFloat.random(min: 0, max: 1) > 0.7 {
            let coin = SKSpriteNode(imageNamed: "coin")
            coin.setScale(0.5)
            
            var coinPositionX = CGFloat.random(min: 0, max: 250)
            var coinPositionY:CGFloat
            if coinPositionX > btmPipe.size.width / 1.5 {
                coinPositionY = CGFloat.random(min: -225,max: 225)
            } else {
                coinPositionX = 0
                coinPositionY = 0
            }
            coin.position = CGPoint(x: self.frame.width + coinPositionX, y: self.frame.height / 2 + coinPositionY)
            
            coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.height / 2)
            coin.physicsBody?.categoryBitMask = PhysicsCat.Coin
            coin.physicsBody?.collisionBitMask = 0
            coin.physicsBody?.contactTestBitMask = PhysicsCat.Bird
            coin.physicsBody?.affectedByGravity = false
            coin.physicsBody?.dynamic = false
            
            pipePair.addChild(coin)
        }
        
        pipePair.addChild(topPipe)
        pipePair.addChild(btmPipe)
        pipePair.addChild(scoreNode)
        
        pipePair.position.y += CGFloat.random(min: -200, max: 200)
        pipePair.zPosition = 1
        
        pipePair.runAction(moveAndRemovePipeSequence)
        self.addChild(pipePair)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        if gameStarted {
            if !birdDied {
                bird.physicsBody?.velocity = CGVectorMake(0, 0)
                bird.physicsBody?.applyImpulse(CGVectorMake(0, 190))
                compressBird()
            }
        } else {
            
            gameStarted = true
            bird.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.runBlock({
                self.createPipes()
            })
            let delay = SKAction.waitForDuration(3.25)
            let spawnPipeAndWaitSequence = SKAction.sequence([spawn, delay])
            let repeatedlySpawnPipeSequence = SKAction.repeatActionForever(spawnPipeAndWaitSequence)
            
            self.runAction(repeatedlySpawnPipeSequence)
            
            let distance = CGFloat(self.frame.width + pipePair.frame.width)
            let movePipes = SKAction.moveByX(-distance, y: 0, duration: NSTimeInterval(0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemovePipeSequence = SKAction.sequence([movePipes, removePipes])
            
            
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 200))
        }
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if birdDied {
                if restartBtn.containsPoint(location) {
                    restartScene()
                }
            }
        }
    }
    
    func compressBird() {
      //  bird.position = CGPoint(x: bird.position.x, y: bird.position.y - bird.size.height * 0.1 / 2)
      //  bird.size = CGSize(width: bird.size.width, height: bird.size.height * 0.9)
        let compressionAction = SKAction.scaleYTo(0.350 * 0.775, duration:  0.175 / 2)
        let expansionAction = SKAction.scaleYTo(0.350, duration: 0.175 / 2)
        let compressionSequence = SKAction.sequence([compressionAction, expansionAction])
        bird.runAction(compressionSequence)
      //  bird.position = CGPoint(x: bird.position.x, y: bird.position.y + bird.size.height * 0.1 / 2)

//        performSelector(Selector("returnNormalBirdState"), withObject: nil, afterDelay: 0.175)
        
    }
//    func returnNormalBirdState() {
//        bird.size = CGSize(width: bird.size.width, height: bird.size.height / 0.9)
//        
//    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if gameStarted {
            bird.physicsBody?.applyAngularImpulse(-0.05 * bird.zRotation)

            if !birdDied {
                enumerateChildNodesWithName("bg", usingBlock: {
                    (node, error) in
                    
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 1.8, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: bg.position.y)
                    }
                })
            }
        }
    }
}
