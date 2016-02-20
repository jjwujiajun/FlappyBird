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
}

class GameScene: SKScene {
    
    var ground = SKSpriteNode()
    var bird = SKSpriteNode()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
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
        bird.setScale(0.375)
        bird.position = CGPoint(x: self.frame.width / 2 - bird.frame.width/3*2, y: self.frame.height / 2)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.frame.height / 2.45)
        bird.physicsBody?.categoryBitMask = PhysicsCat.Bird
        bird.physicsBody?.collisionBitMask = PhysicsCat.Ground | PhysicsCat.Pipe
        bird.physicsBody?.contactTestBitMask = PhysicsCat.Ground | PhysicsCat.Pipe
        bird.physicsBody?.affectedByGravity = true
        bird.physicsBody?.dynamic = true
        
        bird.zPosition = 2
        self.addChild(bird)
        
        createPipes()
        
    }
    
    func createPipes() {
        let pipePair = SKNode()
        
        let topPipe = SKSpriteNode(imageNamed: "pipe")
        let btmPipe = SKSpriteNode(imageNamed: "pipe")
        
        let pipeImageScale:CGFloat = 0.5
        topPipe.setScale(pipeImageScale)
        btmPipe.setScale(pipeImageScale)
        topPipe.zRotation = CGFloat(M_PI)
        
        let pipeGap: CGFloat = 300
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
        
        pipePair.addChild(topPipe)
        pipePair.addChild(btmPipe)
        
        pipePair.zPosition = 1
        self.addChild(pipePair)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        bird.physicsBody?.velocity = CGVectorMake(0, 0)
        bird.physicsBody?.applyImpulse(CGVectorMake(0, 200))
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
