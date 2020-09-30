//
//  UIImage Ext.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 6/30/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    ///get the image in the correct orientation by redrawing
    func normalizedImage() -> UIImage {
        
        if (self.imageOrientation == .up) {
            return self;
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, true, self.scale);
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        
        return normalizedImage;
    }
    
    ///alternative function to normalize image
    func normalizePng() -> UIImage {
        
        let format = UIGraphicsImageRendererFormat()
        
        format.opaque = true
        
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            
           let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            
           self.draw(in: rect)
            
        }
        
    }
    
}
