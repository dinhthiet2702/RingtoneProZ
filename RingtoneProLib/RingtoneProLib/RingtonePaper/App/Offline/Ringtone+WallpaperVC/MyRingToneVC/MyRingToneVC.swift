//
//  MyRingToneVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/3/21.
//

import UIKit

class MyRingToneVC: BaseViewControllers {
    
    @IBOutlet weak var viewEmty: UIView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var tbv: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
   
    
    @IBOutlet weak var btnImport: UIButton!
    
    var ringTones:[RingtoneModel] = []
    
    var listSearch:[RingtoneModel] = []{
        didSet{
            DispatchQueue.main.async {
                
                if self.ringTones.count <= 0{
                    self.searchBar.isHidden = true
                    self.tbv.isHidden = true
                    self.viewEmty.isHidden = false
                    self.viewHeader.isHidden = true
                }
                else{
                    self.searchBar.isHidden = false
                    self.tbv.isHidden = false
                    self.viewEmty.isHidden = true
                    self.viewHeader.isHidden = false
                }
                self.tbv.reloadData()
            }
        }
    }
    
    
    var urlConverted:[URL] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        checkFileAdd()
        loadFileLocal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didDownload), name: NSNotification.Name.init(rawValue: "DidRingToneDownloadSuccess"), object: nil)
        
    }
    
    @objc func didDownload(){
        loadFileLocal()
    }
    
    func setupUI(){
        configureSearch()
        
        tbv.delegate = self
        tbv.dataSource = self
        tbv.register(UINib(nibName: "CellRingtone", bundle: nil), forCellReuseIdentifier: CellRingtone.description())
        btnImport.layer.cornerRadius = 24
        self.viewHeader.addBottomBorderWithColor(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), width: 0.5)
        loadFileLocal()
        
        tbv.estimatedRowHeight = 197
        
    }
    
    
    func loadFileLocal(){
        ringTones = []
        ManagerFile.shared.getMyRingtones().forEach { url in
            let ringtone = RingtoneModel(url: url, date: url.dateCreate, nameOriginal: url.originalFileName ?? "", duration: url.getDuration(), type: url.typeExtension ?? "mp3", size: url.getSizeVideo())
            ringTones.append(ringtone)
        }
        
        
        
        listSearch = ringTones
       
    }
    
    
    @IBAction func clickImport(_ sender: Any) {
        let addVC = AddMediaVC()
        addVC.index = 0
        addVC.delegate = self
        addVC.modalPresentationStyle = .fullScreen
        self.presentVC(addVC)
        
    }
    
    @IBAction func clickDeleteText(_ sender: Any) {
        searchBar.text = nil
    }
    
    func configureSearch() {
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
       
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            
            searchField.frame = CGRect(x: 0, y: 0, width: searchBar.frame.width, height: 60)
            searchField.layer.cornerRadius = 22
            searchField.clipsToBounds = true
            searchField.textColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.3)
            searchField.backgroundColor =  #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
            searchField.font = UIFont(name: "SFUIText-Regular", size: 14)
        }
        
    }
}
extension MyRingToneVC:UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listSearch.count
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tbv.dequeueReusableCell(withIdentifier: CellRingtone.description(), for: indexPath) as! CellRingtone
        let ringtone = listSearch[indexPath.row]
        
        cell.bindData(ringtone:ringtone)
        cell.delegate = self
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? CellRingtone{
            let ringTone = listSearch[indexPath.item]
            if cell.isSelectedCell == false{
                cell.setSelected(true, animated: true)
                MusicPlayer.instance.initURLRingtone(url: ringTone.url.absoluteString)
                if MusicPlayer.instance.onlinePlay{
                    MusicPlayer.clickPlay.accept(.pause)
                }
                
                cell.isSelectedCell = true
                tabBarController?.dismissPopupBar(animated: true, completion: nil)
                
                
                
            }
            else{
                cell.setSelected(false, animated: true)
                tbv.visibleCells.forEach { cell in
                    if let cell = cell as? CellRingtone{
                        cell.isSelectedCell = false
                    }
                }
                tbv.reloadData()
                if let controller = MusicPlayer.controller, controller.song != nil{
                    tabBarController?.presentPopupBar(withContentViewController: controller, animated: true, completion: nil)
                }
                
            }
            
            tbv.performBatchUpdates(nil, completion: nil)
            
        }
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
    
    
}




extension MyRingToneVC:ActionRingtoneDelegate{
    func clickDropDown(cell: CellRingtone) {
        
    }
    
    func didFinishTime(cell: CellRingtone) {
        cell.timer = nil
        cell.timer?.invalidate()
        
    }
    
    func renameAction(cell: CellRingtone) {
        
        
        
        if let indexPath = tbv.indexPath(for: cell){
            var ringtone = listSearch[indexPath.row]
            
            
            let alert = UIAlertController(title: "Rename", message: "Enter your name!", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "New name"
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in}))
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                
                if let name = alert?.textFields?.first?.text {
                    if name.count != 0, !name.isReallyEmpty{
                        var rv = URLResourceValues()
                        rv.name = "\(name).\(ringtone.type)"
                        try? ringtone.url.setResourceValues(rv)
                    }
                    
                        
                    
                    DispatchQueue.main.async {
                        self.loadFileLocal()
                    }
                    
                }
                
               
               
            }))
            
            
            self.present(alert, animated: true, completion: nil)
            
        }
       
    }
    
    func trimAction(cell: CellRingtone) {
        
        if let indexPath = tbv.indexPath(for: cell){
            let ringtone = listSearch[indexPath.row]
            let trimmingVC = BaseNavVC(rootViewController: TrimmingVC(ringtone: ringtone))
            trimmingVC.modalPresentationStyle = .fullScreen
            self.present(trimmingVC, animated: true, completion: nil)
            cell.setSelected(false, animated: true)
            tbv.performBatchUpdates(nil, completion: nil)
            if let controller = MusicPlayer.controller, controller.song != nil{
                tabBarController?.presentPopupBar(withContentViewController: controller, animated: true, completion: nil)
            }
           
        }
       
    }
    
    func setAsAction(cell: CellRingtone) {
        
        if UserDefaults.getOnlineAPP(){
            if UserDefaults.getPremiumUser(){
                if let indexPath = tbv.indexPath(for: cell){
                    let ringtone = listSearch[indexPath.row]
                    let setRingVC = SetRingtoneGrand(linkShare: ringtone.url)
                    self.present(setRingVC, animated: true, completion: nil)
                    
                }
            }
            else{
                self.showPremium()
            }
        }
        else{
            if let indexPath = tbv.indexPath(for: cell){
                let ringtone = listSearch[indexPath.row]
                let setRingVC = SetRingtoneGrand(linkShare: ringtone.url)
                self.present(setRingVC, animated: true, completion: nil)
            }
        }
        
        
        
    }
    
    func moreAction(cell: CellRingtone) {
        if let indexPath = tbv.indexPath(for: cell){
            let ringtone = listSearch[indexPath.row]
            let alert = UIAlertController(title: "More", message: "Choose action!", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { _ in
                let activityViewController = UIActivityViewController(activityItems: [ringtone.url], applicationActivities: nil)
                if let popoverController = activityViewController.popoverPresentationController {
                     popoverController.sourceView = cell
                     popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                }
                
                // Show the share-view
                self.present(activityViewController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak self] _ in
                guard let self = self else {return}
                
                let alertShow = UIAlertController(title: "Delete", message: "Do you want delete file?", preferredStyle: .alert)
                alertShow.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    ManagerFile.shared.removeItem(url: ringtone.url) {
                        
                        
                        if let index = self.ringTones.firstIndex(where: {$0.url == ringtone.url}){
                            self.ringTones.remove(at: index)
                            self.listSearch = self.ringTones
                           
                            MusicPlayer.instance.pause()
                        }
                    }
                }))
                alertShow.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alertShow, animated: true, completion: nil)
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            if let popoverController = alert.popoverPresentationController {
                 popoverController.sourceView = cell
                 
            }
            
            self.present(alert, animated: true, completion: nil)
        }
       
    }
}

extension MyRingToneVC:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            listSearch = ringTones
        }
        else{
                        
            listSearch = ringTones.filter{$0.nameOriginal.range(of: searchText, options: .caseInsensitive) != nil}
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
       
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
}
extension MyRingToneVC:DidGotoLibary{
    func didGotoLibary(_ url: [URL]) {
        self.urlConverted = url
    }
    
    
}

