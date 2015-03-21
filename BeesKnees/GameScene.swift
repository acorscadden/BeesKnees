
//
//  GameScene.swift
//  BeesKnees
//
//  Created by Adrian Corscadden on 2015-01-28.
//  Copyright (c) 2015 Adrian Corscadden. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

  let bottomCategory: UInt32 = 1
  let beeCategory:    UInt32 = 1 << 1
  let flowerCategory: UInt32 = 1 << 2
  let stemCategory:   UInt32 = 1 << 3
  
  let kHighScoreKey = "HighScoreKey"
  
  let scoreLabel =      SKLabelNode(text: "Score: ")
  let highScoreLabel =  SKLabelNode(text: "High Score: ")
  var bee =             Bee()
  var retry =           SKLabelNode(fontNamed: "Chalkduster")
  
  var flowers:[Flower] = []
  var stems:[SKSpriteNode] = []
  var dead = false
  var score: Int = 0 {
    didSet{
      scoreLabel.text = "Score: \(score)"
    }
  }
  
  override func didMoveToView(view: SKView) {
    addBackground()
    addFlowers()
    addLabels()
    addBee()
    addRetry()
    setPhysicsCategories()
    setHighScoreLabel()
    physicsWorld.contactDelegate = self
  }
  
  // MARK: View Adders
  func addBackground(){
    let sky = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(CGRectGetWidth(self.frame)*2, CGRectGetHeight(self.frame)))
    sky.position = CGPointMake(0, CGRectGetHeight(self.frame)/2)
    addChild(sky)
    
    let ground = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(CGRectGetWidth(self.frame)*2, CGRectGetHeight(self.frame)))
    ground.position = CGPointMake(0, 0)
    addChild(ground)
    
    let bottomRect = CGRectMake(0, 0, self.frame.size.width*2, 250/2)
    var bottom = SKSpriteNode(color: UIColor.brownColor(), size: CGSizeMake(CGRectGetWidth(frame)*2, 250))
    bottom.position = CGPoint(x: 0, y: 0)
    bottom.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRect)
    bottom.physicsBody!.categoryBitMask = bottomCategory
    addChild(bottom)
  }
  
  func addLabels(){
    scoreLabel.position = CGPoint(x:50, y:CGRectGetMaxY(self.frame)-30)
    scoreLabel.fontName = "Helvetica"
    scoreLabel.fontSize = 20
    addChild(scoreLabel)
    
    highScoreLabel.position = CGPoint(x: 210, y: scoreLabel.position.y)
    highScoreLabel.fontName = "Helvetica"
    highScoreLabel.fontSize = 20
    addChild(highScoreLabel)
  }
  
  func addFlowers(){
    var flowerCount = 1;
    for index in 0..<flowerCount {
      var flower = Flower()
      flower.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(-flower.size.width/2, -flower.size.height/2, flower.size.width, flower.size.height))
      
      addChild(flower)
      flowers.append(flower)
    }
    
    setFlowerStartingPositions()
  }
  
  func setFlowerStartingPositions(){
    for (index, flower) in enumerate(flowers){
      flower.position = CGPointMake(CGRectGetWidth(frame)*(CGFloat(index)+1), flower.randomFlowerHeight())
    }
  }
  
  func clamp (min:CGFloat, max:CGFloat, value: CGFloat) -> CGFloat{
    if( value > max ) {
      return max;
    } else if( value < min ) {
      return min;
    } else {
      return value;
    }
  }
  
  func addBee(){
    bee.position = CGPoint(x:CGRectGetMidX(frame), y:CGRectGetHeight(frame)*(3/4))
    addChild(bee)
  }
  
  func addRetry(){
    retry.text = "Retry"
    retry.fontColor = SKColor.orangeColor()
    retry.fontSize = 70
    retry.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
    retry.name = "retry";
    retry.hidden = true
    addChild(retry)
  }
  
  
  // MARK: SKScene
  override func update(currentTime: CFTimeInterval) {
    if !dead {
      for flower in flowers {
        score += flower.moveToLeftAndCalculateScoreChange()
      }
      bee.zRotation = clamp( -1, max: 0.5, value: CGFloat(bee.physicsBody!.velocity.dy * ( bee.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001 )) );
    }
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    for touch: AnyObject in touches {
      if !dead {
        bee.physicsBody?.velocity = CGVectorMake(0, 0);
        bee.physicsBody?.applyImpulse(CGVectorMake(0, 80))
      } else {
        
        var touch = touches.anyObject() as AnyObject! as UITouch
        var location = touch.locationInNode(self)
        var node:SKNode? = nodeAtPoint(location)
        
        if let aNode = node{
          if let name = aNode.name {
            if name == "retry"{
              reset()
            }
          }
        }
      }
    }
  }
  
  // MARK: Lifecycle
  func gameOver(){
    if let highScore = NSUserDefaults.standardUserDefaults().integerForKey(kHighScoreKey) as Int? {
      if score > highScore {
        NSUserDefaults.standardUserDefaults().setInteger(score, forKey: kHighScoreKey)
        setHighScoreLabel()
      }
    }
    
    bee.setIsDead()
    dead = true
    retry.hidden = false
  }
  
  func reset(){
    setFlowerStartingPositions()
    for flower in flowers {
      flower.reset()
    }
    retry.hidden = true
    dead = false
    score = 0
    bee.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
    bee.setIsAlive()
  }
  
  // MARK: Physics
  func didBeginContact(contact: SKPhysicsContact) {
    
    var tempFirstBody:SKPhysicsBody?
    var tempSecondBody:SKPhysicsBody?
    
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      tempFirstBody = contact.bodyA
      tempSecondBody = contact.bodyB
    } else {
      tempFirstBody = contact.bodyB
      tempSecondBody = contact.bodyA
    }
    
    if let firstBody = tempFirstBody {
      if let secondBody = tempSecondBody {
        
        if (firstBody.categoryBitMask & bottomCategory) != 0 {
          gameOver()
        }
        
        if (secondBody.categoryBitMask & stemCategory) != 0{
          gameOver()
        }
        
        if (secondBody.categoryBitMask & flowerCategory) != 0 {
          if let flower = secondBody.node as? Flower {
            if !flower.hit {
              flower.collide()
              flower.hit = true
              incrementFlowerCount()
            }
          }
        }
      }
    }
  }
  
  // MARK: Helpers
  func setHighScoreLabel(){
    if let highScore = NSUserDefaults.standardUserDefaults().integerForKey(kHighScoreKey) as Int? {
      highScoreLabel.text = "High Score: \(highScore)"
    }
  }
  
  func incrementFlowerCount(){
    score += 10
  }
  
  func setPhysicsCategories(){
    for aFlower in flowers {
      aFlower.physicsBody!.categoryBitMask = flowerCategory
      aFlower.physicsBody!.contactTestBitMask = beeCategory
      aFlower.stem.physicsBody!.categoryBitMask = stemCategory
      aFlower.stem.physicsBody!.contactTestBitMask = beeCategory
    }
    
    bee.physicsBody!.categoryBitMask = beeCategory
    bee.physicsBody!.contactTestBitMask = flowerCategory | bottomCategory
    bee.physicsBody!.collisionBitMask = bottomCategory | stemCategory
  }
}
