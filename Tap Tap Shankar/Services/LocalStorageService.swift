//
//  LocalStorageService.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 6/26/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import Foundation
import UIKit

///the type of storage being used to store data
enum StorageType {
    case userDefaults
    case fileSystem
}

enum pictureType {
    case jpeg, png
}

///Anything and everything related to local data persistence
class LocalStorageService {
    
    
    //MARK: - character storage
    
    /**
     saves the name of a character to local storage
     
     - parameter name: the name of the character
     */
    static func storeCharacter(name: String) {
        
        //add to the existing array if there is one, else make a new one
        if var characters = UserDefaults.standard.value(forKey: "characterArray") as? [String] {
            characters.append(name)
            UserDefaults.standard.setValue(characters, forKey: "characterArray")
        } else {
            
            UserDefaults.standard.setValue([name], forKey: "characterArray")
        }
        
    }
    
    /**
     retrieves all the saved characters
     
     - returns: an array containing all the character name or nil if there isn't one
     */
    static func retrieveCharacters() -> [String]? {
        
        if let characters = UserDefaults.standard.value(forKey: "characterArray") as? [String] {
            
            return characters
            
        }
        
        return nil
        
    }
    
    
    //MARK: - persistence for photos
    
    ///gets url for home dirrectory
    private static func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                 in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        return documentURL.appendingPathComponent(key + ".png")
    }
    
    
    ///saves image to local storage
    static func store(image: UIImage,
                      forKey key: String,
                      withStorageType storageType: StorageType) {
        
        //convert image to png
        if let imgRepresentation = image.pngData() {
            switch storageType {
            //store in the file system
            case .fileSystem:
                if let filePath = filePath(forKey: key) {
                    do  {
                        try imgRepresentation.write(to: filePath,
                                                    options: .atomic)
                        
                    } catch let err {
                        print("Saving file resulted in error: ", err)
                    }
                }
            //store in userDefaults
            case .userDefaults:
                UserDefaults.standard.set(imgRepresentation,
                                          forKey: key)
            }
        }
    }
    ///deletes image with the given key from local storage
    static func delete(key: String) {
        let fileManager = FileManager.default
        
        if let filePath = self.filePath(forKey: key)
        {
            do {
                try fileManager.removeItem(at: filePath)
            } catch let err {
                print("error deleting item",err)
            }
            
        }
        
    }
    
    ///retrieves image from lcoal storage.
    static func retrieveImage(forKey key: String,
                              inStorageType storageType: StorageType) -> UIImage? {
        switch storageType {
            
        //retrieve from file system
        case .fileSystem:
            if let filePath = self.filePath(forKey: key),
                let fileData = FileManager.default.contents(atPath: filePath.path),
                let image = UIImage(data: fileData) {
                
                return image
            }
        case .userDefaults:
            if let imageData = UserDefaults.standard.object(forKey: key) as? Data,
                let image = UIImage(data: imageData) {
                return image
            }
        }
        
        return nil
    }
    
    ///alternative function to store image in local storage.
    static func storePng(image: UIImage, key: String) -> String? {
        
        let imageData = image.pngData()!
        do {
            let docDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let imageURL = docDir.appendingPathComponent(key)
            try imageData.write(to: imageURL)
            return imageURL.path
            
        }
            
        catch {
            print("error saving image")
            return nil
        }
        
    }
    
    ///alternative function to retrieve image from local storage.
    static func retrieve2(path: String) -> UIImage? {
        
        if let newImage = UIImage(contentsOfFile: path) {
            return newImage
        }
        
        return nil
    }
    
    //MARK: - leaderboard and saving scores
    
    /**
     
     saves highest score to local storage
     
     - parameter gameType: the mode that the score was earned in
     
     - parameter score: the score to store in local storage
     
     */
    static func saveHighScore(for gameType: GameType, score: Int) {
        let defaults = UserDefaults.standard
        switch gameType {
            
        case .tactical:
            defaults.set(score, forKey: "highScore-tactical")
            
        case .timed:
            defaults.set(score, forKey: "highScore-timed")
            
            
        }
        
    }
    
    ///retrieves score from local storage for the given game mode
    static func retrieveScore(for gameType: GameType) -> Int {
        let defaults = UserDefaults.standard
        
       
        switch gameType {
            
        case .tactical:
            if let score = defaults.value(forKey: "highScore-tactical") as? Int {
                return score
            }
            
        case .timed:
            if let score = defaults.value(forKey: "highScore-timed") as? Int {
                return score
            }
            
        }
        
        return 0 //default
        
    }
    
    ///saves the ID associated with this player on the leaderboard to local storage
    static func saveLeaderboardID(_ id: String) {
        let defaults = UserDefaults.standard
        
        defaults.set(id, forKey: "LeaderBoardID")
    }
    
    static func retrieveLeaderboardID() -> String? {
        let defaults = UserDefaults.standard
        
        return defaults.value(forKey: "LeaderBoardID") as? String
    }
    
    //MARK: - notifications and device tokens
    
    ///saves device token for push notifications
    static func saveDeviceToken(token: String) {
        let defaults = UserDefaults.standard
        
        defaults.setValue(token, forKey: "deviceToken")
    }
    
    ///retrieves device token for push notifications
    static func retrieveDeviceToken() -> String? {
        
        let defaults = UserDefaults.standard
        
        return defaults.value(forKey: "deviceToken") as? String
        
    }
    
    //MARK: - local copies
    
    /**
     saves lobby information for the current lobby that the player is in to local storage
     
     - parameter playerID: theID of the player
     
     - parameter lobby: the ID of the lobby
     */
    static func saveLobbyInformation(playerID: String, lobbyID: String) {
        
        let defaults = UserDefaults.standard
        
        defaults.set(["playerID": playerID, "lobbyID": lobbyID], forKey: "lobbyInformation")
        
    }
    
    ///retrieves lobby information as a dictionary with the keys "playerID" and "lobbyID"
    static func retrieveLobbyInformation() -> [String:String]? {
        
        let defaults = UserDefaults.standard
        
        return defaults.value(forKey: "lobbyInformation") as?  [String:String]
        
    }
    
    ///clears lobby information from local storage
    static func clearLobbyInformation() {
        let defaults = UserDefaults.standard
        
        defaults.set(nil, forKey: "lobbyInformation")
    }

}
