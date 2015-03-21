//
//  Flower.swift
//  BeesKnees
//
//  Created by Adrian Corscadden on 2015-03-16.
//  Copyright (c) 2015 Adrian Corscadden. All rights reserved.
//

import SpriteKit

class Flower: SKSpriteNode {
  
  override var position: CGPoint {
    willSet {
      if position.y != newValue.y {
        stem.size = CGSizeMake(10, newValue.y/yScale)
        stem.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(-stem.size.width/2, -stem.size.height/2, stem.size.width, stem.size.height - size.height/2/yScale))
        stem.position = CGPointMake(0, -(stem.size.height/2))
      }
    }
  }
  
  let stem = SKSpriteNode(color: UIColor.orangeColor(), size: CGSizeMake(10, 0))
  var hit = false
  
  override convenience init() {
    self.init(imageNamed:"flower")
    
    xScale = 0.25
    yScale = 0.25
    
    self.name = "flower"
    stem.position = CGPointMake(0,0)
    addChild(stem)
  }
  
  func reset(){
    texture = SKTexture(imageNamed: "flower")
    hit = false
  }
  
  func collide(){
    texture = SKTexture(imageNamed: "flowerPoof")
  }
  
  //Returns the score change after move
  func moveToLeftAndCalculateScoreChange() -> Int {
    let speed:CGFloat = 7.0
    var result = movePositionToLeft(position, speed: speed, newY:true)
    position = result.0
    if result.1 {
      reset()
      if !hit {
        return -10
      } else {
        return 0
      }
    }
    return 0
  }
  
  func randomFlowerHeight() -> CGFloat {
    let bottom = CGRectGetHeight(UIScreen.mainScreen().bounds)*(2/8)
    let top = UInt32(CGRectGetHeight(UIScreen.mainScreen().bounds)*(5/8))
    return (CGFloat(arc4random()%top) + bottom)
  }
  
  func movePositionToLeft( position:CGPoint, speed:CGFloat, newY:Bool ) -> (CGPoint, Bool) {
    var newPosition = position
    var hasReset = false
    newPosition.x = newPosition.x - speed;
    if newPosition.x < 0 {
      newPosition.x = CGRectGetWidth(UIScreen.mainScreen().bounds)
      if newY{
        newPosition.y = randomFlowerHeight()
      }
      hasReset = true
    }
    return (newPosition, hasReset)
  }
  
  // MARK: Unused inits
  override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}
