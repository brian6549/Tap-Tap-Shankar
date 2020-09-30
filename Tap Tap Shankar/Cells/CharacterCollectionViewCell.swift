//
//  CharacterCollectionViewCell.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 6/25/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import UIKit

class CharacterCollectionViewCell: UICollectionViewCell {
    
    
//the image can just be the characters name
    @IBOutlet weak var characterImage: UIImageView!
    
    
    
    func setImage(image: UIImage) {
        characterImage.image = image
    
    }
    
}
