//
//  GameScene.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 6/14/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import SpriteKit
import GameplayKit


//if the player misses a specific number of times then it is game over.

//after five missed touches it's game over. The screen should flash red when you miss a touch.

///difficulty of the game
enum Difficulty {
    case easy,hard,veryHard, doubleHard, extremelyHard
}

///the state of the game

enum GameState {
    ///the game has been set up and is ready to begin
    case ready
    ///the game is being played
    case playing
    ///the game has ended
    case ended
}

///the z positons of the various objects in the game
struct ZPositions {
    
    static let background: CGFloat = 0
    static let gameLabels:CGFloat = 1
    static let characters: CGFloat = 2
    static let endGameHUD: CGFloat = 3
    
}


///the scene that presents the game.
class GameScene: SKScene {
    
    //MARK: - enums
    var gameType: GameType?
    var gameState: GameState?
    var currentDifficulty: Difficulty = .easy
    
    //MARK: - nodes
    var node: Character?
    var node2: Character?
    var duplicateNode: Character?
    var missedtouchIndicator = SKSpriteNode()
    
    //MARK: - timers
    var moveTimer: Timer?
    var countdownTimer: Timer?
    var changeLabelColorTimer: Timer?
    
    //MARK: - labels
    var timerLabel = SKLabelNode()
    var starterLabel = SKLabelNode()
    var scoreLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    
    //MARK: - game stats
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var lives: Int = 6 {
        didSet {
            livesLabel.text = "Lives: \(lives)"
        }
    }
    
    var highScore: Int {
        get {
            return gameType == .tactical ? LocalStorageService.retrieveScore(for: .tactical) : LocalStorageService.retrieveScore(for: .timed) //gets the score from local storage
        }
    }
    
    //MARK:  multiplayer
    var peopleReady:Int?
    var inviteCode: String?
    var playerID: String?
    var gameInformation = GameInformation()
    
    var gameEndedDelegate: SKSceneCleanupDelegate?
    
    override func didMove(to view: SKView) {
        
        ///multiplayer
        if gameInformation.multiplayerType == .multi {
            
            setupGame() //set up the game
            
            MultiplayerHandler.getPlayers(for: inviteCode!) { (gameInformation) in
                self.gameInformation.players = gameInformation?.players
            } //get all the players
            
            MultiplayerHandler.peopleReady(in: inviteCode!) { (peopleReady) in
                self.peopleReady = peopleReady ?? 0
                
                //if everyone is ready then start the game
                
                //everyone is ready
                if peopleReady == self.gameInformation.players?.count && self.gameInformation.players!.count > 1 && self.gameState == .ready {
                    
                    self.changeLabelColorTimer?.invalidate()
                    self.starterLabel.removeAllActions()
                    self.starterLabel.isHidden = true
                    self.startGame() //
                    
                } //everyone lost
                else if peopleReady == self.gameInformation.players?.count && self.gameInformation.players!.count > 1 && self.gameState == .playing {
                    self.changeLabelColorTimer?.invalidate()
                    self.starterLabel.removeAllActions()
                    self.starterLabel.isHidden = true
                    self.gameOver()
                }
                
            }
        } else { //single player
            setupGame()
        }
        
    }
    
    ///sets up the game
    func setupGame() {
        
        zPosition = ZPositions.background
        
        //adding intial character
        
        node?.size = CGSize(width: 150, height: 150)
        node?.position = CGPoint(x: frame.midX, y: frame.midY)
        node?.touched = nil
        node?.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        
        node?.isHidden = true
        
        node?.zPosition = ZPositions.characters
        
        addChild(node!)
        
        //adding missed touch indicator
        missedtouchIndicator.size = frame.size
        missedtouchIndicator.color = .red
        missedtouchIndicator.alpha = 0
        missedtouchIndicator.zPosition = ZPositions.endGameHUD
        addChild(missedtouchIndicator)
        
        //adding labels
        scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        scoreLabel.alpha = 0
        scoreLabel.fontSize = 50
        scoreLabel.zPosition = ZPositions.gameLabels
        addChild(scoreLabel)
        
        livesLabel = SKLabelNode(fontNamed: "Helvetica")
        livesLabel.text = "Score: 0"
        livesLabel.horizontalAlignmentMode = .center
        livesLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        livesLabel.alpha = 0
        livesLabel.fontSize = 50
        livesLabel.fontColor = .systemRed
        livesLabel.zPosition = ZPositions.gameLabels
        addChild(livesLabel)
        
        //tap anywhere to begin game
        gameState = .ready
        
        starterLabel.numberOfLines = .max
        
        starterLabel.zPosition = ZPositions.endGameHUD
        
        starterLabel.text = gameInformation.multiplayerType == .single ? "Tap anywhere to begin! \n\n High Score: \(highScore) " : "Waiting for others \n\n High Score: \(highScore)"
        
        starterLabel.fontName = "Chalkduster"
        
        starterLabel.fontSize = 50
        
        starterLabel.position.x = frame.midX
        starterLabel.position.y = frame.midY
        
        
        addChild(starterLabel)
        
        //cool label effect
        changeLabelColorTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            
            let changeColorAction = SKAction.sequence([SKAction.colorize(with: UIColor.random(), colorBlendFactor: 0.5, duration: 1.0),
                                                       SKAction.wait(forDuration: 0.1),
                                                       SKAction.colorize(with: .white,colorBlendFactor: 0.0, duration: 1)
            ])
            
            self.starterLabel.run(changeColorAction)
            
        }
        
    }
    
    ///start the game
    func startGame() {
        
        gameState = .playing
        
        node?.isHidden = false //node is hidden initially
        
        updateTimer(interval: 1) //easy difficulty
        
        //timer
        if gameType == .timed {
            
            timerLabel.text = "60"
            
            timerLabel.fontName = "Menlo-Bold"
            
            timerLabel.fontSize = 75
            
            timerLabel.fontColor = .systemYellow
            
            timerLabel.horizontalAlignmentMode = .right
            
            timerLabel.position.x = frame.maxX - timerLabel.frame.size.width //(self.view?.frame.width)! - label.frame.width
            timerLabel.position.y =  (self.frame.maxY - timerLabel.frame.size.height * 2)
            
            timerLabel.zPosition = ZPositions.gameLabels
            
            addChild(timerLabel)
            updateGameOverTimer() //update the timer to reflect the addition of the extra node
        }
        
        //testing
        //  currentDifficulty = .veryHard
        //  score = 30
    }
    
    
    
    ///add the second character
    func addCharacter() {
        
        
        //handle the case of a duplicate node
        if node2?.parent != nil {
            
            duplicateNode = node2?.copy() as? Character
            
            duplicateNode?.zPosition = ZPositions.characters
            
            duplicateNode?.size = CGSize(width: 150, height: 150)
            
            duplicateNode?.position = CGPoint(x: frame.midX, y: frame.midY)
            
            duplicateNode?.touched = nil
            
            duplicateNode?.isUserInteractionEnabled = true
            
            addChild(duplicateNode!)
            
            return
        }
        
        //want to add to middle of the screen
        
        node2?.zPosition = ZPositions.characters
        
        node2?.size = CGSize(width: 150, height: 150)
        
        node2?.position = CGPoint(x: frame.midX, y: frame.midY)
        
        node2?.touched = nil
        node2?.isUserInteractionEnabled = true
        
        addChild(node2!)
        
    }
    
    ///changes the characters position to a random spot on the screen.
    @objc func changePosition(_ sender: GameScene) {
        
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.prepare() //vibration
        
        node?.position = CGPoint(x: CGFloat(CGFloat(arc4random_uniform(UInt32(frame.maxX * 2))) - frame.maxX), y: CGFloat(CGFloat(arc4random_uniform(UInt32(frame.maxY * 2))) - frame.maxY))
        
        if currentDifficulty == .doubleHard || currentDifficulty == .extremelyHard {
            
            if duplicateNode != nil {
                duplicateNode?.position = CGPoint(x: CGFloat(CGFloat(arc4random_uniform(UInt32(frame.maxX * 2))) - frame.maxX), y: CGFloat(CGFloat(arc4random_uniform(UInt32(frame.maxY * 2))) - frame.maxY))
            } else {
                node2?.position = CGPoint(x: CGFloat(CGFloat(arc4random_uniform(UInt32(frame.maxX * 2))) - frame.maxX), y: CGFloat(CGFloat(arc4random_uniform(UInt32(frame.maxY * 2))) - frame.maxY))
            }
            
        }
        
        //should check if it has been touched
        if node?.touched == true || (node2?.touched == true || duplicateNode?.touched == true) {
            
            score += 1
            
            scoreLabel.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0), SKAction.fadeOut(withDuration: 1)]))
            
            impactGenerator.impactOccurred()
            //upload the change to the database if the game is multiplayer
            if gameInformation.multiplayerType == .multi {
                MultiplayerHandler.incrementScore(for: playerID!, in: inviteCode!, score: score)
            }
            
            
            //check score to increase difficulty
            if (score > 10 && score < 20) && currentDifficulty == .easy {
                currentDifficulty = .hard
                updateTimer(interval: 0.50)
            } else if (score > 20 && score < 30) && currentDifficulty == .hard {
                currentDifficulty = .veryHard
                updateTimer(interval: 0.40)
            } else if (score > 30 && score < 40) && currentDifficulty == .veryHard {
                currentDifficulty = .doubleHard
                addCharacter()
                updateTimer(interval: 0.40)
            } else if score > 40 && currentDifficulty == .doubleHard {
                currentDifficulty = .extremelyHard
                updateTimer(interval: 0.30)
            }
            
            node?.touched = nil
            
            if duplicateNode != nil {
                duplicateNode?.touched = nil
            } else {
                node2?.touched = nil
            }
            print("score: \(score)")
            
        } else if node?.touched == false && (node2?.touched == false || duplicateNode?.touched == false) {
            
            if gameType != .timed && gameState == .playing { lives -= 1 }
            
            node?.touched = nil
            
            if duplicateNode != nil {
                duplicateNode?.touched = nil
            } else {
                node2?.touched = nil
            }
            
            if gameType != .timed {  livesLabel.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0), SKAction.fadeOut(withDuration: 1)])) }
            
            print("lives: \(lives)")
            
            if lives < 1 {
                
                //handle the multiplayer case here
                
                if gameInformation.multiplayerType == .multi {
                    
                    self.isUserInteractionEnabled = false
                    
                    for child in self.children {
                        child.isUserInteractionEnabled = false
                    }
                    
                    self.starterLabel.numberOfLines = .max
                    
                    self.starterLabel.text = "Waiting for others \n\n Score: \(score)"
                    
                    self.starterLabel.isHidden = false
                    
                    changeLabelColorTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
                        
                        let changeColorAction = SKAction.sequence([SKAction.colorize(with: UIColor.random(), colorBlendFactor: 0.5, duration: 1.0),
                                                                   SKAction.wait(forDuration: 0.1),
                                                                   SKAction.colorize(with: .white,colorBlendFactor: 0.0, duration: 1)
                        ])
                        
                        self.starterLabel.run(changeColorAction)
                        
                    }
                    
                    //check if everyone lost
                    MultiplayerHandler.getReady(lobbyID: inviteCode!)
                } else {
                    gameOver()
                }
                
            }
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //invalidate timer and hide label
        if gameState == .ready && gameInformation.multiplayerType == .single {
            //remove label
            changeLabelColorTimer?.invalidate()
            starterLabel.removeAllActions()
            starterLabel.isHidden = true
            
            //start game
            startGame()
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //missed touch
        
        node?.touched = false
        
        if duplicateNode != nil {
            duplicateNode?.touched = false
        } else {
            node2?.touched = false
        }
        
        
        missedtouchIndicator.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.1), SKAction.fadeOut(withDuration: 0.1)]))
    }
    
    ///timer for the changing of positions
    func updateTimer(interval: TimeInterval) {
        moveTimer?.invalidate()
        moveTimer = Timer.scheduledTimer(timeInterval: interval, target: self , selector: #selector(changePosition(_:)), userInfo: nil, repeats: true)
        
    }
    
    //called when the game mode is timed
    func updateGameOverTimer() {
        
        var timeLeft = 60
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            
            guard timeLeft > 0 else {
                timer.invalidate()
                self.gameOver()
                return
            }
            
            
            timeLeft -= 1
            
            if timeLeft <= 10 {
                self.timerLabel.fontColor = .systemRed
                self.timerLabel.run(SKAction.move(by: CGVector(dx: self.timerLabel.frame.width * 2, dy: 0), duration: 0.5))
                self.timerLabel.position.x = self.frame.maxX - self.timerLabel.frame.size.width
            }
            
            self.timerLabel.text = "\(timeLeft)"
            
        }
        
    }
    
    ///called when lives becomes less than 0 in single player.
    ///In multiplayer the game cannot end until everybody has lost
    func gameOver() {
        
        
        //need to compare scores
        
        var sortedByHighest:[Player]?
        
        if gameInformation.multiplayerType == .multi {
            
            self.isUserInteractionEnabled = true
            sortedByHighest = gameInformation.players?.sorted(by: { (player1, player2) -> Bool in
                return player1.score! > player2.score!
            })
            
            MultiplayerHandler.updateSession(for: inviteCode!, inSession: false) //game is no longer in session, people can join now
        }
        
        moveTimer?.invalidate()
        
        starterLabel.position = CGPoint(x: frame.midX, y: frame.midY + starterLabel.frame.height)
        starterLabel.numberOfLines = .max
        starterLabel.color = .white
        starterLabel.isHidden = false
        starterLabel.text =  gameInformation.multiplayerType == .single ? "Game Over \n\n Score: \(score)" : "Game Over \n Score: \(score) \n \(sortedByHighest?[0].playerName ?? ":)") wins!"
        
        
        //setting up buttons
        if gameInformation.multiplayerType == .single {
            
            let retryButton = SpriteKitButton(defaultButtonImage: "retryButtonRoundedSmall", action: { _ in
                self.restartGame()
            }, index: 0, highlightable: false)
            
            retryButton.zPosition = ZPositions.endGameHUD
            
            retryButton.aspectScale(to: starterLabel.frame.size, width: false, multiplier: 0.8)
            
            //pop up from bottom of the screen
            retryButton.position.y = frame.minY + retryButton.frame.height
            retryButton.position.x = frame.midX
            
            let changeCharacterButton = SpriteKitButton(defaultButtonImage: "changeCharacterButton", action: { _ in
                //need to dismiss this game scene and go back to the character selection
                
                self.removeAllChildren()
                self.removeFromParent()
                self.view?.presentScene(nil)
                self.gameEndedDelegate?.reshowSelectionScreen()
                
                
            }, index: 0, highlightable: false)
            
            
            changeCharacterButton.zPosition = ZPositions.endGameHUD
            
            changeCharacterButton.aspectScale(to: starterLabel.frame.size, width: false, multiplier: 0.8)
            
            changeCharacterButton.position.y = frame.minY + retryButton.frame.height
            changeCharacterButton.position.x = frame.midX
            
            let goHomeButton = SpriteKitButton(defaultButtonImage: "goHomeButton", action: { _ in
                
                self.removeAllChildren()
                self.removeFromParent()
                self.view?.presentScene(nil)
                self.gameEndedDelegate?.goHome()
                
            }, index: 0, highlightable: false)
            
            goHomeButton.zPosition = ZPositions.endGameHUD
            
            goHomeButton.aspectScale(to: starterLabel.frame.size, width: false, multiplier: 0.8)
            
            goHomeButton.position.y = frame.minY + changeCharacterButton.frame.height
            goHomeButton.position.x = frame.midX
            
            
            addChild(retryButton)
            addChild(changeCharacterButton)
            addChild(goHomeButton)
            retryButton.run(SKAction.move(to: CGPoint(x: frame.midX, y: starterLabel.position.y - starterLabel.frame.height), duration: 1))
            changeCharacterButton.run(SKAction.wait(forDuration: 1))
            changeCharacterButton.run(SKAction.move(to: CGPoint(x: frame.midX, y: starterLabel.position.y - (starterLabel.frame.height * 2)), duration: 1))
            goHomeButton.run(SKAction.wait(forDuration: 4))
            goHomeButton.run(SKAction.move(to: CGPoint(x: frame.midX, y: starterLabel.position.y - (starterLabel.frame.height * 3)), duration: 1))
            
            if score > highScore {
                LocalStorageService.saveHighScore(for: gameType!, score: score)
            }
            
        } else {
            
            let goHomeButton = SpriteKitButton(defaultButtonImage: "goHomeButton", action: { _ in
                self.removeAllChildren()
                self.removeFromParent()
                self.view?.presentScene(nil)
                MultiplayerHandler.unready(lobbyID: self.inviteCode!)
                self.gameEndedDelegate?.goHome()
            }, index: 0, highlightable: false) //take them back to the lobby
            
            goHomeButton.zPosition = ZPositions.endGameHUD
            
            goHomeButton.aspectScale(to: starterLabel.frame.size, width: false, multiplier: 0.8)
            
            goHomeButton.position.y = frame.minY
            goHomeButton.position.x = frame.midX
            
            addChild(goHomeButton)
            
            goHomeButton.run(SKAction.move(to: CGPoint(x: frame.midX, y: starterLabel.position.y - starterLabel.frame.height), duration: 1))
            
            if score > highScore {
                LocalStorageService.saveHighScore(for: gameType!, score: score)
            }
            
        }
        
    }
    
    ///restarts game
    func restartGame() {
        
        for child in children.dropFirst() {
            child.removeFromParent()
        }
        
        lives = 6
        score = 0
        
        setupGame()
    }

}
