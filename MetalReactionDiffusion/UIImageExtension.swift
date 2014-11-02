//
//  UIImageExtension.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 01/11/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import Foundation
import UIKit

extension UIImage
{
    func resizeToBoundingSquare(#boundingSquareSideLength : CGFloat) -> UIImage
    {
        let imgScale = self.size.width > self.size.height ? boundingSquareSideLength / self.size.width : boundingSquareSideLength / self.size.height
        let newWidth = self.size.width * imgScale
        let newHeight = self.size.height * imgScale
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContext(newSize)
        
        self.drawInRect(CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        return resizedImage
    }
    
}