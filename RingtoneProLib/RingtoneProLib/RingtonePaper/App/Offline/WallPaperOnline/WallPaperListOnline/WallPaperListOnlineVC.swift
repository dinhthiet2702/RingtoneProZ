//
//  WallPaperListOnlineVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/2/21.
//

import UIKit
import GoogleMobileAds

class WallPaperListOnlineVC: BaseViewControllers {
    @IBOutlet var clvPaper: UICollectionView!
    
    
    var isLoading = false
    var pageLive = 0
    var idCategory:Int?
    
    var titleVC = ""
    
    var lisWallPapers:[WallpaperLive]? = []{
        didSet{
            
            clvPaper.reloadData()
            
        }
    }
    
    var indexPath:IndexPath?
    
    private var interstitial: GADInterstitialAd?
    
    init(lisWallPapers:[WallpaperLive]?, idCategory:Int?) {
        self.lisWallPapers = lisWallPapers
        self.idCategory = idCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupUI()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pageLive = 0
        isLoading = false
    }
    
    
    func setupUI(){
        
        clvPaper.delegate = self
        clvPaper.dataSource = self
        clvPaper.loadControl = UILoadControl(target: self, action: #selector(loadMore))
        clvPaper.loadControl?.heightLimit = 100
        clvPaper.register(UINib(nibName: "Cell_Item_Paper", bundle: nil), forCellWithReuseIdentifier: Cell_Item_Paper.description())
        
        if let layout = clvPaper?.collectionViewLayout as? DynamicLayout {
            layout.delegate = self
        }
        clvPaper?.contentInset = UIEdgeInsets(top: 20, left: 16, bottom: 10, right: 16)
        navigationItem.title = titleVC
        changeLeftButton(image: #imageLiteral(resourceName: "backTrim"))
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
    
    @objc func loadMore(){
        if isLoading{
          
            self.clvPaper.loadControl?.endLoading()
            
            return
        }
        
        else{
            
            if let id = idCategory{
                pageLive += 1
                
                APIWallpapers.getLiveFromCategory(id: id, page: pageLive) { data in
                    if let listW = data?.data{
                        if listW.count > 0{
                            self.lisWallPapers?.append(contentsOf: listW)
                            self.isLoading = false
                            self.clvPaper.loadControl?.endLoading()
                        }
                        else{
                            self.isLoading = true
                            self.clvPaper.loadControl?.endLoading()
                        }
                    }
                    else{
                        self.isLoading = true
                        self.clvPaper.loadControl?.endLoading()
                    }
                } fail: { _ in
                    self.isLoading = true
                    self.clvPaper.loadControl?.endLoading()
                }
                
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isLoading{
            return
        }
        else{
            scrollView.loadControl?.update()
        }
    }
   
    
    override func clickLeft(sender: UIButton) {
        self.popViewController()
        
    }
    
}
extension WallPaperListOnlineVC:UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lisWallPapers?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = clvPaper.dequeueReusableCell(withReuseIdentifier: Cell_Item_Paper.description(), for: indexPath) as! Cell_Item_Paper
        let currentImage = lisWallPapers?[indexPath.item]
        
        
        if let link = currentImage?.thumbnail, let url = URL(string: link){
            cell.bindData(url: url)
            cell.btnDelete.isHidden = true
        }else{
            cell.backgroundColor = #colorLiteral(red: 0.06274509804, green: 0.8039215686, blue: 0.9607843137, alpha: 1)
        }
        
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        self.indexPath = indexPath
        
        if UserDefaults.getPremiumUser(){
            let currentImage = lisWallPapers?[indexPath.item]
            
            if let link = currentImage?.original, let lisWallPapers = lisWallPapers {
                print("link", link)
                let browserVC = BrowserLiveVC(urlLive: link, flagBrowser: .online)
                browserVC.lisWallPapers = lisWallPapers
                browserVC.modalPresentationStyle = .fullScreen
                self.present(browserVC, animated: true, completion: nil)
            }
        }
        else{
            
            if interstitial != nil {
                interstitial?.present(fromRootViewController: self)
              } else {
                if indexPath.item > 3{
                    
                    self.showPremium()
                    
                }
                else{
                    let currentImage = lisWallPapers?[indexPath.item]
                    
                    if let link = currentImage?.original, let lisWallPapers = lisWallPapers {
                        print("link", link)
                        let browserVC = BrowserLiveVC(urlLive: link, flagBrowser: .online)
                        browserVC.lisWallPapers = lisWallPapers
                        browserVC.modalPresentationStyle = .fullScreen
                        self.present(browserVC, animated: true, completion: nil)
                    }
                }
              }
            
        }
        
        
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 2 - 30
        let currentImage = lisWallPapers?[indexPath.item]
        
        if let resolution = currentImage?.resolution{
            let s = resolution.splitText("X")
            if let w = s.first,
               let wi = NumberFormatter().number(from: w),
               let h = s.last,
               let he = NumberFormatter().number(from: h){
                let ratio =  CGFloat(truncating: wi)/CGFloat(truncating: he)
                let height = width*ratio*2
                return CGSize(width: width, height: height)
                
            }
        }
        return CGSize(width: width, height: width*2)
        
    }
    
    
    
}
extension WallPaperListOnlineVC: DynamicLayoutDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        let width = UIScreen.main.bounds.width / 2 - 30
        let currentImage = lisWallPapers?[indexPath.item]
        if let resolution = currentImage?.resolution{
            let s = resolution.splitText("X")
            if let w = s.first,
               let wi = NumberFormatter().number(from: w),
               let h = s.last,
               let he = NumberFormatter().number(from: h){
                let ratio =  CGFloat(truncating: wi)/CGFloat(truncating: he)
                let height = width*ratio*2
                return height
                
            }
        }
        return width*2
    }
}
extension WallPaperListOnlineVC:GADFullScreenContentDelegate{
    /// Tells the delegate that the ad failed to present full screen content.
      func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        guard let indexPath = indexPath else {return}
        if indexPath.item > 3{
            
            self.showPremium()
            
        }
        else{
            let currentImage = lisWallPapers?[indexPath.item]
            
            if let link = currentImage?.original, let lisWallPapers = lisWallPapers {
                print("link", link)
                let browserVC = BrowserLiveVC(urlLive: link, flagBrowser: .online)
                browserVC.lisWallPapers = lisWallPapers
                browserVC.modalPresentationStyle = .fullScreen
                self.present(browserVC, animated: true, completion: nil)
            }
        }
    
      }

      /// Tells the delegate that the ad presented full screen content.
      func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
      }

      /// Tells the delegate that the ad dismissed full screen content.
      func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        guard let indexPath = indexPath else {return}
        if indexPath.item > 3{
            
            self.showPremium()
            
        }
        else{
            let currentImage = lisWallPapers?[indexPath.item]
            
            if let link = currentImage?.original, let lisWallPapers = lisWallPapers {
                print("link", link)
                let browserVC = BrowserLiveVC(urlLive: link, flagBrowser: .online)
                browserVC.lisWallPapers = lisWallPapers
                browserVC.modalPresentationStyle = .fullScreen
                self.present(browserVC, animated: true, completion: nil)
            }
        }
        
        interstitial = nil
      }
}
