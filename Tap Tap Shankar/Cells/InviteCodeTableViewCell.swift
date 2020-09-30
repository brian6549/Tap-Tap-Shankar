//
//  InviteCodeTableViewCell.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 7/13/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import UIKit

class InviteCodeTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var codeLabel: UILabel!
    
    var showShareSheetDelegate: ShowShareSheetDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    func setLabel(code: String) {
        codeLabel.text = code
    }
    
    @IBAction func shareCodeButton(_ sender: Any) {
        
        //there will always be a code so the text can be safely unwrapped
        
        showShareSheetDelegate?.showShareSheet(with: codeLabel.text!)
        
    }
    
    
}
