//
//  SplashImageVC.swift
//  RingTones-Wallpapers
//
//  Created by thiet on 6/25/21.
//

import UIKit

class SplashImageVC: UIViewController {

    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var imv: UIImageView!

    init() {
        super.init(nibName: "SplashImageVC", bundle: BundleProvider.bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI(){
        if UIDevice.current.userInterfaceIdiom == .pad{
            imv.image = UIImage(named: "lauch_ipad")
        }else{
            imv.image = UIImage(named: "lauch_iphone")
        }
        btnContinue.layer.cornerRadius = 25
    }

    @IBAction func clickContinue(_ sender: Any) {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {
            return
        }
        
        let tabbarVC = BaseTabbar()
        window.rootViewController = tabbarVC
    }
    
}
