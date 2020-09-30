//
//  LeaderBoardTableViewCell.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 7/22/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import UIKit

class LeaderBoardTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCell(name: String, score: String) {
        nameLabel.text = name
        scoreLabel.text = score
        
    }
    
}
