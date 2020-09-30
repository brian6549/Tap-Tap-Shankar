//
//  LobbyViewController.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 7/12/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import UIKit

protocol ShowShareSheetDelegate {
    func showShareSheet(with content: String)
}

///the lobby for multiplayer
class LobbyViewController: UIViewController {

    
    var inviteCode: String?
    
    var playerID: String?
    
    var peopleReady: Int = 0
    
    var gameInformation = GameInformation()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var readyButton: UIButton!
    //the view here has to be an skview
    
    //the tableView should have a separate section that displays the invite code
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        
        //networking stuff
        
        //the correct game type for will be updated here for all players
        
        //MARK: - make sure all the infomation is correct
        
        MultiplayerHandler.getPlayers(for: inviteCode!) { (gameInformation) in
            
            if let gameInfo = gameInformation {
                
                self.gameInformation.players = gameInfo.players
                MultiplayerHandler.updateNumberOfPlayers(for: self.inviteCode!, players: (gameInformation?.players!.count)!)
                self.tableView.reloadData()
                if self.playerID == nil {
                    self.playerID = gameInformation?.players?[0].playerID
                }
            }
           
        }
        
        MultiplayerHandler.getCorrectGameType(for: inviteCode!) { (type) in
            self.gameInformation.gameType = type
        }
        
        MultiplayerHandler.peopleReady(in: inviteCode!) { (peopleReady) in
            self.peopleReady = peopleReady ?? 0
            
            //if everyone is ready then start the game
            
            if peopleReady == self.gameInformation.players?.count && self.gameInformation.players!.count > 1 {
                //go to character selection screen
                self.performSegue(withIdentifier: "goToCharacterSelection2", sender: self)
            }
        
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        readyButton.setTitle("Ready", for: .normal)
    }
    
    ///ready button
    @IBAction func readyButtonTapped(_ sender: Any) {
    
        if readyButton.title(for: .normal) == "Ready" {
            MultiplayerHandler.getReady(lobbyID: inviteCode!)
            readyButton.setTitle("Unready", for: .normal)
        } else {
            
            MultiplayerHandler.unready(lobbyID: inviteCode!)
            readyButton.setTitle("Ready", for: .normal)
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //pass all the information to the next screen
        
        if let characterSelectionScreen = segue.destination as? CharacterSelectionViewController {
            
            gameInformation.multiplayerType = .multi
            characterSelectionScreen.gameInformation = gameInformation
            characterSelectionScreen.modalPresentationStyle = .fullScreen
            characterSelectionScreen.inviteCode = inviteCode!
            characterSelectionScreen.playerID = playerID
            MultiplayerHandler.updateSession(for: inviteCode!, inSession: true) //TODO: - once the game is in session nobody can join
            MultiplayerHandler.unready(lobbyID: inviteCode!)
        
        }
        
    }
    
  
    @IBAction func leaveButton(_ sender: Any) {
    
        //have to handle the part where the lobby deletes itself once everybody leaves
        
        MultiplayerHandler.leaveLobby(playerID: playerID!, lobbyID: inviteCode!)
        
        self.dismiss(animated: true, completion: {
            if self.gameInformation.numberOfPlayers < 1 {
                MultiplayerHandler.deleteLobby(lobbyID: self.inviteCode!)
            }
        })
        
    }
    
    
}

extension LobbyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "Invite Code"
        default:
            return "Players"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
             case 0:
                 return 1
             default:
                return gameInformation.players?.count ?? 0
             }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell") as! PlayerTableViewCell
            
            cell.setLabel(name: gameInformation.players?[indexPath.row].playerName ?? "no one here yet :(")
            
            return cell
        
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "inviteCodeCell") as! InviteCodeTableViewCell
            
            cell.showShareSheetDelegate = self
            
            cell.setLabel(code: inviteCode!)
            
            return cell
        }
    }
    
}

extension LobbyViewController: ShowShareSheetDelegate {
    
   func showShareSheet(with content: String) {
        
    let activityViewController = UIActivityViewController(activityItems: [content as NSString], applicationActivities: nil)
    
        present(activityViewController, animated: true, completion: nil)
    }
    
}
