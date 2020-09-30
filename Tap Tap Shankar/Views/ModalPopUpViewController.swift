//
//  ModalPopUpViewController.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 7/22/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import UIKit

///view controller used to upload scores to the leaderboard
class ModalPopUpViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var highScoreLabel: UILabel!
    
    @IBOutlet weak var modalView: UIView!
    
    @IBOutlet weak var dimView: UIView!
    
    @IBOutlet weak var promptLabel: UILabel!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textField.delegate = self
        
         self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        highScoreLabel.adjustsFontSizeToFitWidth = true
        
        promptLabel.adjustsFontSizeToFitWidth = true
        
        dimView.alpha = 0
        
        modalView.layer.cornerRadius = 10
        
        uploadButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        highScoreLabel.text = "High Scores \n\n Tactical: \(LocalStorageService.retrieveScore(for: .tactical)) \n\n Timed: \(LocalStorageService.retrieveScore(for: .timed))"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.20, delay: 0, options: .curveEaseIn, animations: {
            self.dimView.alpha = 1
        }, completion: nil)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseIn, animations: {
            self.dimView.alpha = 0
               }, completion: nil)
    }
    

    @IBAction func uploadScoreButton(_ sender: Any) {
        
        //make sure the textfield is not empty
        guard textField.text != nil, textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "", textField.text!.count > 0 else  {
            return
        }
        
        MultiplayerHandler.uploadScores(for: textField.text!) //upload to database
        
        self.dismiss(animated: true, completion: nil)
        
        if let parentVC = presentingViewController as? LeaderBoardViewController {
            parentVC.getScores()
        }
        
    
    
    }
    
    
    @IBAction func dismissButton(_ sender: Any) {
    
        self.dismiss(animated: true, completion: nil)
        
    }
    
}

extension ModalPopUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    
}
