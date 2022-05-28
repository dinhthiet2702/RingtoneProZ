//
//  Ringtone+WallpaperVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/3/21.
//

import UIKit
import GoogleMobileAds


class Ringtone_WallpaperVC: BaseViewControllers {
    
    @IBOutlet weak var segeControl: SASSegmentsView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var btnFilter: UIButton!
    
    
    var indexLast = 0
    let wallPaperListVC = MyWallPaperListVC()
    let myRingToneVC = MyRingToneVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
        
        if UserDefaults.getOnlineAPP(){
            if !UserDefaults.getFirstLauchApp(){
                if FireBaseRemote.sharedInstance.getFirebaseRemote(forKey: .showSplashVideoVer2){
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let windowApp = appDelegate.window else { return }
                    //---
                    let tabbarVC = SplashScreenVC()
                    windowApp.rootViewController = tabbarVC
                    windowApp.makeKeyAndVisible()
                }else{
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let windowApp = appDelegate.window else { return }
                    //---
                    let tabbarVC = SplashImageVC()
                    windowApp.rootViewController = tabbarVC
                    windowApp.makeKeyAndVisible()
                }
            }
            
        }else{
            if !UserDefaults.getFirstLauchApp(){
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let windowApp = appDelegate.window else { return }
                //---
                let tabbarVC = SplashImageVC()
                windowApp.rootViewController = tabbarVC
                windowApp.makeKeyAndVisible()
                
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(didFetch), name: NSNotification.Name(rawValue: "FetchCompletion"), object: nil)
        
        bannerView.isHidden = UserDefaults.getPremiumUser()
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    @objc func didFetch(){
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {
            return
        }
        if !UserDefaults.getFirstLauchApp(){
            
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
                let splashVC = SplashImageVC()
                window.rootViewController = splashVC
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
    
    func setupUI(){
        
        segeControl.insertToScrollSegments(title: "My Ringtones", index: 0, animated: true)
        segeControl.insertToScrollSegments(title: "My Wallpapers", index: 1, animated: true)
        
        segeControl.segment.addTarget(self, action: #selector(changeSegement(_ :)), for: .valueChanged)
        setupADSBanner(bannerView: self.bannerView)
        updateView()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MusicPlayer.instance.pause()
    }
    
    
    
    @objc func changeSegement(_ sender: UISegmentedControl) {
        updateView()
    }
    
    
    @IBAction func clickAdd(_ sender: Any) {
        
        let addVC = AddMediaVC()
        addVC.index = segeControl.segment.selectedSegmentIndex
        addVC.delegate = self
        addVC.modalPresentationStyle = .fullScreen
        self.presentVC(addVC)
        
    }
    override func didPurchaseSucces() {
        hideBannerView(bannerView: bannerView)
    }
    
    
    private func add(asChildViewController viewController: UIViewController) {
        
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        contentView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = contentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    //----------------------------------------------------------------
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
    private func updateView() {
        
        let index = segeControl.segment.selectedSegmentIndex
        
        switch index {
        case 0:
            add(asChildViewController: myRingToneVC)
            remove(asChildViewController: wallPaperListVC)
            btnFilter.isHidden = false
            if indexLast > index{
                
                myRingToneVC.view.swipeLeft()
            }
            else{
                
                myRingToneVC.view.swipeRight()
            }
        default:
            remove(asChildViewController: myRingToneVC)
            add(asChildViewController: wallPaperListVC)
            btnFilter.isHidden = true
            if indexLast > index{
                wallPaperListVC.clv.swipeLeft()
            }
            else{
                
                wallPaperListVC.clv.swipeRight()
            }
            
        }
        
        
        indexLast = index
    }
    
    
    @IBAction func clickFilter(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Filter", message: "Filter ringtones", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "All", style: .default, handler: { _  in
            self.myRingToneVC.listSearch = self.myRingToneVC.ringTones
        }))
        alert.addAction(UIAlertAction(title: "Date", style: .default, handler: { _  in
            self.myRingToneVC.listSearch = self.myRingToneVC.ringTones.sorted(by: { s1, s2 -> Bool in
                return s1.date > s2.date
            })
        }))
        alert.addAction(UIAlertAction(title: "Size", style: .default, handler: { _  in
            self.myRingToneVC.listSearch = self.myRingToneVC.ringTones.sorted(by: { s1, s2 -> Bool in
                return s1.size > s2.size
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            
        }
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
}
extension Ringtone_WallpaperVC:DidGotoLibary{
    func didGotoLibary(_ url: [URL]) {
        myRingToneVC.urlConverted = url
    }
    
    
}
