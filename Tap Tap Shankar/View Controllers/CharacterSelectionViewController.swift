//
//  CharacterSelectionViewController.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 6/25/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit

//TODO: - it would actually be better to have the add character option as something that pops up in the nav bar

//realistically, the characters should be loaded as soon as the app launches for minimal delay, will try later.

///called after a scene is dismissed to clean up and fix any errors
protocol SKSceneCleanupDelegate {
    
    ///used to reshow the character selection screen.
    func reshowSelectionScreen()
    ///go to the initisl screen
    func goHome()
    ///go to the next view controller
    func goToNextScreen(with information: GameInformation)
}

///the view controller where the player selects a character
class CharacterSelectionViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    
    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    
    var longPressGuestureRecognizer:UILongPressGestureRecognizer?
    
    var characters = [Character]()
    
    var cleanupDelegate: SKSceneCleanupDelegate?
    
    var gameInformation = GameInformation()
    
    var inviteCode: String?
    
    var playerID: String?
    
    //when the game ends everybody gets taken back to the lobby, the getReady system will be used for this
    override func viewDidLoad() {
       
        longPressGuestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        
        longPressGuestureRecognizer?.delegate = self
        
        longPressGuestureRecognizer?.minimumPressDuration = 0.5
        
        longPressGuestureRecognizer?.delaysTouchesBegan = true
        
        collectionView.isUserInteractionEnabled = true
        
        self.collectionView.addGestureRecognizer(longPressGuestureRecognizer!)
        
        let itemSize = UIScreen.main.bounds.width/3 - 3
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
        //default characters
    //    let character1 = Character(characterName: "Shankar512")
        let character2 = Character(characterName: "ShankarPods")
        let character3 = Character(characterName: "ShankarHeart")
     //   let character4 = Character(characterName: "ShankarPodsSupreme")
     //   let character5 = Character(characterName: "ShankarPodsSupremeCap")
        
        
        characters = [character2,character3]
        
        //retrieving image
        DispatchQueue.global(qos: .background).async {
            if let userCharacters = LocalStorageService.retrieveCharacters() {
                for character in userCharacters {
                    if let characterPicture = LocalStorageService.retrieveImage(forKey: character, inStorageType: .fileSystem) {
                        
                        let character = Character(with: characterPicture, name: character, isDefault: false)
                        
                        self.characters.append(character)
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        collectionView.isHidden = false
        navBar.isHidden = false
    }
    
    
    @IBAction func addCharacterButtonTapped(_ sender: Any) {
        
        showActionSheet(barButtonItem)
        
    }
    
    func showCharacterActionSheet(for character: IndexPath, _ sender: AnyObject ) {
        
        //make sure that there is a cell and that the character in that cell is not a default character so that it can be deleted
        guard let cell = collectionView.cellForItem(at: character), !characters[character.row].isDefault else {
            return
        }
        
        let actionsheetForCharacter = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Remove Character", style: .destructive) { _ in
            let characterToDelete = self.characters[character.row]
            LocalStorageService.delete(key: characterToDelete.name!)
            self.characters.remove(at: character.row)
            self.collectionView.reloadData()
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel,handler: nil)
        
        actionsheetForCharacter.addAction(deleteAction)
        actionsheetForCharacter.addAction(dismissAction)
        
        //for ipad
        actionsheetForCharacter.popoverPresentationController?.sourceView = view
        actionsheetForCharacter.popoverPresentationController?.sourceRect = cell.frame
        
        //present action sheet
        present(actionsheetForCharacter, animated: true, completion: nil)
    }
    
    //action sheet for when the profile picture is tapped.
    func showActionSheet(_ sender: AnyObject) {
        
        //create action sheet
        let actionSheet = UIAlertController(title: "Change Character", message: "Select a source", preferredStyle: .actionSheet)
        actionSheet.modalPresentationStyle = .popover
        
        
        //create actions
        
        //camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
                
                self.showImagePicker(type: .camera)
                
            }
            
            actionSheet.addAction(cameraAction)
            
        }
        
        //photo library
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
                
                self.showImagePicker(type: .photoLibrary)
                
            }
            
            actionSheet.addAction(libraryAction)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cancelAction)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        
        //present action sheet
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    func showImagePicker(type: UIImagePickerController.SourceType) {
        //create image picker
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = type
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        //present it
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    @objc func handleLongPress(_ sender: Any) {
        
        if let press = sender as? UILongPressGestureRecognizer {
            if press.state != .ended {
                return
            }
            let pressLocation = press.location(in: collectionView)
            if let indexPath = self.collectionView.indexPathForItem(at: pressLocation) {
                let view = UIView()
                showCharacterActionSheet(for: indexPath, view)
            }
                
            else {
                return
            }
        }
    }
    
    func presentGameScene(with nodes: [Character]) {
        
        if gameInformation.multiplayerType == .multi {
            MultiplayerHandler.getReady(lobbyID: inviteCode!)
        }
        
        if let view = view as! SKView? {
            
            
            self.collectionView.isHidden = true
            self.navBar.isHidden = true
            
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .fill
                
                //    scene.node
                scene.gameType = gameInformation.gameType
                
                scene.gameInformation = gameInformation
                scene.inviteCode = inviteCode
                
                scene.node = nodes[0]
                scene.node2 = nodes[1]
                
                scene.playerID = playerID
                
                scene.gameEndedDelegate = self
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
        }
        
    }
    
    
    @IBAction func dismiss(_ sender: Any) {
        
        //can't use this button while in multplayer
        if gameInformation.multiplayerType == .multi {
            return
        }
        
        cleanupDelegate?.reshowSelectionScreen()
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension CharacterSelectionViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //user canceled, dismiss image picker
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            
            
            //successfully got the image, now save it
            DispatchQueue.global(qos: .background).async {
                
                let key = UUID().uuidString
               
                let newImage = selectedImage.normalizedImage()
                LocalStorageService.store(image: newImage, forKey: key, withStorageType: .fileSystem)
                LocalStorageService.storeCharacter(name: key)
                
                //want to make a new character once the user is done picking an image
                
                let character = Character(with: selectedImage, name: key, isDefault: false)
                
                self.characters.append(character)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            }
            
        }
        
        //dismiss the picker
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}



extension CharacterSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characters.count //need extra cell for the add character option
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath) as! CharacterCollectionViewCell
        
        cell.setImage(image: characters[indexPath.row].characterPicture!)
        
        cell.backgroundColor = UIColor(white: 1.0, alpha: 0)
        
        cell.characterImage.backgroundColor = .clear
        cell.characterImage.isOpaque = true
        cell.characterImage.contentMode = .scaleAspectFit
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //pass the character to the game scene and a random one for the second. Having duplicates is possible.
        presentGameScene(with: [characters[indexPath.row],characters[Int(arc4random_uniform(UInt32(characters.count)))]])
    }

}

extension CharacterSelectionViewController: SKSceneCleanupDelegate {
    
    func goToNextScreen(with information: GameInformation) {
        
    }
    
    
    func goHome() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func reshowSelectionScreen() {
        navBar.isHidden = false
        collectionView.isHidden = false
    }
    
    
}
