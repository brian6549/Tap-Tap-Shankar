//
//  PlayerTableViewCell.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 7/12/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var playerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        playerLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //once the player gets ready "(ready) will be appended"
    func setLabel(name: String) {
        playerLabel.text = name
    }
    
}
