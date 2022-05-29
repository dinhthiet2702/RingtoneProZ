//
//  BrowserLiveVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/11/21.
//

import UIKit
import PKHUD
//import Photos


enum ActionDownload:String{
    case share
    case download
    case add
}
enum FlagWallpaperVC:String{
    case myWallPaper
    case online
}


class BrowserLiveVC: BaseViewControllers {
    
    @IBOutlet weak var clvLive: UICollectionView!
    
    
    var flagVC:FlagWallpaperVC = .online
    
    var urlLive:String?
    
    var lisWallPapers:[WallpaperLive] = []{
        didSet{
            scrollToItem()
        }
    }
    
    
    var listMyWall:[MyWallpaperModel] = []{
        didSet{
            scrollToItem()
        }
    }
    
   
    
    
    init (urlLive:String?, flagBrowser:FlagWallpaperVC) {
        self.urlLive = urlLive
        self.flagVC = flagBrowser
        
        super.init(nibName: "BrowserLiveVC", bundle: BundleProvider.bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func clickDismis(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func setupUI(){
        
        clvLive.delegate = self
        clvLive.dataSource = self
        clvLive.register(UINib(nibName: "CellLive", bundle: nil), forCellWithReuseIdentifier: CellLive.description())
 
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        urlLive = nil
        lisWallPapers = []
        listMyWall = []
        
    }
    
    func scrollToItem(){
        DispatchQueue.main.async {
            self.clvLive.performBatchUpdates({
                self.clvLive.reloadData()
            }) {  _ in
                if let urlLive = self.urlLive{
                    switch self.flagVC {
                    case .online:
                        if let index = self.lisWallPapers.firstIndex(where: {$0.original == urlLive}){
                            self.clvLive.isPagingEnabled = false
                            self.clvLive.scrollToItem(at: IndexPath(item: index, section: 0), at: .right, animated: false)
                            self.clvLive.isPagingEnabled = true
                            
                        }
                    default:
                        if let index = self.listMyWall.firstIndex(where: {$0.liveImage.path == urlLive}){
                            self.clvLive.isPagingEnabled = false
                            self.clvLive.scrollToItem(at: IndexPath(item: index, section: 0), at: .right, animated: false)
                            self.clvLive.isPagingEnabled = true
                            
                        }
                    }
                }
            }
            
        }
    }
    
    
    
    
}
extension BrowserLiveVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch flagVC {
        case .online:
            return lisWallPapers.count
        default:
            return listMyWall.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = clvLive.dequeueReusableCell(withReuseIdentifier: CellLive.description(), for: indexPath) as! CellLive
        
        switch flagVC {
        case .online:
            if let link = lisWallPapers[indexPath.item].original, let url = URL(string: link){
                cell.bindData(url: url)
            }
        default:
            let link = listMyWall[indexPath.item].liveImage
            cell.bindData(url: link)
            
        }
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch flagVC {
        case .online:
            if UserDefaults.getPremiumUser(){
                return
            }else{
                if indexPath.item > 3{
                    self.showPremium()
                }
                else{
                    return
                }
            }
            
        default:
            return
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

extension BrowserLiveVC:ActionCellLiveDelegate{
    
    func didTapShare(_ cell:CellLive) {
        downloadWallpaperTool(cell, action: .share)
    }
    
    func didTapDownload(_ cell:CellLive) {
        downloadWallpaperTool(cell, action: .download)
    }
    
    func didTapAdd(_ cell:CellLive) {
        downloadWallpaperTool(cell, action: .add)
    }
    
    func didTapDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    fileprivate func downloadWallpaperTool(_ cell:CellLive, action: ActionDownload){
        
        if let indexPath = clvLive.indexPath(for: cell){
            
            switch flagVC {
            case .online:
                let wallpaper = lisWallPapers[indexPath.item]
                if let link = wallpaper.original, let url = URL(string: link){
                    
                    
                    
                    if let urlLocal =  checkfileDownload(url: url){
                        HUD.show(.progress)
                        switch action {
                        case .add:
                            ManagerFile.shared.moveWallpaperImage(urlImageLive: urlLocal) { _ in
                                cell.btnAdd.setImage(ImageProvider.image(named: "checkAdd"), for: .normal)
                                cell.btnAdd.isUserInteractionEnabled = false
                                HUD.hide()
                            } error: {
                                HUD.hide()
                            }
                        default:
                            handleActionWallpaper(cell, url: urlLocal, action: action)
                        }
                    }
                    else{
                        HUD.show(.labeledProgress(title: nil, subtitle: "Downloading..."))
                        APIWallpapers.downloadWallpaper(url: url) { _ in} completion: { data in
                            if let urlp = data.dataToFile(fileName: url.lastPathComponent){
                                
                                switch action {
                                case .add:
                                    ManagerFile.shared.moveWallpaperImage(urlImageLive: urlp) { _ in
                                        cell.btnAdd.setImage(ImageProvider.image(named: "checkAdd"), for: .normal)
                                        cell.btnAdd.isUserInteractionEnabled = false
                                        HUD.hide()
                                    } error: {
                                        HUD.hide()
                                    }
                                default:
                                    self.handleActionWallpaper(cell, url: urlp, action: action)
                                }
                            }
                            else{
                                HUD.hide()
                            }
                            
                        } fail: {err in
                            HUD.show(.labeledError(title: "Error", subtitle: err?.localizedDescription))
                            
                        }
                    }
                }
            default:
                let wallpaper = listMyWall[indexPath.item]
                HUD.show(.progress)
                handleActionWallpaper(cell, url: wallpaper.liveImage, action: action)
            }
        }
    }
    
    fileprivate func handleActionWallpaper(_ cell:CellLive, url:URL, action:ActionDownload){
        
        if url.containsImage{
            
            switch action {
            case .download:
                if let image = UIImage(contentsOfFile: url.path){
                    SaveToAlbum.shared.save(image: image) {
                        HUD.show(.labeledSuccess(title: nil, subtitle: "Success"))
                        HUD.hide(afterDelay: 1)
                    } fail: {
                        HUD.show(.labeledError(title: nil, subtitle: "Fail"))
                        HUD.hide(afterDelay: 1)
                    }

                    
                }
            case .share:
                guard let image = UIImage(contentsOfFile: url.path) else {
                    HUD.show(.labeledError(title: "Error", subtitle: "cannot found file!"))
                    HUD.hide(afterDelay: 1)
                    return
                }
                let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                    popoverController.sourceView = self.view
                    popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                }
                self.present(activityViewController, animated: true, completion: nil)
                HUD.hide()
            default:
                HUD.hide()
                return
            }
            
            
        }
        else{
            ConvertLive.generate(videoURL: url, progress: {_ in}) { live, response in
                switch action {
                case .download:
                    
                    if let urlImage = response?.pairedImage , let urlLive = response?.pairedVideo {
                        SaveToAlbum.shared.saveLivePhotoToPhotosLibrary(livePhotoURL: urlImage ,livePhotoMovieURL: urlLive) {
                            HUD.show(.labeledSuccess(title: nil, subtitle: "Success"))
                            HUD.hide(afterDelay: 1)
                            
                        } fail: { err in
                            HUD.show(.labeledError(title: "Error", subtitle: err?.localizedDescription))
                            HUD.hide(afterDelay: 1)
                        }
                    }
                    else{
                        HUD.hide()
                    }
                    
                case .share:
                    
                    guard let live = live else {
                        HUD.show(.labeledError(title: "Error", subtitle: "cannot found file!"))
                        HUD.hide(afterDelay: 1)
                        return
                    }
                    let activityViewController = UIActivityViewController(activityItems: [live], applicationActivities: nil)
                    if let popoverController = activityViewController.popoverPresentationController {
                        popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                        popoverController.sourceView = self.view
                        popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                    }
                    self.present(activityViewController, animated: true, completion: nil)
                    HUD.hide()
                    
                    
                default:
                    
                    HUD.hide()
                    return
                    
                }
            }
        }
        
    }
    
    
    fileprivate func checkfileDownload(url:URL) -> URL?{
        
        let files = ManagerFile.shared.getWallpapersDownload()
        if files.count > 0{
            for file in files{
                if file.lastPathComponent == url.lastPathComponent{
                    return file
                }
            }
        }
        
        return nil
    }
}
