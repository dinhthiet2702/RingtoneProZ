//
//  NSMutableAttributedString+Extension.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/10/21.
//

import UIKit


extension NSMutableAttributedString {

    public func setAsLink(textToFind:String, linkURL:String) -> Bool {

        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            
            return true
        }
        return false
    }
}
