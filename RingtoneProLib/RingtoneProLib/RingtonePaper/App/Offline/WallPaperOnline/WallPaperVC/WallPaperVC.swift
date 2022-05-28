//
//  WallPaperVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/3/21.
//

import UIKit
import GoogleMobileAds

class WallPaperVC: BaseViewControllers {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var segeControl: SASSegmentsView!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    let categoryVC = CategoryWallPaperVC()
    
    
    var indexLast = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
       
        bannerView.isHidden = UserDefaults.getPremiumUser()
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setupUI(){
        
        segeControl.insertToScrollSegments(title: "Categories", index: 0, animated: true)
        segeControl.segment.addTarget(self, action: #selector(actionSege(_ :)), for: .valueChanged)
        setupADSBanner(bannerView: self.bannerView)
        updateView()
        
        
    }
    
    override func didPurchaseSucces() {
        hideBannerView(bannerView: bannerView)
    }

    @objc func actionSege(_ sender: UISegmentedControl) {
        
        updateView()
        
        
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
    
    //----------------------------------------------------------------
    
    private func updateView() {
    
//        let index = segeControl.segment.selectedSegmentIndex
//
//        switch index {
//        case 0:
//
//            remove(asChildViewController: wallPaperListVC)
//            add(asChildViewController: wallPaperListVC)
////            wallPaperListVC.size = 5
//
//            if indexLast > index{
//                wallPaperListVC.clv.swipeLeft()
//            }
//            else{
//                wallPaperListVC.clv.swipeRight()
//            }
//        case 1:
//
//            remove(asChildViewController: wallPaperListVC)
//            add(asChildViewController: wallPaperListVC)
////            wallPaperListVC.size = 10
//            if indexLast > index{
//                wallPaperListVC.clv.swipeLeft()
//            }
//            else{
//                wallPaperListVC.clv.swipeRight()
//            }
//        case 2:
//
//            remove(asChildViewController: wallPaperListVC)
//            add(asChildViewController: wallPaperListVC)
////            wallPaperListVC.size = 20
//            if indexLast > index{
//                wallPaperListVC.clv.swipeLeft()
//            }
//            else{
//                wallPaperListVC.clv.swipeRight()
//            }
//        default:
//            remove(asChildViewController: wallPaperListVC)
            add(asChildViewController: categoryVC)
//            if indexLast > index{
//                categoryVC.clv.swipeLeft()
//            }
//            else{
//                categoryVC.clv.swipeRight()
//            }
//        }
//        indexLast = index
//
    }
    
    
}


