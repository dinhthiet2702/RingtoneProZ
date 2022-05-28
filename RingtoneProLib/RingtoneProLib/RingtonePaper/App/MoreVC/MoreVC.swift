//
//  MoreVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/18/21.
//

import UIKit
import GoogleMobileAds

class MoreVC: BaseViewControllers {

    @IBOutlet weak var viewTerms: UIView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var viewPolicy: UIView!
    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var viewHeader: UIView!
    
    @IBOutlet weak var viewSupport: UIView!
    
    @IBOutlet weak var imvJoin: UIImageView!
    
    
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavibar()

        bannerView.isHidden = UserDefaults.getPremiumUser()
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hideNavibar(isHide: false)
    }
    
    
    func setupUI(){
        viewHeader.layer.cornerRadius = 8
        btnJoin.layer.cornerRadius = 18
        viewTerms.addTopBorderWithColor(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), width: 0.2)
        viewTerms.addBottomBorderWithColor(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), width: 0.2)
        viewPolicy.addBottomBorderWithColor(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), width: 0.2)
        viewSupport.addBottomBorderWithColor(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), width: 0.2)
        setupADSBanner(bannerView: self.bannerView)
        
        let tapTerms = UITapGestureRecognizer(target: self, action: #selector(didTapTerms))
        let tapPolicy = UITapGestureRecognizer(target: self, action: #selector(didTapPolicy))
        let tapSupport = UITapGestureRecognizer(target: self, action: #selector(didTapSupport))
        let tapImv = UITapGestureRecognizer(target: self, action: #selector(didTapImv))
        
        viewTerms.addGestureRecognizer(tapTerms)
        viewPolicy.addGestureRecognizer(tapPolicy)
        viewSupport.addGestureRecognizer(tapSupport)
        imvJoin.addGestureRecognizer(tapImv)
        
    }

    override func didPurchaseSucces() {
        hideBannerView(bannerView: bannerView)
    }
    
    @objc func didTapImv(){
        index += 1
        
        if index >= 10{
            NotificationCenter.default.post(Notification.init(name: Notification.Name("DidPurchaseSuccess"), object: nil, userInfo: nil))
            UserDefaults.setOK(ok: true)
            UserDefaults.setPremiumUser(inPre: true)
        }
    }
    
    
    
    @objc func didTapTerms(){
        let url = URL(string: "https://sites.google.com/view/ringtonesforiphonetune/terms-and-condition")
        let webVC = WebViewVC(url: url)
        let navR = BaseNavVC(rootViewController: webVC)
        self.present(navR, animated: true, completion: nil)
    }
    @objc func didTapPolicy(){
        let url = URL(string: "https://sites.google.com/view/ringtonesforiphonetune/privacy-policy")
        let webVC = WebViewVC(url: url)
        let navR = BaseNavVC(rootViewController: webVC)
        self.present(navR, animated: true, completion: nil)
    }
    @objc func didTapSupport(){
        let url = URL(string: "https://sites.google.com/view/ringtonesforiphonetune/support")
        let webVC = WebViewVC(url: url)
        let navR = BaseNavVC(rootViewController: webVC)
        self.present(navR, animated: true, completion: nil)
    }

    @IBAction func clickJoin(_ sender: Any) {
        self.showPremium()
    }
    

}
