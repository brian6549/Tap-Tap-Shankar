//
//  Utils.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 6/15/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import Foundation

///probability function
func randomBool(odds: Int, pivot: Int) -> Bool {
    let random = arc4random_uniform(UInt32(odds))
    if random < pivot {
        return true
    } else {
        return false
    }
}
