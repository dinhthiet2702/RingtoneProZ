//
//  CategoryWallPaperVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/3/21.
//

import UIKit
import PKHUD
import GoogleMobileAds

class CategoryWallPaperVC: BaseViewControllers {

    @IBOutlet weak var clv: UICollectionView!
    
    
    var categories:[CategoryWallpaper] = []{
        didSet{
            clv.reloadData()
        }
    }
    
    private var interstitial: GADInterstitialAd?
    var indexPath:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }

    
    
    func setupUI(){
        
        clv.delegate = self
        clv.dataSource = self
        clv.register(UINib(nibName: "CellCategoryWall", bundle: nil), forCellWithReuseIdentifier: CellCategoryWall.description())
        if let layout = clv?.collectionViewLayout as? DynamicLayout {
            layout.delegate = self
        }
        
        clv?.contentInset = UIEdgeInsets(top: 20, left: 16, bottom: 10, right: 16)
        loadCategories()
        
        let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID:"ca-app-pub-1478057197787470/2933112803",
                                        request: request,
                              completionHandler: { [self] ad, error in
                                if let error = error {
                                  print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                  return
                                }
                                interstitial = ad
                                interstitial?.fullScreenContentDelegate = self
                              }
            )
    }

    
    
    func loadCategories(){
        APIWallpapers.getListCategory { data in
            if let categories = data?.data?.sorted(by: { s1, s2 -> Bool in
                guard let id1 = s1.id, let id2 = s2.id else {return false}
                return id1 > id2
            }){
                
                
                self.categories = categories
            }
            else{
                self.categories = []
            }
        } fail: { err in
            
        }

    }
    

}
extension CategoryWallPaperVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = clv.dequeueReusableCell(withReuseIdentifier: CellCategoryWall.description(), for: indexPath) as! CellCategoryWall
        
        let category = categories[indexPath.row]
        cell.bindData(category: category)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if UserDefaults.getPremiumUser(){
            if let id = categories[indexPath.item].id{
                HUD.show(.progress)
                APIWallpapers.getLiveFromCategory(id: id, page: 0) { data in
                    if let listW = data?.data{
                        let details = WallPaperListOnlineVC(lisWallPapers: listW, idCategory: id)
                        details.titleVC = self.categories[indexPath.item].title ?? ""
                        self.pushVC(details)
                    }
                    else{
                        HUD.hide()
                    }
                } fail: { _ in
                    
                }
            }
        }else{
            
            self.indexPath = indexPath
            
            if !UserDefaults.getOnlineAPP(){
                if interstitial != nil {
                    
                    interstitial?.present(fromRootViewController: self)
                  } else {
                    if indexPath.item > 3{
                        self.showPremium()
                    }else{
                        
                        if let id = categories[indexPath.item].id{
                            HUD.show(.progress)
                            APIWallpapers.getLiveFromCategory(id: id, page: 0) { data in
                                if let listW = data?.data{
                                    let details = WallPaperListOnlineVC(lisWallPapers: listW, idCategory: id)
                                    details.titleVC = self.categories[indexPath.item].title ?? ""
                                    self.pushVC(details)
                                }
                                else{
                                    HUD.hide()
                                }
                            } fail: { _ in
                                
                            }
                        }
                    }
                }
                //apple
                
            }
            else{
                
                if interstitial != nil {
                    if MusicPlayer.instance.onlinePlay{
                        MusicPlayer.clickPlay.accept(.pause)
                    }
                    interstitial?.present(fromRootViewController: self)
                  } else {
                    self.showPremium()
                }
                
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 2 - 20, height: UIScreen.main.bounds.width / 2 - 20)
    }
    
    
    
}
extension CategoryWallPaperVC: DynamicLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        
        return UIScreen.main.bounds.width / 2 - 20
        
    }
}
extension CategoryWallPaperVC: GADFullScreenContentDelegate {

    
    /// Tells the delegate that the ad failed to present full screen content.
      func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        guard let indexPath = indexPath else {return}
        if !UserDefaults.getOnlineAPP(){
            
                if indexPath.item > 3{
                    self.showPremium()
                }else{
                    
                    if let id = categories[indexPath.item].id{
                        HUD.show(.progress)
                        APIWallpapers.getLiveFromCategory(id: id, page: 0) { data in
                            if let listW = data?.data{
                                let details = WallPaperListOnlineVC(lisWallPapers: listW, idCategory: id)
                                details.titleVC = self.categories[indexPath.item].title ?? ""
                                self.pushVC(details)
                            }
                            else{
                                HUD.hide()
                            }
                        } fail: { _ in
                            
                        }
                    }
                }
            //apple
            
        }
        else{
            self.showPremium()
            
        }
      }

      /// Tells the delegate that the ad presented full screen content.
      func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
      }

      /// Tells the delegate that the ad dismissed full screen content.
      func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
        guard let indexPath = indexPath else {return}
        if !UserDefaults.getOnlineAPP(){
            
                if indexPath.item > 3{
                    self.showPremium()
                }else{
                    
                    if let id = categories[indexPath.item].id{
                        HUD.show(.progress)
                        APIWallpapers.getLiveFromCategory(id: id, page: 0) { data in
                            if let listW = data?.data{
                                let details = WallPaperListOnlineVC(lisWallPapers: listW, idCategory: id)
                                details.titleVC = self.categories[indexPath.item].title ?? ""
                                self.pushVC(details)
                            }
                            else{
                                HUD.hide()
                            }
                        } fail: { _ in
                            
                        }
                    }
                }
            //apple
            
        }
        else{
            self.showPremium()
            
        }
        interstitial = nil
      }
}
