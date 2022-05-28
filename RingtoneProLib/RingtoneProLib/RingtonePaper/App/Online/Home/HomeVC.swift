//
//  HomeVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/2/21.
//

import UIKit
import PKHUD
import GoogleMobileAds

class HomeVC: BaseViewControllers {
    
    @IBOutlet weak var tbv: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var headerHome: HeaderHome!
    
    let refeshControl = UIRefreshControl()
    
    var homeCategories:[CategoryModel] = []{
        didSet{
            tbv.reloadData()
        }
    }
    
    var genresCategories:[CategoryModel] = []{
        didSet{
            tbv.reloadData()
        }
    }
    
    var indexPath:IndexPath?
    var playList:PlayList?
    var genres:CategoryModel?
    
    private var interstitial: GADInterstitialAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        setupUI()
        UserDefaults.setFirstLauchApp(isFirst: true)
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    func setupUI(){
        headerHome.delegate = self
        tbv.delegate = self
        tbv.dataSource = self
        tbv.register(CellHome.self)
        tbv.register(CellGenres.self)
        refeshControl.backgroundColor = UIColor.clear
        refeshControl.tintColor = .clear
        
        refeshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.gray])
        
        tbv.addSubview(refeshControl)
        
        refeshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        
        setupADSBanner(bannerView: self.bannerView)
        
        
        let dummyViewHeight = CGFloat(40)
        self.tbv.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tbv.bounds.size.width, height: dummyViewHeight))
        self.tbv.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: 0, right: 0)
        
        HUD.show(.progress)
        reloadData()
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
    
    
    @objc func reloadData(){
        
        fetchData(page: 0) { listCate, listGenres  in
            
            
            var listCategories = listCate.sorted(by: { s1, s2 -> Bool in
                return s1.id! > s2.id!
            })
            if let index = listCategories.firstIndex(where: {$0.name?.uppercased() == "song on demand".uppercased()}){
                let recommand = listCategories.remove(at: index)
                listCategories.insert(recommand, at: listCategories.count)
                self.homeCategories = listCategories
                
            }else{
                self.homeCategories = listCategories
            }
            self.genresCategories = listGenres
            self.refeshControl.endRefreshing()
        }
    }
    
    
    
    
    
    func fetchData(page:Int?, completion: @escaping ([CategoryModel], [CategoryModel]) -> Void){
        if let page = page{
            APICategoryHome.getHome(page: page) { cateModel, genresModel  in
                if let cateModel = cateModel?.data{
                    if let genresModel = genresModel?.data {
                        DispatchQueue.main.async {
                            completion(cateModel, genresModel)
                        }
                    }else{
                        DispatchQueue.main.async {
                            completion(cateModel, [])
                        }
                    }
                    
                }
                else{
                    DispatchQueue.main.async {
                        completion([], [])
                    }
                }
            } fail: { err in
                //
            }
            
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavibar()
        
        bannerView.isHidden = UserDefaults.getPremiumUser()
        
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideNavibar(isHide: false)
    }
    
    override func didPurchaseSucces() {
        hideBannerView(bannerView: bannerView)
    }
    
    
}

extension HomeVC:UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if genresCategories.count > 0{
            return homeCategories.count+1
        }
        else{
            return homeCategories.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case homeCategories.count:
            
            let view = HeaderCell(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
            view.didClickSeeAll = { [weak self] in
                
                
                let genresVC = PlayListVC(arrGenres: self?.genresCategories)
                genresVC.titleVC = "Categories"
                genresVC.section = section
                return self?.pushVC(genresVC)
                
            }
            view.titleHeader.text = "Categories"
            
            return view
        default:
            let category = homeCategories[section]
            
            
            let view = HeaderCell(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
            
            if section == homeCategories.count-1{
                view.btnSeeAll.isHidden = true
            }else{
                view.btnSeeAll.isHidden = false
                view.didClickSeeAll = { [weak self] in
                    let playList = self?.homeCategories[section].playlists
                    let playListVC = PlayListVC(arrPlayList: playList)
                    playListVC.titleVC = category.name ?? ""
                    playListVC.section = section
                    return self?.pushVC(playListVC)
                    
                }
            }
            
            view.titleHeader.text = category.name
            
            return view
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case homeCategories.count:
            let cell = tbv.dequeueReusableCell(withIdentifier: CellGenres.defaultIdentifier, for: indexPath) as! CellGenres
            cell.bindDataGenres(genres: genresCategories)
            cell.delegate = self
            return cell
            
        default:
            let cell = tbv.dequeueReusableCell(withIdentifier: CellHome.defaultIdentifier, for: indexPath) as! CellHome
            if let playLists = homeCategories[indexPath.section].playlists{
                if indexPath.section == homeCategories.count-1{
                    cell.bindDataCate(playLists: playLists, flagCell: .recommend)
                }else{
                    cell.bindDataCate(playLists: playLists)
                }
                cell.delegate = self
            }
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case homeCategories.count:
            if UIDevice.current.userInterfaceIdiom == .pad{
                if genresCategories.count%3 == 0{
                    return CGFloat(370*(genresCategories.count/3))
                }else{
                    return CGFloat(370*((genresCategories.count/3)+1))
                }
            }else{
                if genresCategories.count%2 == 0{
                    return CGFloat(220*(genresCategories.count/2))
                }else{
                    return CGFloat(220*((genresCategories.count+1)/2))
                }
            }
            
            
        default:
            switch indexPath.section {
            case homeCategories.count - 1:
                return 220
            default:
                return 250
            }
        }
    }
    
    
    
    
}


extension HomeVC:ActionClickItemHomeDelegate{
    func didClickGenres(_ genres: CategoryModel?) {
        
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
    
    
    
    
    func didClickItemPlayList(_ playList: PlayList?, _ cell:CellHome) {
        
        if UserDefaults.getPremiumUser(){
            
            switch cell.flagCell {
            case .recommend:
                APICategoryHome.getPlayListFromCategory(id: playList?.id ?? 0) { model in
                    if let model = model?.data?.first{
                        let detailVC = SendRecommendVC(playList: model)
                        self.pushVC(detailVC)
                    }
                } fail: { err in
                    //
                }
            default:
                APICategoryHome.getPlayListFromCategory(id: playList?.id ?? 0) { model in
                    if let model = model?.data?.first{
                        let detailVC = DetailPlayListVC(songs: model.songs, playLists: model)
                        self.pushVC(detailVC)
                    }
                } fail: { err in
                    //
                }
            }
            
        }else{
            let indexPath = tbv.indexPath(for: cell)
            self.indexPath = indexPath
            self.playList = playList
            
            
            if indexPath?.section == 0{
                APICategoryHome.getPlayListFromCategory(id: playList?.id ?? 0) { model in
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
    
}

extension HomeVC:SearchHomeDelegate{
    func beginSearch() {
        if UserDefaults.getPremiumUser(){
            let searchVC = SearchVC()
            self.pushVC(searchVC)
        }else{
            self.showPremium()
        }
        
    }
    
    
}


extension HomeVC:GADFullScreenContentDelegate{
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
