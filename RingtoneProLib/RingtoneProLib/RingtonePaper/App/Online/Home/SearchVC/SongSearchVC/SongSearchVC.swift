//
//  SongSearchVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/27/21.
//

import UIKit



class SongSearchVC: BaseViewControllers {
    @IBOutlet weak var tbv: UITableView!
    
    
    var songs:[Song] = []{
        didSet{
            tbv.reloadData()
        }
    }
    
    
    var hidenKeyBroad:(()->Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        // Do any additional setup after loading the view.
    }


    func setupUI(){
        tbv.delegate = self
        tbv.dataSource = self
        tbv.register(CellDetailPlayList.self)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hidenKeyBroad?()
    }
    
    

}
extension SongSearchVC:UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return songs.count
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tbv.dequeueReusableCell(withIdentifier: CellDetailPlayList.defaultIdentifier, for: indexPath) as! CellDetailPlayList
        
        
        
       let song = songs[indexPath.row]
        cell.bindData(song: song)
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
        
        if UserDefaults.getPremiumUser(){
            
            let song = songs[indexPath.item]
            
            MusicPlayer.showMiniPlayer(tabBarController: self.tabBarController, indexPath: indexPath, songs: [song], tbv: tbv)
            
        }
        else{
            self.showPremium()
        }
        
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 55
        
    }
    
    
}
extension SongSearchVC:ActionCellDetailPlayListProtocol{
    func didTapDownload(_ cell: CellDetailPlayList) {
        if let indexPath = tbv.indexPath(for: cell){
            
            if UserDefaults.getPremiumUser(){
                let song = songs[indexPath.row]
                let songsCore = CoreDataManger.shared.getListSongOff()
                if let urlString = song.filename?.queryURL, let url = URL(string: urlString){
                    
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
                        
                        let songCore = songsCore.filter {$0.id == song.id}.first
                        if songCore?.id == song.id{
                            
                            
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
            ConvertRingtone.convertAudio(name: cell.lbName.text ?? "", url: urlL) { _ in
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
