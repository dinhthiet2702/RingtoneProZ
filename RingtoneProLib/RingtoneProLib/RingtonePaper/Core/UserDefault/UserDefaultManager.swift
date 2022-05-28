//
//  UserDefaultManager.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/28/21.
//

import Foundation
import UIKit


extension UserDefaults{
    
    static func setPremiumUser(inPre: Bool) {
        let defaults = UserDefaults.standard
        defaults.setValue(inPre, forKey: "user_premium")
    }
    
    
    static func getPremiumUser() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "user_premium")
    }
    
    static func setOK(ok: Bool) {
        let defaults = UserDefaults.standard
        defaults.setValue(ok, forKey: "OKOK")
    }
    static func getOK() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "OKOK")
    }
    
    static func setFirstLauchApp(isFirst: Bool) {
        let defaults = UserDefaults.standard
        defaults.setValue(isFirst, forKey: "lauchApp")
    }
    
    static func getFirstLauchApp() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "lauchApp")
    }
    
    static func setOnlineAPP(isOnline: Bool) {
        let defaults = UserDefaults.standard
        defaults.setValue(isOnline, forKey: "onlineApp")
    }
    
    static func getOnlineAPP() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "onlineApp")
    }
    
    static func setTapMusic(didTap: [String]) {
        let defaults = UserDefaults.standard
        defaults.setValue(didTap, forKey: "tapMusic")
    }
    
    static func getTapMusic() -> [String] {
        let defaults = UserDefaults.standard
        if let arr = defaults.array(forKey: "tapMusic") as? [String]{
            return arr
        }
        else{
            return []
        }
       
    }
    
    
    
}
