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
  let hiveCategory:   UInt32 = 1 << 3
  let spiderCategory: UInt32 = 1 << 4
  
  let flowerCountLabel =  SKLabelNode(text: "Flowers: ")
  var bee =               SKSpriteNode(imageNamed: "bee1")
  var retry =             SKLabelNode(fontNamed: "Chalkduster")
  var hive =              SKSpriteNode(imageNamed: "hive")
  
  var flowers:[SKSpriteNode] = []
  var flowerCount: Int = 0
  var dead = false
  
  override func didMoveToView(view: SKView) {
    addBackground()
    addFlowers()
    addLabels()
    addBee()
    addRetry()
    addHive()
    setPhysicsCategories()
    physicsWorld.contactDelegate = self
  }
  
  func setPhysicsCategories(){
    for aFlower in flowers {
      aFlower.physicsBody!.categoryBitMask = flowerCategory
      aFlower.physicsBody!.contactTestBitMask = beeCategory
    }
    bee.physicsBody!.categoryBitMask = beeCategory
    bee.physicsBody!.contactTestBitMask = flowerCategory | hiveCategory | spiderCategory | bottomCategory
    bee.physicsBody!.collisionBitMask = bottomCategory
    
    hive.physicsBody!.categoryBitMask = hiveCategory
    hive.physicsBody!.contactTestBitMask = beeCategory
    
  }
  
  func addHive(){
    hive.position = CGPoint( x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame)-50)
    hive.xScale = 0.25
    hive.yScale = 0.25
    hive.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(-hive.size.width/2, -hive.size.height/2, hive.size.width, hive.size.height))
    hive.name = "ball"
    addChild(hive)
  }
  
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
    flowerCountLabel.position = CGPoint(x:CGRectGetMidX(self.frame)/2 + 100, y:CGRectGetMaxY(self.frame)-30)
    flowerCountLabel.fontName = "Helvetica"
    flowerCountLabel.fontSize = 20
    addChild(flowerCountLabel)
  }
  
  func addFlowers(){
    var flowerCount = 5;
    for index in 0...flowerCount {
      var flower = SKSpriteNode(imageNamed: "flower")
      flower.name = "flower"
      flower.xScale = 0.25
      flower.yScale = 0.25
      flower.position = CGPointMake(200.0*CGFloat(index), CGFloat(arc4random()%300) + 300.0)
      flower.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(-flower.size.width/2, 0, flower.size.width, (flower.size.height/2)))
      addChild(flower)
      flowers.append(flower)
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
    bee.xScale = 0.25
    bee.yScale = 0.25
    bee.name = "bee"
    bee.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
    bee.physicsBody = SKPhysicsBody(circleOfRadius: bee.size.height / 2.75)
    bee.physicsBody!.allowsRotation = true
    addChild(bee)
    addFlap()
  }
  
  func addFlap(){
    
    var frames:[SKTexture] = []
    let numBees = 8
    for index in 1...numBees {
      var texture = SKTexture(imageNamed: "bee\(index)")
      texture.filteringMode = .Nearest
      frames.append(texture)
    }
    
    for index in stride(from: numBees-1, through: 1, by: -1){
      var texture = SKTexture(imageNamed: "bee\(index)")
      texture.filteringMode = .Nearest
      frames.append(texture)
      frames.append(texture)
      frames.append(texture)
    }
    
    var flap = SKAction.repeatActionForever(SKAction.animateWithTextures(frames, timePerFrame: 0.01))
    bee.runAction(flap)
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
                retry.hidden = true
                hive.position = CGPoint( x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame)-50)
                dead = false
                flowerCount = 0
                flowerCountLabel.text = "Flowers: 0"
                bee.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
                bee.texture = SKTexture(imageNamed: "bee1")
                addFlap()
              }
            }
          }
        }
      }
  }
 
  override func update(currentTime: CFTimeInterval) {
    if !dead {
      for aFlower in flowers {
        var position = aFlower.position
        position.x = position.x - 4
        if position.x < 0 {
          position.x = CGRectGetWidth(self.frame)
        }
        aFlower.position = position
      }
      bee.zRotation = clamp( -1, max: 0.5, value: CGFloat(bee.physicsBody!.velocity.dy * ( bee.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001 )) );
    }
  }
  
  func incrementFlowerCount(){
    flowerCount++
    flowerCountLabel.text = "Flowers: \(flowerCount)"
  }
  
  func gameOver(){
    bee.removeAllActions()
    var texture = SKTexture(imageNamed: "splat")
    bee.texture = texture
    dead = true
    retry.hidden = false
  }
  
  func didBeginContact(contact: SKPhysicsContact) {
    
    println("collision \(contact.bodyA.categoryBitMask), \(contact.bodyB.categoryBitMask)")
    
    if let nameA = contact.bodyA.node?.name {
      if let nameB = contact.bodyB.node?.name {
        if nameA == "flower" && nameB == "ball" {
          incrementFlowerCount()
        }
      }
    }
    
    
    if contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 2 {
      gameOver()
    }
    
  }
  
}
