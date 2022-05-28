//
//  PlayListLibrary.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/23/21.
//

import UIKit
import GoogleMobileAds


class PlayListVC: BaseViewControllers {

    @IBOutlet weak var clv: UICollectionView!
    
    var arrPlayList:[PlayList]?{
        didSet{
            clv.reloadData()
        }
    }
    
    var arrGenres:[CategoryModel]?
    
    var titleVC = "Play List"
    
    var section = 0
    
    private var interstitial: GADInterstitialAd?
    
    var hidenKeyBroad:(()->Void)?
    
    var playList:PlayList?
    
    init(arrPlayList:[PlayList]?) {
        self.arrPlayList = arrPlayList
        super.init(nibName: nil, bundle: nil)
    }
    
    init(arrGenres:[CategoryModel]?) {
        self.arrGenres = arrGenres
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
   
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavibar(isHide: false)
        
        
    }

    
    func setupUI(){
        clv.delegate = self
        clv.dataSource = self
        clv.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        clv.register(CellHomeItem.self)
        
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
        
        
//        hideNavibar()
    }
    
    override func clickLeft(sender: UIButton) {
        self.popViewController()
    }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hidenKeyBroad?()
    }

}
extension PlayListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        arrPlayList?.count ?? arrGenres?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = clv.dequeueReusableCell(withReuseIdentifier: CellHomeItem.defaultIdentifier, for: indexPath) as! CellHomeItem
        
        if let playList = arrPlayList?[indexPath.item]{
            cell.bindDataHome(playlist: playList)
        }else if let genre = arrGenres?[indexPath.item]{
            cell.bindDataGenres(genres: genre)
        }
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let id = arrPlayList?[indexPath.item].id{
            
            if UserDefaults.getPremiumUser(){
                APICategoryHome.getPlayListFromCategory(id: id) { model in
                    if let model = model?.data?.first{
                        let detailVC = DetailPlayListVC(songs: model.songs, playLists: model)
                        self.pushVC(detailVC)
                    }
                } fail: { err in
                    //
                }
            }else{
                self.playList = arrPlayList?[indexPath.item]
                if section == 0{
                    APICategoryHome.getPlayListFromCategory(id: id) { model in
                        if let model = model?.data?.first{
                            let detailVC = DetailPlayListVC(songs: model.songs, playLists: model)
                            self.pushVC(detailVC)
                        }
                    } fail: { err in
                        //
                    }
                }else{
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

        }else{
            let genres = arrGenres?[indexPath.item]
            if UserDefaults.getPremiumUser(){
                APICategoryHome.getGenresById(id: genres?.id ?? 0) { model in
                    if let model = model?.data?.first{
                        let detailVC = DetailPlayListVC(songs: model.songs, playLists: model)
                        self.pushVC(detailVC)
                    }
                } fail: { err in
                    //
                }
            }else{
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         
        if arrPlayList != nil{
            
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: UIScreen.main.bounds.width/3 - 30, height: 400)
            }else{
                return CGSize(width: UIScreen.main.bounds.width/2 - 30, height: 250)
            }
            
        }else{
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: UIScreen.main.bounds.width/3 - 30, height: 350)
            }else{
                return CGSize(width: UIScreen.main.bounds.width/2 - 30, height: 200)
            }
            
        }
        
    }
    
    
}
extension PlayListVC: GADFullScreenContentDelegate{
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        
        self.showPremium()
        
        
    }
    
    /// Tells the delegate that the ad presented full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
        
        self.showPremium()
        
        interstitial = nil
        
    }
}
