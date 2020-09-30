//
//  GameInformation.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 7/10/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import Foundation
import Firebase

///model for the player
struct Player {
    
    var playerID: String?
    var playerName: String?
    var score: Int?
    
    //MARK: - for the leaderboard
    
    var tacticalScore:Int?
    var timedScore:Int?
    var deviceToken: String?
    
    ///initialize with a data snapshot
    init?(snapshot: DataSnapshot) {
        
        if let playerDictionary = snapshot.value as? [String:Any] {
            
            playerID = snapshot.key
            
            self.playerName = playerDictionary["playerName"] as? String
            self.score = playerDictionary["score"] as? Int
            
            //values for the leaderboard
            
            self.tacticalScore = playerDictionary["tacticalScore"] as? Int
            self.timedScore = playerDictionary["timedScore"] as? Int
            self.deviceToken = playerDictionary["deviceToken"] as? String
            
        } else {
            
            return nil
            
        }
        
    }
}

///model for the game information. This is used throughout different parts to set up each game correctly
struct GameInformation {
    
    var multiplayerType: MultiplayerType!
    var gameType: GameType!
    var characters:[Character]?
    var numberOfPlayers: Int {
        get {
            return players?.count ?? 0
        }
    }
    var players: [Player]?
}
