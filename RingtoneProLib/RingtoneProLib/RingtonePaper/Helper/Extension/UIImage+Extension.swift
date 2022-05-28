//
//  UIImage+Extension.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/3/21.
//

import Foundation
import UIKit

enum Side: String {
    case top, left, right, bottom
}

extension UIImage{
    
    func imageWithColor(_ color: UIColor) -> UIImage? {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: width*size.height/size.width)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    
}


extension UIImage {
    func createSelectionIndicator(color: UIColor, size: CGSize, lineThickness: CGFloat, side: Side) -> UIImage {
        var xPosition = 0.0
        var yPosition = 0.0
        var imgWidth = 2.0
        var imgHeight = 2.0
        switch side {
        case .top:
            xPosition = 0.0
            yPosition = 0.0
            imgWidth = Double(size.width)
            imgHeight = Double(lineThickness)
        case .bottom:
            xPosition = 0.0
            yPosition = Double(size.height - lineThickness)
            imgWidth = Double(size.width)
            imgHeight = Double(lineThickness)
        case .left:
            xPosition = 0.0
            yPosition = 0.0
            imgWidth = Double(lineThickness)
            imgHeight = Double(size.height)
        case .right:
            xPosition = Double(size.width - lineThickness)
            yPosition = 0.0
            imgWidth = Double(lineThickness)
            imgHeight = Double(size.height)
        }
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        
        UIRectFill(CGRect(x: xPosition, y: yPosition, width: imgWidth, height: imgHeight))
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func getCropRatio()->CGFloat{
        let wRatio = CGFloat(self.size.width / self.size.height)
        return wRatio
    }
}

