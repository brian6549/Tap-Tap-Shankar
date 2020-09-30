//
//  HomeScreenScene.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 7/8/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import SpriteKit

///game mode
enum GameType {
    case tactical, timed
}

//all the other info will have to be on the server somewhere

///multiplayer mode
enum MultiplayerType {
    case single, multi
}

///the scene that presents the initial screen
class HomeScreenScene: SKScene {
    
    var gameInformation = GameInformation()
    
    // MARK: - labels and title card
    
    var modeLabel: SKLabelNode?
    var playerModeLabel: SKLabelNode?
    var titleCard: SKSpriteNode?
    
    //MARK: - buttons
    var tacticalModeButton: SpriteKitButton!
    var timedModeButton:SpriteKitButton!
    var singlePlayerModeButton:SpriteKitButton!
    var multiplayerModeButton:SpriteKitButton!
    var continueButton: SpriteKitButton!
    var leaderBoardButton: SpriteKitButton!
    
    var cleanupDelegate: SKSceneCleanupDelegate?
    
    override func didMove(to view: SKView) {
        
        //initial setup
        children[0].zPosition = ZPositions.background
        
        setupButtons()
        
    }
    
    ///lays out the buttons on the screen
    func setupButtons() {
        
        //MARK: - game modes and title card
        
        let texture = SKTexture(imageNamed: "tap tap shankar title card")
        
        titleCard = SKSpriteNode(texture: texture, color: .clear, size: texture.size())
        
        titleCard?.zPosition = ZPositions.characters
        titleCard?.position.x = frame.midX
        titleCard?.position.y = frame.maxY - (titleCard?.frame.height)!
        
        titleCard?.aspectScale(to: frame.size, width: true, multiplier: 0.7)
        
        addChild(titleCard!)
        
        let shrinkGrowAction = SKAction.sequence([SKAction.resize(toWidth: (titleCard?.frame.width)! / 2, height: (titleCard?.frame.height)! / 2, duration: 1), SKAction.resize(toWidth: (titleCard?.frame.width)!, height: (titleCard?.frame.height)!, duration: 1)])
        
        titleCard?.run(SKAction.repeatForever(shrinkGrowAction))
        
        modeLabel = SKLabelNode()
        
        modeLabel?.text = "Choose a mode:"
        modeLabel?.fontName = "Chalkduster"
        modeLabel?.fontSize = 50
        modeLabel?.zPosition = ZPositions.characters
        modeLabel?.position = CGPoint(x: frame.midX, y: (titleCard?.position.y)! - (titleCard?.frame.height)! /*frame.midY + ((modeLabel?.frame.height)! * 4)*/)
        
        addChild(modeLabel!)
        
        
        tacticalModeButton = SpriteKitButton(defaultButtonImage: "TacticalModeButton", action: { _ in
            
            self.gameInformation.gameType = .tactical
            
            self.timedModeButton.unhighlight()
            
            self.updateContinueButton()
            
        }, index: 0, highlightable: true)
        
        tacticalModeButton.aspectScale(to: (titleCard?.frame.size)!, width: false, multiplier: 0.5)
        
        tacticalModeButton?.position.x = frame.maxX + (tacticalModeButton?.frame.width)!
        tacticalModeButton?.position.y = (modeLabel?.position.y)! - (tacticalModeButton?.frame.height)! // this will change once the title gets added
        
        tacticalModeButton?.zPosition = ZPositions.characters
        
        addChild(tacticalModeButton!)
        
        tacticalModeButton?.run(SKAction.moveTo(x: frame.minX + ((tacticalModeButton?.frame.width)!), duration: 1))
        
        timedModeButton = SpriteKitButton(defaultButtonImage: "TimedModeButton", action: { _ in
            
            self.gameInformation.gameType = .timed
            
            self.tacticalModeButton?.unhighlight()
            
            self.updateContinueButton()
            
        }, index: 0, highlightable: true)
        
        timedModeButton.aspectScale(to: (titleCard?.frame.size)!, width: false, multiplier: 0.5)
        
        timedModeButton.position.x = frame.maxX + (tacticalModeButton?.frame.width)!
        timedModeButton.position.y = (modeLabel?.position.y)! - (tacticalModeButton?.frame.height)! // this will change once the title gets added
        
        timedModeButton.zPosition = ZPositions.characters
        
        addChild(timedModeButton)
        
        timedModeButton.run(SKAction.moveTo(x: frame.midX + ((timedModeButton.frame.size.width) / 2) + 50 , duration: 1))
        
        //MARK: - player modes
        
        playerModeLabel = SKLabelNode()
        
        playerModeLabel?.text = "Choose your journey:"
        
        playerModeLabel?.fontName = "Chalkduster"
        playerModeLabel?.fontSize = 50
        
        playerModeLabel?.zPosition = ZPositions.characters
        playerModeLabel?.position = CGPoint(x: frame.midX, y: (timedModeButton.position.y) - (timedModeButton.frame.height) - 50)
        
        addChild(playerModeLabel!)
        
        singlePlayerModeButton = SpriteKitButton(defaultButtonImage: "SinglePlayerModeButton", action: { _ in
            
            self.gameInformation.multiplayerType = .single
            
            self.multiplayerModeButton.unhighlight()
            
            self.updateContinueButton()
            
        }, index: 0, highlightable: true)
        
        singlePlayerModeButton.aspectScale(to: (titleCard?.frame.size)!, width: false, multiplier: 0.5)
        singlePlayerModeButton.zPosition = ZPositions.characters
        singlePlayerModeButton.position.x = frame.maxX + singlePlayerModeButton.frame.width
        singlePlayerModeButton.position.y = (playerModeLabel?.position.y)! - singlePlayerModeButton.frame.height
        
        
        addChild(singlePlayerModeButton)
        
        singlePlayerModeButton.run(SKAction.moveTo(x: frame.minX + (singlePlayerModeButton.frame.width), duration: 1))
        
        
        multiplayerModeButton =  SpriteKitButton(defaultButtonImage: "MultiplayerModeButton", action: { _ in
            
            self.gameInformation.multiplayerType = .multi
            
            self.singlePlayerModeButton.unhighlight()
            
            self.updateContinueButton()
            
        }, index: 0, highlightable: true)
        
        multiplayerModeButton.aspectScale(to: (titleCard?.frame.size)!, width: false, multiplier: 0.5)
        
        multiplayerModeButton.zPosition = ZPositions.characters
        multiplayerModeButton.position.x = frame.maxX + multiplayerModeButton.frame.width
        multiplayerModeButton.position.y = (playerModeLabel?.position.y)! - multiplayerModeButton.frame.height
        
        addChild(multiplayerModeButton)
        
        multiplayerModeButton.run(SKAction.moveTo(x: frame.midX + (singlePlayerModeButton.frame.size.width / 2) + 50, duration: 1))
        
        //MARK: - continue
        
        continueButton = SpriteKitButton(defaultButtonImage: "ContinueButton", action: { _ in
            
            guard self.continueButton.isHighlighted else {
                self.continueButton.highlight()
                return
            }
            
            //will probably perform a segue
            
            //the sk scene will need to be dismissed
            self.removeAllChildren()
            self.removeFromParent()
            self.view?.presentScene(nil)
            
            self.cleanupDelegate?.goToNextScreen(with: self.gameInformation)
            
            
        }, index: 0, highlightable: true)
        
        continueButton.aspectScale(to: (titleCard?.frame.size)!, width: false, multiplier: 0.5)
        
        continueButton.zPosition = ZPositions.characters
        continueButton.position.x = frame.maxX + continueButton.frame.width
        continueButton.position.y = multiplayerModeButton.position.y - (singlePlayerModeButton.frame.height * 1.5)
        
        addChild(continueButton)
        
        continueButton.run(SKAction.moveTo(x: frame.minX + continueButton.frame.width, duration: 1))
        
        continueButton.highlight()
        
        //this and the continue button have the same y position
        leaderBoardButton = SpriteKitButton(defaultButtonImage: "LeaderBoardButton", action: { _ in
            
            //segue to the leaderboard view controller
            self.removeAllChildren()
            self.removeFromParent()
            self.view?.presentScene(nil)
            
            self.gameInformation.multiplayerType = .none
            
            self.cleanupDelegate?.goToNextScreen(with: self.gameInformation)
            
            
        }, index: 0, highlightable: false)
        
        leaderBoardButton.zPosition = ZPositions.characters
        leaderBoardButton.position.x = continueButton.position.x + leaderBoardButton.frame.width
        
        leaderBoardButton.position.y = multiplayerModeButton.position.y - (singlePlayerModeButton.frame.height * 1.5)
        
        leaderBoardButton.aspectScale(to: (titleCard?.frame.size)!, width: false, multiplier: 0.5)
        
        addChild(leaderBoardButton)
        
        leaderBoardButton.run(SKAction.moveTo(x:  frame.midX + (leaderBoardButton.frame.width/2) + 50, duration: 1))
        
    }
    
    ///updates the continue button based on the state of the other buttons
    func updateContinueButton() {
        
        if (tacticalModeButton.isHighlighted || timedModeButton.isHighlighted) && (singlePlayerModeButton.isHighlighted || multiplayerModeButton.isHighlighted) {
            continueButton.unhighlight()
        }
            
        else {
            continueButton.highlight()
        }
    }
    
}
