//
//  GameViewController.swift
//  BeesKnees
//
//  Created by Adrian Corscadden on 2015-01-28.
//  Copyright (c) 2015 Adrian Corscadden. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let scene = GameScene(size: view.bounds.size)
    let skView = view as SKView
    scene.scaleMode = .ResizeFill
    skView.presentScene(scene)
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}
