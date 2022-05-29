//
//  AddMediaVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/10/21.
//

import UIKit
import YPImagePicker
import Photos
import MobileCoreServices


protocol DidGotoLibary: AnyObject {
    func didGotoLibary(_ url:[URL])
}

class AddMediaVC: BaseViewControllers {
    @IBOutlet weak var clv: UICollectionView!
    
    var index = 0
    
    @IBOutlet weak var segementAdd: SegementAdd!
    
    
    var baseAdd:[AddModel] = []{
        didSet{
            clv.reloadData()
        }
    }
    weak var delegate:DidGotoLibary?
    
    var urlTransformIsAudio = true
    
    var ringtoneAdds:[AddModel] = [
        AddModel(name: "From Video", image: ImageProvider.image(named: "video"), color: #colorLiteral(red: 0.4274509804, green: 0.4431372549, blue: 1, alpha: 0.2)),
        AddModel(name: "Wifi Transfer", image: ImageProvider.image(named: "wifi"), color: #colorLiteral(red: 0.368627451, green: 0.6862745098, blue: 1, alpha: 0.2)),
        AddModel(name: "Drop box", image: ImageProvider.image(named: "dropbox"), color: #colorLiteral(red: 0.06274509804, green: 0.8039215686, blue: 0.4901960784, alpha: 0.2)),
        AddModel(name: "File Browser", image: ImageProvider.image(named: "file"), color: #colorLiteral(red: 0.368627451, green: 0.5568627451, blue: 1, alpha: 0.2))
    ]
    
    var wallPaperAdds:[AddModel] = [
        AddModel(name: "Import Image", image: ImageProvider.image(named: "imageI"), color: #colorLiteral(red: 0.4274509804, green: 0.4431372549, blue: 1, alpha: 0.2)),
        AddModel(name: "Create Live Wallpaper", image: ImageProvider.image(named: "liveA"), color: #colorLiteral(red: 1, green: 0.537254902, blue: 0.4274509804, alpha: 0.2))
        
    ]

    init() {
        super.init(nibName: "AddMediaVC", bundle: BundleProvider.bundle)
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
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(statusUpdate), name: NSNotification.Name(rawValue: "Dropboxlistrefresh"), object: nil)
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    
   
    
    func setupUI(){
        segementAdd.items = ["Ringtones", "Wallpapers"]
        segementAdd.font = UIFont(name: "SF-Pro-Text-Bold", size: 15)
        segementAdd.borderColor = .clear
        segementAdd.selectedLabelColor = .white
        segementAdd.unselectedLabelColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.3)
        segementAdd.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.03)
        segementAdd.thumbColor = #colorLiteral(red: 0.06274509804, green: 0.8039215686, blue: 0.4901960784, alpha: 1)
        segementAdd.selectedIndex = index
        
        segementAdd.addTarget(self, action: #selector(segmentValueChanged(_:)), for: .valueChanged)
        clv.delegate = self
        clv.dataSource = self
        clv.register(UINib(nibName: "CellImport", bundle: nil), forCellWithReuseIdentifier: CellImport.description())
        switch index {
        case 0:
            baseAdd = ringtoneAdds
        default:
            baseAdd = wallPaperAdds
        }
    }

    @objc func statusUpdate(notification:Notification){
        let ab = DBListFileVC()
        
        ab.delegate = self
        ab.showDropboxData()
//        let navRoot = UINavigationController(rootViewController: ab)
        self.pushVC(ab)
    }
    
    @objc func segmentValueChanged(_ sender:SegementAdd){
        switch sender.selectedIndex {
        case 0:
            baseAdd = ringtoneAdds
        default:
            baseAdd = wallPaperAdds
        }
        
        
    }
    
    
    @IBAction func clickDismiss(_ sender: Any) {
        self.dismissVC()
        
    }
    
}
extension AddMediaVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return baseAdd.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = clv.dequeueReusableCell(withReuseIdentifier: CellImport.description(), for: indexPath) as! CellImport
        
        
        let addModel = baseAdd[indexPath.item]
        
        cell.bindData(addModel: addModel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch segementAdd.selectedIndex {
        case 0:
            switch indexPath.item {
            case 0:
                addVideoToLib { listURL in
                    let convertVC = ConverImportVC(arrURL: listURL)
                    convertVC.delegate = self
                    self.present(convertVC, animated: true, completion: nil)
                }
            case 1:
                let mgr = SGWiFiUploadManager.shared()
                let success = mgr?.startHTTPServer(atPort: 8080) ?? false
                if success {
                    mgr?.setFileUploadStartCallback({ (fileName, savePath) in
                        print("File \(fileName ?? "") Upload Start")
                    })
                    
                    mgr?.setFileUploadProgressCallback({ (fileName, savePath, progress) in
                        print("File \(fileName ?? "") on progress \(progress)")
                    })
                    mgr?.setFileUploadFinishCallback({ (fileName, savePath) in
                        if let path = savePath{
                            let url = URL(fileURLWithPath: path)
                            if url.containsAudio || url.containsVideo || url.containsQuickTime{
                                ConvertRingtone.convertAudio(name: url.originalFileName ?? "", url: url) { urlL in
                                    self.dismissVC()
                                    
                                }
                            }
                            else{
                                try? FileManager.default.removeFileIfNecessary(at: url)
                                self.urlTransformIsAudio = false
                                
                            }
                            
                        }
                    })
                }
                mgr?.showWiFiPageFrontViewController(self, dismiss: {
                    mgr?.stopHTTPServer()
                    
                    if !self.urlTransformIsAudio{
                        let aler = UIAlertController(title: "Error", message: "File is not audio or video", preferredStyle: .alert)
                        
                        aler.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(aler, animated: true, completion: nil)
                    }
                })
            case 2:
                
                if UserDefaults.getPremiumUser(){
                    DropboxManager.loginDropBox(controller: self) {
                        return
                    }
                }
                else{
                    self.showPremium()
                }
                
            
            default:
                clickCloud()
            }
        default:
           
            switch indexPath.item {
            case 0:
                didClickAddImage()
                
            default:
                didClickAddVideoWallPaper()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 2 - 30
        return CGSize(width: width, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
}

//MARK: -add Ringtone


extension AddMediaVC{
    func clickCloud(){
        let types = [kUTTypeAudio, kUTTypeVideo, kUTTypeMovie]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
}


//MARK: -Add paper

extension AddMediaVC{
    
    
    
    func didClickAddImage(){
        var countOunt = 0
        addImageToLib { listURL in
            listURL.forEach { url in
                ManagerFile.shared.moveWallpaperImage(urlImageLive: url) { url in
                    DispatchQueue.main.async {
                        
                        DispatchQueue.main.async {
                            if countOunt == listURL.count{
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                        countOunt += 1
                    }
                } error: {
                    return
                }
            }
        }
    }
    
    func didClickAddVideoWallPaper(){
        var countOunt = 0
        addVideoToLib { listURL in
            listURL.forEach { url in
                ManagerFile.shared.moveWallpaperImage(urlImageLive: url) { _ in
                    
                    DispatchQueue.main.async {
                        if countOunt == listURL.count{
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    countOunt += 1
                } error: {
                    return
                }
            }
        }
    }
    
    
    
    fileprivate func addVideoToLib( completion: @escaping (_ listURL:[URL])->Void){
        var config = YPImagePickerConfiguration()
        config.screens = [.library, .video]
        config.library.mediaType = .video
        config.hidesStatusBar = false
        config.library.maxNumberOfItems = 5
        config.video.compression = AVAssetExportPresetHighestQuality
        config.video.fileType = .mp4
        config.video.minimumTimeLimit = 1.0
        config.video.libraryTimeLimit = 3600.0
        config.overlayView = nil
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if !cancelled {
                var arrURLVideo:[URL] = []
                for item in items {
                    switch item {
                    case .photo(let photo):
                        print(photo)
                    case .video(let video):
                        
                        arrURLVideo.append(video.url)
                        
                    }
                }
                picker.dismiss(animated: true, completion: {
                    completion(arrURLVideo)
                })
                
                
            }
            else{
                picker.dismiss(animated: true, completion: nil)
            }
           
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    
    fileprivate func addImageToLib(completion: @escaping (_ listURL:[URL])->Void){
        var config = YPImagePickerConfiguration()
        config.screens = [.library]
        config.library.mediaType = .photo
        config.hidesStatusBar = false
        config.library.maxNumberOfItems = 5
        config.overlayView = nil
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if !cancelled {
                var arrURLImage:[URL] = []
                for item in items {
                    switch item {
                    case .photo(let photo):
                        
                        let image = photo.originalImage
                        if let url = image.pngData()?.dataToFile(fileName: "\(Date().timeIntervalSince1970).png"){
                            arrURLImage.append(url)
                        }
                        else{
                            completion([])
                            break
                        }
                            
                        
                    case .video(let video):
                        print(video)
                    }
                }
                picker.dismiss(animated: true, completion: nil)
                completion(arrURLImage)
                
            }
            else{
                picker.dismiss(animated: true, completion: nil)
                completion([])
            }
            
        }
        
        present(picker, animated: true, completion: nil)
    }
}
extension AddMediaVC:UIDocumentPickerDelegate,UINavigationControllerDelegate{
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let urlAt = urls.first else {
            return
        }
        
        let convertVC = ConverImportVC(arrURL: [urlAt])
        convertVC.delegate = self
        self.present(convertVC, animated: true, completion: nil)
        
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
extension AddMediaVC:DidConverSuccess{
    func didConvertSuccess(urls: [URL]) {
        let completionVC = CompletionConvertVC()
        
        completionVC.count = urls.count
        completionVC.didGotoLibary = { [weak self] in
            self?.delegate?.didGotoLibary(urls)
            self?.dismiss(animated: true, completion: nil)
        }
        
        self.present(completionVC, animated: true, completion: nil)
    }
    

    
    
}
extension AddMediaVC:SelectedDropboxData{
    func getDropboxSelectedData(_ url:URL) {
        self.dismiss(animated: true, completion: nil)
    }
}


