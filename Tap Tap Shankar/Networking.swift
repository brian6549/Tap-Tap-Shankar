//
//  Networking.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 7/11/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import Foundation
import Firebase

//the multiplayer interface will have to be slightly different because it will include a lobby


//cases for when the app is terminated or when it's in the background will have to be handled
/**
 handles all the logic for the multiplayer and networking
 
 */
class MultiplayerHandler {
    
    //MARK: - lobby creation and deletion logic
    
    /**
     Creates a lobby and places the player in a lobby
     
     - parameter name: the name of the player
     
     - parameter gameType: the game mode that the lobby will be playing
     
     - returns: the invite code for the lobby
     
     
     */
    static func createLobby(name: String, gameType: GameType) -> String? {
        
        //root of database
        let ref = Database.database().reference()
        
        
        //duplicate names are also possible in lobbies
        
        //create a new lobby and get a reference to it
        let lobby = ref.child("Lobbies").childByAutoId().ref
        //add info for the number of players. There is one player initially
        lobby.child("numberOfPlayers").setValue(1)
        //the number of players ready to start is initially 0
        lobby.child("peopleReady").setValue(0)
        //the game is not in session when it is created
        lobby.child("inSession").setValue(false)
        //set the correct game mode
        lobby.child("gameType").setValue(gameType == .tactical ? "tactical" : "timed")
        
        //add player information
        let playerInformation: [String:Any] = ["playerName": name, "score" : 0 ]
        
        let playerID = lobby.child("Players").childByAutoId().key //creating playerID
        
        lobby.child("Players").child(playerID!).setValue(playerInformation) //adding self to lobby
        
        //the invite code will be the lobbyID
        
        //save a local copy of this information
        LocalStorageService.saveLobbyInformation(playerID: playerID!, lobbyID: lobby.key!)
        
        //this is the invite code
        return lobby.key
        
    }
    
    //called when the last person leaves the lobby
    
    /**
     Deletes the specified lobby. Called when the last person leaves this lobby
     
     - Parameter lobbyID: the ID for the lobby that will be deleted
     
     */
    static func deleteLobby(lobbyID: String) {
        Database.database().reference().child("Lobbies").child(lobbyID).setValue(nil)
    }
    
    //MARK: - joining, leaving, and updating lobby information
    
    /**
     Allows player to join the specified lobby
     
     - parameter name: the name of the player
     
     - parameter inviteCode: the invite code of the lobby
     
     - returns: the playerID of the player in this lobby
     
     
     */
    static func joinLobby(name: String, inviteCode: String) -> String? {
        
        //root of the database
        let ref = Database.database().reference().child("Lobbies").child(inviteCode).child("Players").childByAutoId()
        
        //create and set player information
        let playerInformation: [String:Any] = ["playerName": name, "score" : 0 ]
        
        ref.setValue(playerInformation)
        
        //save local copy of this information
        LocalStorageService.saveLobbyInformation(playerID: ref.key!, lobbyID: inviteCode)
        
        return ref.key //playerID
        
    }
    
    /**
     
     removes the player from a specified lobby
     
     - parameter playerID: the player ID for the player in this lobby
     
     - parameter lobbyID: the ID for the lobby
     
     */
    static func leaveLobby(playerID: String, lobbyID: String) {
        Database.database().reference().child("Lobbies").child(lobbyID).child("Players").child(playerID).setValue(nil) //remove player from lobby
        
        LocalStorageService.clearLobbyInformation() //remove local information
    }
    
    /**
     checks if the lobby exists.
     
     - parameter lobbyID: the ID for the lobby
     
     - parameter completion: a closure that contains a boolean that is used to check if the lobby exists
     
     */
    static func checkLobbyExistence(lobbyID: String, completion: @escaping (Bool) -> Void) {
        
        let ref = Database.database().reference().child("Lobbies").child(lobbyID)
        
        ref.observe(.value) { (snapshot) in
            if snapshot.value == nil {
                completion(false) //lobby does not exist
            } else {completion(true)} //lobby exists
        }
    }
    /**
     checks if the lobby exists and checks if a game is already in session. Called when a player is trying to join a game
     
     - parameter lobbyID: the ID for the lobby
     
     - parameter completion: a closure that contains a boolean that is used to check if the lobby exists
     
     */
    static func checkLobbyExistenceOnce(lobbyID: String, completion: @escaping (Bool) -> Void) {
        
        var doesExist: Bool = false //boolean to pass to the closure. Lobby existence is assumed to be false initially because no checks have been made yet
        
        let ref = Database.database().reference().child("Lobbies")
        //also need to check if the game is in session
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let lobbies = snapshot.value as? [String: Any] {
                if let lobby = lobbies[lobbyID] as? [String:Any] {
                    if lobby["inSession"] as? Bool == false {
                        doesExist = true
                    }
                    
                }
            }
            completion(doesExist)
        }
        
    }
    
    
    //MARK: - get lobby information
    
    //the number of players can also be retrieved from the game information
    
    /**
     gets the number of players in the lobby
     
     - parameter lobby: the lobby ID
     
     - parameter completion: closure with the number of players
     */
    static func getNumberOfPlayers(for lobby: String, completion: @escaping (Int?)->Void) {
        
        let ref = Database.database().reference()
        
        ref.child("Lobbies").child(lobby).child("numberOfPlayers").observe(.value) { (snapshot) in
            completion(snapshot.value as? Int)
        }
        
    }
    
    /**
     retrieves the players in the lobby as Player objects inside a GameInformation
     
     - parameter lobby: the lobby ID
     
     - parameter completion: closure with a game information object
     */
    static func getPlayers(for lobby: String , completion: @escaping (GameInformation?) -> Void) {
        //want to send lobby information to the closure
        
        //game information struct will be used
        
        let ref = Database.database().reference()
        
        var gameInformation: GameInformation? = GameInformation()
        
        ref.child("Lobbies").child(lobby).child("Players").observe(.value) { (snapshot) in
            
            //TODO: - need to instantiate player objects and add them to the game information struct
            var players = [Player]()
            
            let snapshots = snapshot.children.allObjects as? [DataSnapshot]
            
            if let snapshots = snapshots {
                for snap in snapshots {
                    let player = Player(snapshot: snap)
                    
                    if let player = player {
                        players.append(player)
                    }
                }
            }
            
            gameInformation?.players = players
            completion(gameInformation)
        }
        
    }
    
    /**
     updates the number of players in the lobby
     
     - parameter lobby: the lobbyID
     
     - parameter players: the number of players in the lobby
     */
    static func updateNumberOfPlayers(for lobby: String, players: Int) {
        Database.database().reference().child("Lobbies").child(lobby).child("numberOfPlayers").setValue(players)
    }
    
    //MARK: - in game logic
    
    //how to check if everyone is ready to go.
    
    //can have a separate child for that
    //every time someone gets ready, the number of people that are ready get incremented
    
    /*
     if people ready == number of players, then continue to the next screen
     they will be able to get unready as well
     once everyone is ready the game goes on, there is no host for this game
     
     for the character selection:
     
     once everybody chooses their character, they cannot go back and will be marked as ready, everyone is ready. Once everyone is ready the game begins
     
     */
    
    //leaderboard logic will be implemented once all the other multiplayer logic is implemented
    
    /**
     increments the number of players that are ready to start playing the game by one
     
     - parameter lobbyID: the ID of the lobby
     */
    static func getReady(lobbyID: String) {
        
        let ref =  Database.database().reference().child("Lobbies").child(lobbyID).child("peopleReady")
        
        //transaction makes more sense in this situation
        ref.runTransactionBlock { (data) -> TransactionResult in
            
            if var peopleReady = (data.value as? Int)  {
                peopleReady += 1
                data.value = peopleReady
                return TransactionResult.success(withValue: data)
            }
            return TransactionResult.success(withValue: data)
        }
        
    }
    
    /**
     decrements the number of players that are ready to start playing the game by one
     
     - parameter lobbyID: the ID of the lobby
     */
    static func unready(lobbyID: String) {
        let ref =  Database.database().reference().child("Lobbies").child(lobbyID).child("peopleReady")
        
        ref.runTransactionBlock { (data) -> TransactionResult in
            
            if var peopleReady = (data.value as? Int)  {
                peopleReady -= 1
                data.value = peopleReady
                return TransactionResult.success(withValue: data)
            }
            return TransactionResult.success(withValue: data)
        }
    }
    
    /**
     retrieves the number of people that are ready to play in the given lobby
     
     - parameter lobby: the ID of the lobby
     
     - parameter completion: closure that contains the number of people that are ready to start the game
     */
    static func peopleReady(in lobby: String ,completion: @escaping (Int?) -> Void) {
        
        let ref = Database.database().reference().child("Lobbies").child(lobby)
        ref.child("peopleReady").observe(.value) { (snapshot) in
            completion(snapshot.value as? Int)
        }
    }
    
    /**
     gets the game mode that the host has chosen to play
     
     - parameter lobby: the ID of the lobby
     
     - parameter completion: closure containing a gameInformation object with the correct game mode
     */
    static func getCorrectGameType(for lobby: String, completion: @escaping (GameType) -> Void) {
        let ref = Database.database().reference().child("Lobbies").child(lobby)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let lobby = snapshot.value as? [String:Any] {
                if let gameType = lobby["gameType"] as? String {
                    completion(gameType == "tactical" ? .tactical : .timed)
                }
            }
        }
        
    }
    
    /**
     sets the status of the game as inSesion(game being played) or not in session(players still in lobby)
     
     - parameter lobby: the ID of the lobby
     
     - parameter inSession: a boolean that is true if the game is in session or false if the game is not in session
     */
    static func updateSession(for lobby: String, inSession: Bool) {
        Database.database().reference().child("Lobbies").child(lobby).child("inSession").setValue(inSession)
    }
    
    //in-game logic
    
    /**
     increments a player's scor
     
     - parameter player: the playerID of the player whose score will be incremented
     
     - parameter lobby: the ID of the lobby that the player is in
     
     - parameter score: the player's current score
     */
    static func incrementScore(for player: String, in lobby: String, score: Int) {
        
        Database.database().reference().child("Lobbies").child(lobby).child("Players").child(player).child("score").setValue(score)
        
    }
    
    //the score can be retrieved from the get players function
    func getScore() {
        
    }
    
    /**
     resets the player's score when the  game is over
     
     - parameter player: the ID of the player whose score is being reset
     
     - parameter lobby: the ID of the lobby that the player is in
     */
    static func resetScore(for player: String, in lobby: String) {
        Database.database().reference().child("Lobbies").child(lobby).child(player).child("score")
    }
    
    //MARK: - leaderboard logic
    
    /**
     uploads the player's saved high scores to the leaderboard and sends a notification to the player that has been surpassed
     
     - parameter player: the player ID of the player
     */
    static func uploadScores(for player: String ) {
        
        let player:[String:Any] = ["playerName": player,"tacticalScore": LocalStorageService.retrieveScore(for: .tactical) ,"timedScore": LocalStorageService.retrieveScore(for: .timed), "deviceToken" : LocalStorageService.retrieveDeviceToken() ?? "n/a"]
        
        let playerID = LocalStorageService.retrieveLeaderboardID()
        
        var ref: DatabaseReference
        
        if let playerID = playerID {
            
            ref = Database.database().reference().child("Leaderboard").child("Players").child(playerID)
        } else {
            ref = Database.database().reference().child("Leaderboard").child("Players").childByAutoId()
            LocalStorageService.saveLeaderboardID(ref.key!)
        }
        
        //need to send a notification to the player that has been surpassed(need to check for both game modes)
        ref.setValue(player)
        
        getScoresFromLeaderBoard { (players) in
            
            let sortedPlayersByTactical = players.sorted(by: { (player1, player2) -> Bool in
                return player1.tacticalScore! > player2.tacticalScore!
            })
            
            let sortedPlayersByTimed = players.sorted(by: { (player1, player2) -> Bool in
                return player1.timedScore! > player2.timedScore!
            })
            
            //need to find by device token
            
            for player in 0..<sortedPlayersByTactical.count {
                //need the number based loop
                if sortedPlayersByTactical[player].playerID == LocalStorageService.retrieveLeaderboardID() {
                    
                    if sortedPlayersByTactical[player - 1].deviceToken != "n/a"  {
                        sendPushNotification(to: sortedPlayersByTactical[player - 1].deviceToken!, name: sortedPlayersByTactical[player - 1].playerName!, gameType: .tactical)
                    }
                    
                }
                
                //now need to do the same for the timed mode
                if sortedPlayersByTimed[player].playerID == LocalStorageService.retrieveLeaderboardID() {
                    //also need to make sure that the player is not the last one on the leaderboard
                    
                    if sortedPlayersByTimed[player - 1].deviceToken != "n/a"  {
                        sendPushNotification(to: sortedPlayersByTimed[player - 1].deviceToken!, name: sortedPlayersByTimed[player - 1].playerName!, gameType: .timed)
                    }
                    
                }
                
            }
            
            
        }
        
    }
    
    /**
     retrieves scores from the leaderboard
     
     - parameter completion: closure that contains the players retrieved from the leaderboard as player pbjects
     */
    static func getScoresFromLeaderBoard(completion: @escaping ([Player]) -> Void) {
        
        let ref = Database.database().reference().child("Leaderboard").child("Players")
        
        var players = [Player]()
        
        //needs to be sorted
        ref.observeSingleEvent(of: .value) { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                
                for snap in snapshots {
                    if let player = Player(snapshot: snap) {
                        players.append(player)
                    }
                    
                }
                
            }
            
            completion(players) // will be sorted outside of the closure
        }
        
        
    }
    
    private static var functions = Functions.functions() //needed to call https function
    
    /**
     sends a push notification to a player that has been surpassed on the leaderboard
     
     - parameter token: the device token of the current player that was surpassed
     
     - parameter name: the name of the current player
     
     - parameter gameType: the game mode that the notification is related to
     
     */
    private static func sendPushNotification(to token: String, name: String, gameType: GameType) {
        
        //data is sent as a json object
        functions.httpsCallable("leaderBoardNotification").call(["token":token, "name": name, "mode": gameType == .tactical ? "tactical": "timed"]) { (result, error) in
            
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                    
                    print(code as Any, message, details as Any)
                    
                }
                
            }
            
        }
    }
}
