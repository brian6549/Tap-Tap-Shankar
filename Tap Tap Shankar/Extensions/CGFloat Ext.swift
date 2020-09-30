//
//  CGFloat ext.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 7/6/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    
    ///random float generator
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }

}
