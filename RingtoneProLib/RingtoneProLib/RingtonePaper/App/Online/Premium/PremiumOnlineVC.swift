//
//  PremiumVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/28/21.
//


import UIKit
import StoreKit


enum FlagPremiumPosition{
    case home
    case tabbar
}



class PremiumOnlineVC: BaseViewControllers {
    
    @IBOutlet weak var topMarginCloseButton: NSLayoutConstraint!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var titleInApp: UILabel!
    @IBOutlet weak var lbPriceMonth: UILabel!
    @IBOutlet weak var lbPriceYear: UILabel!
    @IBOutlet var viewProducts: [UIView]!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewYear: UIView!
    @IBOutlet weak var viewMonth: UIView!
    @IBOutlet weak var viewWeek: UIView!
    @IBOutlet weak var lbPriceWeek: UILabel!
    var idProduct = IAPManager.oneMonth
    var flagVC:FlagPremiumPosition = .home
    
    var listProducts:[SKProduct] = []{
        didSet{
            lbPriceWeek.text = getPriceFormatted(for: listProducts.filter {$0.productIdentifier == IAPManager.onWeek}.first)
            lbPriceMonth.text = getPriceFormatted(for: listProducts.filter {$0.productIdentifier == IAPManager.oneMonth}.first)
            lbPriceYear.text = getPriceFormatted(for: listProducts.filter {$0.productIdentifier == IAPManager.oneYear}.first)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setGradientBackground()
        super.viewWillAppear(animated)
    }
   
    private func setupUI() {
       
        viewProducts.forEach { view in
            view.layer.cornerRadius = 10
            
            view.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.35)
        }
        
        let tapWeek = UITapGestureRecognizer(target: self, action: #selector(didTapWeek))
        let tapMonth = UITapGestureRecognizer(target: self, action: #selector(didTapMonth))
        let tapYear = UITapGestureRecognizer(target: self, action: #selector(didTapYear))
        
        viewWeek.addGestureRecognizer(tapWeek)
        viewMonth.addGestureRecognizer(tapMonth)
        viewYear.addGestureRecognizer(tapYear)
        
        viewWeek.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.35)
        viewMonth.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        viewMonth.layer.borderWidth = 3
        viewYear.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.35)
      
        scrollView.layer.cornerRadius = 20
        
        
        btnContinue.layer.cornerRadius = 25
        
        IAPManager.store.requestPackInfo { (listProducts) in
            self.listProducts = listProducts
            
        }
    }
    
    @objc func didTapWeek(){
        viewProducts.forEach { view in
            
            view.layer.borderWidth = 0
            view.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.35)
        }
        viewWeek.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        viewWeek.layer.borderWidth = 3
        idProduct = IAPManager.onWeek
    }
    @objc func didTapMonth(){
        viewProducts.forEach { view in
            
            view.layer.borderWidth = 0
            view.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.35)
        }
        
        viewMonth.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        viewMonth.layer.borderWidth = 3
        idProduct = IAPManager.oneMonth
        
    }
    @objc func didTapYear(){
        viewProducts.forEach { view in
            
            view.layer.borderWidth = 0
            view.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.35)
        }
        
        viewYear.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        viewYear.layer.borderWidth = 3
        idProduct = IAPManager.oneYear
    }
    
    
    func setGradientBackground() {
        self.view.layoutIfNeeded()
        let colorTop =  #colorLiteral(red: 1, green: 0.4392156863, blue: 0.3176470588, alpha: 0.71).cgColor
        let colorBottom = #colorLiteral(red: 1, green: 0.7058823529, blue: 0.1960784314, alpha: 1).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = scrollView.bounds
        scrollView.layer.insertSublayer(gradientLayer, at:0)
    }
    
    
    func getPriceFormatted(for product: SKProduct?) -> String {
        if let product = product{
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceLocale
            return formatter.string(from: product.price) ?? "0"
        }
        else{
            return "0"
        }
        
    }
    
    
    
    
    @IBAction func TermofUse(_ sender: Any) {
        let url = URL(string: "https://sites.google.com/view/ringtonesforiphonetune/terms-and-condition")
        let webVC = WebViewVC(url: url)
        let navR = BaseNavVC(rootViewController: webVC)
        self.present(navR, animated: true, completion: nil)
        
    }
    @IBAction func Privacy(_ sender: Any) {
        let url = URL(string: "https://sites.google.com/view/ringtonesforiphonetune/privacy-policy")
        let webVC = WebViewVC(url: url)
        let navR = BaseNavVC(rootViewController: webVC)
        self.present(navR, animated: true, completion: nil)
    }
    
    @IBAction func onTapRestore(_ sender: Any) {
        IAPManager.store.restorePurchase {
            
            switch self.flagVC {
            case .home:
                NotificationCenter.default.post(Notification.init(name: Notification.Name("DidPurchaseSuccess"), object: nil, userInfo: nil))
                self.dismiss(animated: true, completion: nil)
            default:
                self.gotoTabbar()
            }
        }
    }
    
    @IBAction func onTapCloseButton(_ sender: Any) {
        
        switch flagVC {
        case .home:
            self.dismiss(animated: true, completion: nil)
        default:
            if FireBaseRemote.sharedInstance.getFirebaseRemote(forKey: ValueKey.lockAppVer2){
                self.dismiss(animated: true, completion: nil)
            }else{
                gotoTabbar()
            }
           
        }
    }
    
    @IBAction func onTapContinueButton(_ sender: UIButton) {
        
        IAPManager.store.purchasePack(packNameId: idProduct) {[weak self] in
            switch self?.flagVC {
            case .home:
                
                NotificationCenter.default.post(Notification.init(name: Notification.Name("DidPurchaseSuccess"), object: nil, userInfo: nil))
                self?.dismiss(animated: true, completion: nil)
                
            default:
                self?.gotoTabbar()
            }
            
        }
    }
    func gotoTabbar(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let windowApp = appDelegate.window else { return }
        //---
        let tabbarVC = BaseTabbar()
        windowApp.rootViewController = tabbarVC
        windowApp.makeKeyAndVisible()
    }
}

