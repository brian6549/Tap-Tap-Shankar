//
//  UIColor Ext.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 7/6/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    ///random color generator
    static func random() -> UIColor {
        return UIColor(
            red:   .random(),
            green: .random(),
            blue:  .random(),
            alpha: 1.0
        )
    }
    
}
