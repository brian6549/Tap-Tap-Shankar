//
//  SKNode Ext.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 7/3/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import SpriteKit

extension SKNode {
    
    //miscellaneous stuff from tutorials
    
    func aspectScale(to size: CGSize, width: Bool, multiplier: CGFloat) {
        let scale = width ? (size.width * multiplier) / self.frame.size.width : (size.height * multiplier) / self.frame.size.height
        self.setScale(scale)
    }
    
        func adjustLabelFontSizeToFitRect(labelNode:SKLabelNode, rect:CGRect) {

        // Determine the font scaling factor that should let the label text fit in the given rectangle.
        let scalingFactor = min(rect.width / labelNode.frame.width, rect.height / labelNode.frame.height)

        // Change the fontSize.
        labelNode.fontSize *= scalingFactor

        // Optionally move the SKLabelNode to the center of the rectangle.
      //  labelNode.position = CGPoint(x: rect.midX, y: rect.midY - labelNode.frame.height / 2.0)
    }
    
}
