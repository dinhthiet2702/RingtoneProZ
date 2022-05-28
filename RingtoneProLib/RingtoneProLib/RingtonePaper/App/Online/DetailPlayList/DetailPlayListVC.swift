//
//  DetailPlayListVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/18/21.
//

import UIKit
import SDWebImage
import RxSwift
import GoogleMobileAds


class DetailPlayListVC: BaseViewControllers {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stack1: UIStackView!
    
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var btnShuffle: UIButton!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var lbSub: UILabel!
    
    @IBOutlet var btnScreen: [UIButton]!
    
    @IBOutlet weak var lbCountAudio: UILabel!
    
    @IBOutlet weak var tbv: UITableView!
    
    @IBOutlet weak var imvPlayList: UIImageView!
    
    @IBOutlet weak var headerView: HeaderPlayList!
    
    @IBOutlet weak var heightTBV: NSLayoutConstraint!
    
    var playLists:PlayList?
    
    var disposeBag = DisposeBag()
    
    private var interstitial: GADInterstitialAd?
    
    var songs:[Song]?{
        didSet{
            tbv.reloadData()
        }
    }
    
    var indexPath:IndexPath?
    
    init(songs:[Song]?, playLists:PlayList?) {
        self.songs = songs
        self.playLists = playLists
        super.init(nibName: nil, bundle: nil)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("VC did deint")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavibar()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hideNavibar(isHide: false)
        // MusicPlayer.nextBtn.tbv = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        heightTBV.constant = tbv.contentSize.height
    }
    
    func setupUI(){
        btnScreen.forEach { btn in
            btn.layer.cornerRadius = 22.5
            btn.clipsToBounds = true
        }
        tbv.delegate = self
        tbv.dataSource = self
        tbv.register(CellDetailPlayList.self)
        changeLeftButton(image: #imageLiteral(resourceName: "backTrim"))
        viewShadow.layer.cornerRadius = 10
        imvPlayList.layer.cornerRadius = 10
        viewShadow.clipsToBounds = true
        viewShadow.dropShadow(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), opacity: 0.5, offSet: CGSize(width: 1, height: 10))
        lbCountAudio.text = "\(songs?.count ?? 0) songs"
        if let playLists = playLists{
            stack1.isHidden = false
            imvPlayList.isHidden = false
            if let image = playLists.image?.queryURL, let url = URL(string: image){
                imvPlayList.sd_imageIndicator =  SDWebImageActivityIndicator.gray
                imvPlayList.sd_setImage(with: url) { (img, err, _, _) in
                    if err != nil{
                        self.imvPlayList.image = #imageLiteral(resourceName: "ks")
                    }
                    
                }
            }else{
                imvPlayList.image = #imageLiteral(resourceName: "ks")
            }
            lbSub.text = playLists.details
            lbTitle.text = playLists.name
        }
        
        
        headerView.clickDismiss = {[weak self] in
            self?.popViewController()
        }
        
        
        setupRX()
        
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
    
    func setupRX(){
        btnPlay.rx.tap
            .asDriver()
            .debounce(.milliseconds(500))
            .drive(onNext: {[weak self] _ in
                guard let self = self else {return}
                if UserDefaults.getPremiumUser(){
                    if let songs =  self.songs, songs.count > 0{
                        
                        MusicPlayer.showMiniPlayer(tabBarController: self.tabBarController, indexPath: IndexPath(row: 0, section: 0), songs: songs, tbv: self.tbv)
                    }
                    
                }
                else{
                    self.showPremium()
                }
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        btnShuffle.rx.tap
            .asDriver()
            .debounce(.milliseconds(500))
            .drive(onNext: {[weak self] _ in
                guard let self = self else {return}
                if UserDefaults.getPremiumUser(){
                    if let songShuffle = self.songs?.shuffled(), songShuffle.count > 0{
                        MusicPlayer.showMiniPlayer(tabBarController: self.tabBarController, indexPath: IndexPath(row: 0, section: 0), songs: songShuffle, tbv: self.tbv)
                    }
                    
                }
                else{
                    self.showPremium()
                }
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        
      
    }
    
    
    override func clickLeft(sender: UIButton) {
        self.dismissVC()
    }
    
    
    @objc func didDeleteSong(_ sender:Notification){
        if let song = sender.object as? Song{
            if let index = songs?.firstIndex(where: {$0.id == song.id }){
                songs?.remove(at: index)
                tbv.reloadData()
            }
        }
    }
    
    
}
extension DetailPlayListVC:UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return songs?.count ?? 0
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tbv.dequeueReusableCell(withIdentifier: CellDetailPlayList.defaultIdentifier, for: indexPath) as! CellDetailPlayList
        
        if let song = songs?[indexPath.row]{
            cell.bindData(song: song)
            cell.delegate = self
        }
        
        switch indexPath.item {
        case 0:
            cell.lineTop.isHidden = false
        default:
            cell.lineTop.isHidden = true
        }
        
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        guard let self = self else {return}
        guard  let song = self.songs?[indexPath.row] else {
            return
        }
        self.indexPath = indexPath
        if UserDefaults.getPremiumUser(){
            MusicPlayer.showMiniPlayer(tabBarController: self.tabBarController, indexPath: indexPath, songs: [song], tbv: self.tbv)
            
        }
        else{
            
            if interstitial != nil {
                if MusicPlayer.instance.onlinePlay{
                    MusicPlayer.clickPlay.accept(.pause)
                }
                interstitial?.present(fromRootViewController: self)
              } else {
                if UserDefaults.getTapMusic().count >= 1{
                    self.showPremium()
                }
                else{
                    var arr =  UserDefaults.getTapMusic()
                    arr.append("1")
                    UserDefaults.setTapMusic(didTap: arr)
                    
                    MusicPlayer.showMiniPlayer(tabBarController: self.tabBarController, indexPath: indexPath, songs: [song], tbv: self.tbv)
                }
              }
            
            
        }
        
       
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 55
        
    }
    
    
}
extension DetailPlayListVC:ActionCellDetailPlayListProtocol{
    func didTapDownload(_ cell: CellDetailPlayList) {
        if let indexPath = tbv.indexPath(for: cell){
            
            if UserDefaults.getPremiumUser(){
                let song = songs?[indexPath.row]
                let songsCore = CoreDataManger.shared.getListSongOff()
                if let urlString = song?.filename?.queryURL, let url = URL(string: urlString){
                    
                    let alert = UIAlertController(title: "Download", message: "Select download", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "To Ringtone", style: .default, handler: { _ in
                        if url.absoluteString.contains("http"){
                            self.downloadAndConvert(url: url, cell: cell)
                        }else{
                            cell.btnDownload.progressAnimation(value: 5)
                            ConvertRingtone.convertAudio(name: url.deletingPathExtension().lastPathComponent, url: url) { _ in
                                cell.btnDownload.removeProgressLayer()
                                cell.btnDownload.setImage(#imageLiteral(resourceName: "downloadSongIc"), for: .normal)
                            }
                        }
      
                    }))
                    if songsCore.count > 0{
                        
                        let songCore = songsCore.filter {$0.id == song?.id}.first
                        if songCore?.id == song?.id{
                            
                            
                        }else{
                            alert.addAction(UIAlertAction(title: "To Downloaded", style: .default, handler: { _ in
                                self.saveToDownloaded(song: song, url: url, cell: cell)
                            }))
                            
                        }
                    }else{
                        
                        alert.addAction(UIAlertAction(title: "To Downloaded", style: .default, handler: { _ in
                            self.saveToDownloaded(song: song, url: url, cell: cell)
                        }))
                    }
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else{
                self.showPremium()
            }
        }
    }
    func downloadAndConvert(url:URL, cell:CellDetailPlayList){
        cell.btnDownload.setImage(#imageLiteral(resourceName: "downloading"), for: .normal)
        APICategoryHome.downloadMusic(url: url) { pro in
            cell.btnDownload.progressAnimation(value: pro)
            cell.btnDownload.isEnabled = false
        } completion: {[weak self] urlL in
            ConvertRingtone.convertAudio(name: cell.lbName.text ?? "" , url: urlL) { _ in
                cell.btnDownload.removeProgressLayer()
                cell.btnDownload.setImage(#imageLiteral(resourceName: "downloadSongIc"), for: .normal)
                cell.btnDownload.isEnabled = true
                NotificationCenter.default.post(Notification.init(name: Notification.Name.init("DidRingToneDownloadSuccess")))
            }
            
            
        } fail: { err in
            cell.btnDownload.removeProgressLayer()
            cell.btnDownload.setImage(#imageLiteral(resourceName: "downloadSongIc"), for: .normal)
            cell.btnDownload.isEnabled = true
        }
    }
    
    
    func saveToDownloaded(song:Song?, url:URL, cell:CellDetailPlayList){
        
        guard let song = song else {
            return
        }
        cell.btnDownload.setImage(#imageLiteral(resourceName: "downloading"), for: .normal)
        APICategoryHome.downloadMusic(url: url) { pro in
            cell.btnDownload.isEnabled = false
            cell.btnDownload.progressAnimation(value: pro)
        } completion: {[weak self] urlL in
            
            guard let self = self else {return}
            CoreDataManger.shared.saveSongOffline(id: "\(song.id ?? 0)", image: cell.imvSong.image?.pngData(), name: song.name ?? "", artist: song.artist ?? "", album: song.album, filename: url.lastPathComponent, filesize: nil, duration: nil, idPlaylist: "\(song.id_playlist ?? 0)", type: nil) {
                cell.btnDownload.isEnabled = true
                cell.btnDownload.removeProgressLayer()
                cell.btnDownload.setImage(#imageLiteral(resourceName: "downloadSongIc"), for: .normal)
                NotificationCenter.default.post(Notification.init(name: Notification.Name.init("DidDownloadSuccess")))
                
            } failure: { arr in
                cell.btnDownload.removeProgressLayer()
                cell.btnDownload.setImage(#imageLiteral(resourceName: "downloadSongIc"), for: .normal)
                cell.btnDownload.isEnabled = true
                print("Asdasdasdasdasd")
            }
            
        } fail: { err in
            cell.btnDownload.removeProgressLayer()
            cell.btnDownload.setImage(#imageLiteral(resourceName: "downloadSongIc"), for: .normal)
            cell.btnDownload.isEnabled = true
        }
    }
    
}
extension DetailPlayListVC: GADFullScreenContentDelegate{
    /// Tells the delegate that the ad failed to present full screen content.
      func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        if UserDefaults.getTapMusic().count >= 1{
            self.showPremium()
        }
        else{
            var arr =  UserDefaults.getTapMusic()
            arr.append("1")
            UserDefaults.setTapMusic(didTap: arr)
            guard let indexPath = indexPath, let song = songs?[indexPath.row] else {return}
            MusicPlayer.showMiniPlayer(tabBarController: self.tabBarController, indexPath: indexPath, songs: [song], tbv: self.tbv)
        }
      }


      /// Tells the delegate that the ad presented full screen content.
      func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
      }

      /// Tells the delegate that the ad dismissed full screen content.
      func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if UserDefaults.getTapMusic().count >= 1{
            self.showPremium()
        }
        else{
            var arr =  UserDefaults.getTapMusic()
            arr.append("1")
            UserDefaults.setTapMusic(didTap: arr)
            guard let indexPath = indexPath, let song = songs?[indexPath.row] else {return}
            MusicPlayer.showMiniPlayer(tabBarController: self.tabBarController, indexPath: indexPath, songs: [song], tbv: self.tbv)
        }
        interstitial = nil
      }
}
