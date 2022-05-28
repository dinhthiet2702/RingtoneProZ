//
//  FireBaseConfig.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/29/21.
//


import Foundation
import Firebase
import FirebaseRemoteConfig


enum ValueKey: String {
    case onlineAppVer2
    case lockAppVer2
    case showSplashVideoVer2
}



class FireBaseRemote {
    static let sharedInstance = FireBaseRemote()
    
    
    var loadingDoneCallback: (() -> Void)?
    var fetchComplete = false
    
    private init() {
        loadDefaultValues()
        fetchCloudValues()
        
    }
    
    func loadDefaultValues() {
        let isUnlockKey: [String: Any?] = [
            "onlineApp": false,
            "lockApp": false,
            "showSplashVideoVer2":false
        ]
        RemoteConfig.remoteConfig().setDefaults(isUnlockKey as? [String: NSObject])
    }
    
    
    func activateDebugMode() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings
    }
    
    func fetchCloudValues() {
        activateDebugMode()

        RemoteConfig.remoteConfig().fetch {  _, error in
            if let error = error {
                print("Uh-oh. Got an error fetching remote values \(error)")
                return
            }
            
            
            RemoteConfig.remoteConfig().activate {_, _ in
                if self.getFirebaseRemote(forKey: ValueKey.onlineAppVer2){
                    UserDefaults.setOnlineAPP(isOnline: true)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "FetchCompletion")))
                    }
                }
            }
        }
    }
    
    func getFirebaseRemote(forKey key: ValueKey) -> Bool {
        let isUnlock = RemoteConfig.remoteConfig()[key.rawValue].boolValue
        return isUnlock
    }
    
}
