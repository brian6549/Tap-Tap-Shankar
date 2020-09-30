//
//  Character.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 6/16/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import SpriteKit

///model for the in-game characters
class Character: SKSpriteNode {
    
    ///boolean to determine wether or not a character has been touched while in game
    var touched: Bool? = false
    ///the picture associated with the character
    var characterPicture: UIImage?
    ///boolean to differentiate between default characters and user created characters
    var isDefault:Bool!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //touched
        if let parent = parent {
            if let touch = touches.first {
                let location = touch.location(in: self)
                print(location)
                print(position)
                if parent.contains(location) {
                    touched = true
                    print("touched")
                }
            }
        }
    }
    
    //default character intialization
    init() {
        
        characterPicture = UIImage(named: "Shankar512")
        let texture = SKTexture(imageNamed: "Shankar512")
        
        super.init(texture: texture, color: .clear, size: texture.size())
        
        isDefault = true
    }
    
    ///initialize by name(for default characters)
    init(characterName: String) {
        
        characterPicture = UIImage(named: characterName)
        
        let texture = SKTexture(imageNamed: characterName)
        
        super.init(texture: texture, color: .clear, size: texture.size())
        
        name = characterName
        
        isDefault = true
        
    }
    
    ///initialize with an image and name
    init(with image: UIImage, name: String, isDefault: Bool) {
        
        characterPicture = image
        
        let texture = SKTexture(image: image)
        
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.name = name
        
        self.isDefault = isDefault //mark as default or not default
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
