//
//  leaderboardViewController.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 7/17/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import UIKit


//this view controller can just be a table view that gets the scores from the database.

//this is where the upload button should be. The player name and playerID get saved on device so no messing around in the game screen.

///where the player sees the leaderboard
class LeaderBoardViewController: UIViewController {
    
    //needs a table view
    
    //players will get the option to upload their scores to the leaderboard
    
    //players get a notification if someone overtakes them on the leaderboard
    
    //need high scores for both timed and tactical
    
    @IBOutlet weak var tableView: UITableView!
    
    var players = [Player]()
    
    var modalPopUpViewController: ModalPopUpViewController?
    
    var sortedBy: GameType = .tactical //default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        modalPopUpViewController = storyboard?.instantiateViewController(identifier: "modalPopUp") as? ModalPopUpViewController
        
        modalPopUpViewController?.modalPresentationStyle = .overCurrentContext
        
        getScores()
        
    }
    
    //get scores from the database
    func getScores() {
        MultiplayerHandler.getScoresFromLeaderBoard { (players) in
            self.players = players.sorted(by: { (player1, player2) -> Bool in
                return self.sortedBy == .tactical ? (player1.tacticalScore! > player2.tacticalScore!) : (player1.timedScore! > player2.timedScore!)
            })
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func segmentedControl(_ sender: Any) {
        
        if let segmentedConrol = sender as? UISegmentedControl {
            
            switch segmentedConrol.selectedSegmentIndex  {
            case 0:
                sortedBy = .tactical
                getScores()
            case 1:
                sortedBy = .timed
                getScores()
            default:
                break
            }
        }
        
    }
    
    
    //show upload screen
    @IBAction func upload(_ sender: Any) {
        
        DispatchQueue.main.async {
            self.present(self.modalPopUpViewController!, animated: true)
        }
        
    }
    
    
    @IBAction func dismissButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}

extension LeaderBoardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderBoardCell") as! LeaderBoardTableViewCell
        
        cell.setCell(name: players[indexPath.row].playerName!, score: sortedBy == .tactical ? "\(players[indexPath.row].tacticalScore ?? 0)" : "\(players[indexPath.row].timedScore ?? 0)")
        
        return cell
        
    }
    
}
