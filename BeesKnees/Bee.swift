//
//  Bee.swift
//  BeesKnees
//
//  Created by Adrian Corscadden on 2015-03-21.
//  Copyright (c) 2015 Adrian Corscadden. All rights reserved.
//

import SpriteKit

class Bee: SKSpriteNode {
  override convenience init() {
    self.init(imageNamed:"bee1")
    
    xScale = 0.25
    yScale = 0.25
    name = "bee"
    physicsBody = SKPhysicsBody(circleOfRadius: size.height / 2.5)
    physicsBody!.allowsRotation = true
    addFlap()
  }
  
  func setIsDead(){
    removeAllActions()
    texture = SKTexture(imageNamed: "splat")
  }
  
  func setIsAlive(){
    texture = SKTexture(imageNamed: "bee1")
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
    runAction(flap)
  }
  
  override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
