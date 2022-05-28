//
//  BaseViewControllers.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/7/21.
//

import UIKit
import GoogleMobileAds


class BaseViewControllers: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transparentNav()
        
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action:#selector(tap))
        tapGestureReconizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureReconizer)
        navigationController?.changeStatusBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(didPurchaseSucces), name: Notification.Name("DidPurchaseSuccess"), object: nil)
    }
    
    func setupADSBanner(bannerView:GADBannerView){
        bannerView.adUnitID = "ca-app-pub-1478057197787470/9498521156"
        bannerView.rootViewController = self
        if UserDefaults.getPremiumUser(){
            bannerView.isHidden = true
        }else{
            bannerView.isHidden = false
            bannerView.load(GADRequest())
        }
    }
    
    
    @objc func didPurchaseSucces(){
        
    }
    
        
    func hideBannerView(bannerView:GADBannerView){
        bannerView.isHidden = true
    }
        
        
        // Do any additional setup after loading the view.
    
    
    func showAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc func tap(){
        view.endEditing(true)
    }
    
    func changeTextTitle(title:String){
       
    }
    
    func changeLeftButton(image:UIImage? = UIImage()){
        
        let btn = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        if let image = image {
            btn.setImage(image, for: .normal)
        }
        
        btn.addTarget(self, action: #selector(clickLeft), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem =  UIBarButtonItem(customView: btn)
        
        
    }
    
    func changeRightButton(image:UIImage? = nil, title:String?, color:UIColor? = nil){
        
        let btn = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        if let image = image {
            btn.setImage(image, for: .normal)
        }else{
            if let title = title{
                btn.setTitle(title, for: .normal)
                btn.setTitleColor(.black, for: .normal)
            }
        }
        if let color = color{
            btn.setTitleColor(color, for: .normal)
        }
        btn.addTarget(self, action: #selector(clickRight), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem =  UIBarButtonItem(customView: btn)
    }
    
    
    func transparentNav(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
        
    }
    
    
    func hideNavibar(isHide:Bool = true){
        
        self.navigationController?.navigationBar.isHidden = isHide
       
        
    }
    
    @objc func clickLeft(sender : UIButton){
        
    }
    
    @objc func clickRight(){
        
        
        
    }

    
    func pushVC(_ vc:UIViewController){
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func popViewController(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func presentVC(_ vc:UIViewController){
        self.present(vc, animated: true, completion: nil)
    }
    
    func dismissVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func showPremium(flagVC:FlagPremiumPosition = .home){
        
        if !UserDefaults.getOnlineAPP(){
            let premiumVC = PremiumVC()
            self.presentVC(premiumVC)
        }else{
            let premiumVC = PremiumOnlineVC()
            premiumVC.flagVC = flagVC
            
            switch flagVC {
            case .tabbar:
                premiumVC.modalPresentationStyle = .fullScreen
            default:
                premiumVC.modalPresentationStyle = .pageSheet
            }
            
            self.presentVC(premiumVC)
        }
        
        
    }

}
