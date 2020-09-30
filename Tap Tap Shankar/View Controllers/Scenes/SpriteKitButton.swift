//
//  SpriteKitButton.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 6/25/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.

//spritekit button class from udemy tutorial

import SpriteKit


class SpriteKitButton: SKSpriteNode {
    
    var defaultButton: SKSpriteNode
    var action: (Int) -> ()
    var index: Int
    var isHighlighted: Bool
    ///determines wether or not the button can be highlighted
    var highlightable: Bool
    
    init(defaultButtonImage: String, action: @escaping (Int) -> (), index: Int, highlightable: Bool) {
        defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        self.action = action
        self.index = index
        isHighlighted = false
        self.highlightable = highlightable
        
        super.init(texture: nil, color: UIColor.clear, size: defaultButton.size)
        
        isUserInteractionEnabled = true
        addChild(defaultButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func highlight() {
        
        if isHighlighted == false {
            
            defaultButton.alpha = 0.75
            isHighlighted = true
        }
        
    }
    
    func unhighlight() {
        
        if isHighlighted == true {
            
            defaultButton.alpha = 1.0
            isHighlighted = false
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isHighlighted == false {
            defaultButton.alpha = 0.75
            isHighlighted = true
        } else {
            defaultButton.alpha = 1.0
            isHighlighted = false
        }
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard !highlightable else {
            return
        }
        
        let touch: UITouch = touches.first! as UITouch
        let location: CGPoint = touch.location(in: self)
        
        if defaultButton.contains(location) {
            defaultButton.alpha =  0.75
        } else {
            defaultButton.alpha = 1.0
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard !highlightable else {
            action(index)
            return
        }
        
        let touch: UITouch = touches.first! as UITouch
        let location: CGPoint = touch.location(in: self)
        
        if defaultButton.contains(location) {
            action(index)
        }
        
        defaultButton.alpha = 1.0
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        defaultButton.alpha = 1.0
    }
    
}
