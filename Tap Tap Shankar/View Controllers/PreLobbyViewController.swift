//
//  PreLobbyViewController.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 7/12/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import UIKit

///the view controller where a player can join or host a game
class PreLobbyViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var inviteCodeTextField: UITextField!
    
    @IBOutlet weak var joinGameButton: UIButton!
    
    var inviteCode: String?
    
    var playerID: String?
    
    var gameInformation = GameInformation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        joinGameButton.layer.cornerRadius = 10
        
        nameTextField.enablesReturnKeyAutomatically = true
        
        inviteCodeTextField.enablesReturnKeyAutomatically = true
        
        nameTextField.delegate = self
        
        inviteCodeTextField.delegate = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        // Do any additional setup after loading the view.
    }
    
    //have to check/validate the invite code
    


    // MARK: - Navigation

  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        //if the invite code variable is not nil then that means a lobby was created
        
        if let lobbyVC = segue.destination as? LobbyViewController {
            if inviteCode != nil {
                lobbyVC.inviteCode = inviteCode
            }
            lobbyVC.playerID = playerID
            lobbyVC.modalPresentationStyle = .fullScreen
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
      
    }
    
    
    @IBAction func joinGame(_ sender: Any) {
    
        
        //make sure the textfield is not empty
        guard nameTextField.text != nil, nameTextField.text!.count > 0, nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" , inviteCodeTextField.text != nil, inviteCodeTextField.text!.count > 0, inviteCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            
            showAlert(title: "Error", message: "Enter your name and invite code")
            
            return
        }
        
        
        //make sure that the lobby exists
        MultiplayerHandler.checkLobbyExistenceOnce(lobbyID: inviteCodeTextField.text!) { (lobbyExists) in
            
            if lobbyExists {
                self.playerID = MultiplayerHandler.joinLobby(name: self.nameTextField.text!, inviteCode: self.inviteCodeTextField.text!)
                
                self.inviteCode = self.inviteCodeTextField.text!
                
                self.performSegue(withIdentifier: "goToLobby", sender: self)
                
            
            } else {
                
                self.showAlert(title: "Error", message: "Game does not exist or is already in session")
                return
                 
            }
            
        }
        
        //all the stuff for the lobby will be loaded in its viewDidLoad method
    }
    
    ///host a game
    @IBAction func createGame(_ sender: Any) {
    
        guard nameTextField.text != nil, nameTextField.text!.count > 0 else {
            showAlert(title: "Error", message: "Enter your name")
            return
        }
        
        inviteCode =  MultiplayerHandler.createLobby(name: nameTextField.text!, gameType: gameInformation.gameType) //invite code will get passed into the next view controller
        
        performSegue(withIdentifier: "goToLobby", sender: self)
    
    }
    
    
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
