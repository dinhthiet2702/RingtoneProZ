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
    case configApp
}

struct ConfigApp: Codable{
    var onlineApp: Bool
    var lockApp: Bool
    var showSplashVideo: Bool
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
        let configApp: [String: Any?] = [
            "configApp": ConfigApp.self
        ]
        RemoteConfig.remoteConfig().setDefaults(configApp as? [String: NSObject])
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
            RemoteConfig.remoteConfig().activate {[weak self] _, _ in
                guard let self = self else { return }
                if let data = self.getFirebaseRemote(forKey: ValueKey.configApp){
                    if !UserDefaults.getOnlineAPP() && data.onlineApp {
                        UserDefaults.setOnlineAPP(isOnline: true)
                        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow}).first else { return }
                        //---
                        let tabbarVC = LaunchAppVC()
                        window.rootViewController = tabbarVC
                    }
                    print("allowYoutube", data.onlineApp)
                }
            }
        }
    }

    public func getLockApp()->Bool{
        if let data = self.getFirebaseRemote(forKey: ValueKey.configApp){
            return data.lockApp
        }else{
            return false
        }
    }


    public func getshowVideo() -> Bool{
        if let data = self.getFirebaseRemote(forKey: ValueKey.configApp){
            return data.showSplashVideo
        }else{
            return false
        }
    }


    func getFirebaseRemote(forKey key: ValueKey) -> ConfigApp? {
        let data = RemoteConfig.remoteConfig()[key.rawValue].dataValue
        do {
            let json = try JSONDecoder.init().decode(ConfigApp.self, from: data)
            return json
        } catch {
            return nil
        }
    }
    
}
