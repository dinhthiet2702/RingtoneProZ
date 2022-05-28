//
//  SendRecommendVC.swift
//  RingtonesNew
//
//  Created by thiet on 6/19/21.
//

import UIKit
import MessageUI
import PKHUD

class SendRecommendVC: BaseViewControllers {

   
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var heightTbv: NSLayoutConstraint!
    @IBOutlet weak var tbv: UITableView!
    
   
    
    var playList:PlayList?{
        didSet{
            self.listSearch = playList?.songs ?? []
        }
    }
    
    var listSearch:[Song] = []{
        didSet{
            tbv.reloadData()
        }
    }
    var isCategory = false
    init(playList:PlayList, isCategory:Bool = false) {
        self.playList = playList
        self.isCategory = isCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
    }
    
    
    func setupUI(){
        tbv.register(CellDetailPlayList.self)
        tbv.delegate = self
        tbv.dataSource = self
        btnSend.layer.cornerRadius = 24
        configureSearch()
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action:#selector(tap))
        tapGestureReconizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureReconizer)
        self.listSearch = playList?.songs ?? []
    }
    
    @objc override func tap(){
        searchBar.endEditing(true)
    }
    
    
    func configureSearch() {
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search..."
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            
            searchField.frame = CGRect(x: 0, y: 0, width: searchBar.frame.width, height: 40)
            searchField.layer.cornerRadius = 20
            searchField.clipsToBounds = true
            searchField.textColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.3)
            searchField.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        }
        
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["htcorpcompany@gmail.com"])
            mail.setMessageBody("<p>I need to provide this song in the app:\n</p>", isHTML: true)

            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }

   
    
    
    
  
    
  
    
    @IBAction func clickLeft(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        heightTbv.constant = CGFloat(listSearch.count)*55
    }
    


    @IBAction func clickPlay(_ sender: Any) {
        if UserDefaults.getPremiumUser(){
            sendEmail()
        }else{
            showPremium()
        }
        
    }
    

}
extension SendRecommendVC:UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return listSearch.count
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tbv.dequeueReusableCell(withIdentifier: CellDetailPlayList.defaultIdentifier, for: indexPath) as! CellDetailPlayList
        
        let song = listSearch[indexPath.row]
        cell.bindData(song: song)
        cell.delegate = self
        
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        searchBar.endEditing(true)
        MusicPlayer.showMiniPlayer(tabBarController: self.tabBarController, indexPath: indexPath, songs: [listSearch[indexPath.row]], tbv: tbv)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 55
        
    }
    
    
}
extension SendRecommendVC:UISearchBarDelegate{
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            listSearch = playList?.songs ?? []
        }else{
            listSearch = playList?.songs?.filter {
                return $0.name?.range(of: searchText, options: .caseInsensitive) != nil
            } ?? []
        }
        
    }
    
    
    
}

extension SendRecommendVC:MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
extension SendRecommendVC:ActionCellDetailPlayListProtocol{
    func didTapDownload(_ cell: CellDetailPlayList) {
        if let indexPath = tbv.indexPath(for: cell){
            
            if UserDefaults.getPremiumUser(){
                let song = listSearch[indexPath.row]
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
