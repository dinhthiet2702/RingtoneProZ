//
//  Double+Extension.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/10/21.
//

import Foundation

extension Double{
    func stringFromTimeInterval() -> String {

        let time = NSInteger(self)

        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        if hours <= 0{
            return String(format: "%0.2d:%0.2d",minutes,seconds)
        }

        else{
            return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
        }

    }
        
}
