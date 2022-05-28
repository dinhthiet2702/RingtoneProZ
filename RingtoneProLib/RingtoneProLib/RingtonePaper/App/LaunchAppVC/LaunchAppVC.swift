//
//  LaunchAppVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 6/2/21.
//

import UIKit


class LaunchAppVC: UIViewController {
    @IBOutlet weak var widthLogo: NSLayoutConstraint!
    
    @IBOutlet weak var imvLogo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseIn){
            self.widthLogo.constant = UIScreen.main.bounds.width - 60
            self.imvLogo.alpha = 0
            self.view.layoutIfNeeded()

        } completion: { _ in

            self.changeTabbar()

        }

    }
    


    
    func changeTabbar(){
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {
            return
        }
        if !UserDefaults.getOnlineAPP(){
            
            //---
            let tabbarVC = BaseTabbar()
            window.rootViewController = tabbarVC
            UIView.transition(with: window,
                              duration: 0.55,
                              options: [.transitionCrossDissolve, .curveEaseOut],
                              animations: nil,
                              completion: { _ in
                                window.makeKeyAndVisible()
                              })
            
        }
        else{
            if UserDefaults.getFirstLauchApp(){
                //---
                let tabbarVC = BaseTabbar()
                window.rootViewController = tabbarVC
                UIView.transition(with: window,
                                  duration: 0.55,
                                  options: [.transitionCrossDissolve, .curveEaseOut],
                                  animations: nil,
                                  completion: { _ in
                                    window.makeKeyAndVisible()
                                  })
                
            }
            else{
                if FireBaseRemote.sharedInstance.getFirebaseRemote(forKey: .showSplashVideoVer2){
                    let tabbarVC = SplashScreenVC()
                    window.rootViewController = tabbarVC
                    UIView.transition(with: window,
                                      duration: 0.55,
                                      options: [.transitionCrossDissolve, .curveEaseOut],
                                      animations: nil,
                                      completion: { _ in
                                        window.makeKeyAndVisible()
                                      })
                }else{
                    let tabbarVC = SplashImageVC()
                    window.rootViewController = tabbarVC
                    UIView.transition(with: window,
                                      duration: 0.55,
                                      options: [.transitionCrossDissolve, .curveEaseOut],
                                      animations: nil,
                                      completion: { _ in
                                        window.makeKeyAndVisible()
                                      })
                }
                
            }
            
        }
    }
    

}
