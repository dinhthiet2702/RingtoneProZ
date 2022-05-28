//
//  DownloadedVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/18/21.
//

import UIKit
import GoogleMobileAds

class DownloadedVC: BaseViewControllers {
    
    @IBOutlet weak var viewEmpty: UIView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var tbv: UITableView!
    @IBOutlet var btnScreen: [UIButton]!
    @IBOutlet weak var btnDownload: UIButton!
    
    var songs:[Song] = []{
        didSet{
            if songs.count > 0{
                tbv.isHidden = false
                viewEmpty.isHidden = true
            }else{
                tbv.isHidden = true
                viewEmpty.isHidden = false
            }
            tbv.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavibar(isHide: true)
        getListSong()
        
        bannerView.isHidden = UserDefaults.getPremiumUser()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didDownload), name: NSNotification.Name.init(rawValue: "DidDownloadSuccess"), object: nil)
        
    }
    
    @objc func didDownload(){
        getListSong()
    }
    
    func getListSong(){
        var songsOffline:[Song] = []
        
        CoreDataManger.shared.getListSongOff().forEach { song in
            if let path = song.filename{
                song.filename = URL(fileURLWithPath: ManagerFile.shared.urlAudioDownloaded+"/"+path).absoluteString
                songsOffline.append(song)
            }
        }
        songsOffline = songsOffline.reversed()
        songs = songsOffline
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideNavibar(isHide: false)
        
    }
    
    
    func setupUI(){
        btnScreen.forEach { btn in
            btn.layer.cornerRadius = 22.5
            btn.clipsToBounds = true
        }
        btnDownload.layer.cornerRadius = 23
        tbv.delegate = self
        tbv.dataSource = self
        tbv.register(CellDetailPlayList.self)
        setupADSBanner(bannerView: self.bannerView)
        
        
    }
    
    override func didPurchaseSucces() {
        hideBannerView(bannerView: bannerView)
    }
    
    @IBAction func clickPlay(_ sender: Any) {
        if songs.count > 0{
            
            MusicPlayer.showMiniPlayer(tabBarController: self.tabBarController, indexPath: IndexPath(row: 0, section: 0), songs: songs, tbv: tbv)
        }
    }
    @IBAction func clickShuffle(_ sender: Any) {
        
        let songShuffle = songs.shuffled()
        if songShuffle.count > 0{
            MusicPlayer.showMiniPlayer(tabBarController: self.tabBarController, indexPath: IndexPath(row: 0, section: 0), songs: songShuffle, tbv: tbv)
        }
    }
    
    
    
    @IBAction func clickDownload(_ sender: Any) {
        if let tabbar = tabBarController as? BaseTabbar{
            
            tabbar.selectedIndex = 0
            tabbar.animate(index: 0)
           
        }
    }
    
}

extension DownloadedVC:UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return songs.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tbv.dequeueReusableCell(withIdentifier: CellDetailPlayList.defaultIdentifier, for: indexPath) as! CellDetailPlayList
        
        let song = songs[indexPath.row]
        cell.bindDataOffline(song: song)
        cell.delegate = self
        
        switch indexPath.item {
        case 0:
            cell.lineTop.isHidden = false
        default:
            cell.lineTop.isHidden = true
        }
        
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        let song = songs[indexPath.row]
        
        MusicPlayer.showMiniPlayer(tabBarController: self.tabBarController, indexPath: indexPath, songs: [song], tbv: tbv)
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 55
        
    }
    
    
}

extension DownloadedVC:ActionCellDetailPlayListProtocol{
    func didTapDownload(_ cell: CellDetailPlayList) {
        if let indexPath = tbv.indexPath(for: cell){
            if let id =  songs[indexPath.row].id{
                let alert = UIAlertController(title: "Delete", message: "Do you want delete song?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    CoreDataManger.shared.deleteSong(id: "\(id)") {
                        self.getListSong()
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
    }
    
    
}
