//
//  LaunchAppVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 6/2/21.
//

import UIKit


public class LaunchAppVC: UIViewController {
    @IBOutlet weak var widthLogo: NSLayoutConstraint!
    
    @IBOutlet weak var imvLogo: UIImageView!

    public init() {
        super.init(nibName: "LaunchAppVC", bundle: BundleProvider.bundle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
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
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        if !UserDefaults.getOnlineAPP(){
            let tabbarVC = BaseTabbar()
            window.rootViewController = tabbarVC
        } else{
            if UserDefaults.getPremiumUser() {
                //---
                let tabbarVC = BaseTabbar()
                window.rootViewController = tabbarVC
            } else{
                if FireBaseRemote.sharedInstance.getshowVideo() {
                    let tabbarVC = SplashScreenVC()
                    window.rootViewController = tabbarVC
                }else{
                    let tabbarVC = SplashImageVC()
                    window.rootViewController = tabbarVC
                }
                
            }
            
        }
    }
    

}
