//
//  GameViewController.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 6/14/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

//very random todo: a widget that shows the leaderboard?

///the view controller handling the home screen scene
class GameViewController: UIViewController {
    
    var gameInformation = GameInformation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "HomeScreenScene") as? HomeScreenScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.cleanupDelegate = self
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //the multiplayer screen will also get a gameInformation object because the game type still needs to be passed
        
        if let vc = segue.destination as? CharacterSelectionViewController {
            
            vc.gameInformation = gameInformation
            vc.modalPresentationStyle = .fullScreen
            
        } else if let vc = segue.destination as? PreLobbyViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.gameInformation = gameInformation
        } else if let vc = segue.destination as? LeaderBoardViewController {
            vc.modalPresentationStyle = .fullScreen
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


extension GameViewController: SKSceneCleanupDelegate {
    
    func goToNextScreen(with information: GameInformation) {
        gameInformation = information
        
        if information.multiplayerType == .multi {
            performSegue(withIdentifier: "goToMultiplayerScreen", sender: self)
        } else if information.multiplayerType == .single {
            performSegue(withIdentifier: "goToCharacterSelection", sender: self)
        } else {
            performSegue(withIdentifier: "goToLeaderBoard", sender: self)
        }
        
        
    }
    
    func reshowSelectionScreen() {
        
    }
    
    func goHome() {
        
    }
    
    
}
