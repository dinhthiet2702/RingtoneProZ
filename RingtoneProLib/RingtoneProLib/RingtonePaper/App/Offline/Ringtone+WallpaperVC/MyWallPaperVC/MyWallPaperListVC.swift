//
//  MyWallPaperListVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/3/21.
//

import UIKit

class MyWallPaperListVC: UIViewController {
    
    @IBOutlet weak var segeMent: SegementAdd!
    @IBOutlet weak var viewEmty: UIView!
    
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var clv: UICollectionView!
    
    var index = 0
    
    var listLiveBase:[MyWallpaperModel] = []{
        didSet{
            DispatchQueue.main.async {
                if self.listLiveBase.count <= 0{
                    
                    self.clv.isHidden = true
                    self.viewEmty.isHidden = false
                    
                }
                else{
                    
                    self.clv.isHidden = false
                    self.viewEmty.isHidden = true
                    
                }
                self.clv.reloadData()
            }
        }
    }
    
    var listLive:[MyWallpaperModel] = []
    var listStill:[MyWallpaperModel] = []
    
    
    var listMyWallPapers:[MyWallpaperModel] = []{
        didSet{
            listLive = listMyWallPapers.filter({$0.liveImage.containsVideo})
            listStill = listMyWallPapers.filter({$0.liveImage.containsImage})
            
            if index == 0{
                self.listLiveBase = listLive
            }else{
                self.listLiveBase = listStill
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if ManagerFile.shared.getMyWallpapers().count != listMyWallPapers.count {
            fetchMyWallpaper()
//        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    
    
    func setupUI(){
        fetchMyWallpaper()
        segeMent.items = ["Live", "Still"]
        segeMent.font = UIFont(name: "SF-Pro-Text-Bold", size: 15)
        segeMent.borderColor = .clear
        segeMent.selectedLabelColor = .white
        segeMent.unselectedLabelColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.3)
        segeMent.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.03)
        segeMent.thumbColor = #colorLiteral(red: 0.06274509804, green: 0.8039215686, blue: 0.4901960784, alpha: 1)
        segeMent.addTarget(self, action: #selector(segmentValueChanged(_:)), for: .valueChanged)
        clv.delegate = self
        clv.dataSource = self
        clv.register(UINib(nibName: "Cell_Item_Paper", bundle: nil), forCellWithReuseIdentifier: Cell_Item_Paper.description())
        
        
        clv.contentInset = UIEdgeInsets(top: 20, left: 16, bottom: 10, right: 16)
        
        btnDownload.layer.cornerRadius = 24
        if listMyWallPapers.count <= 0{
            
            clv.isHidden = true
            viewEmty.isHidden = false
            
        }
        else{
            
            clv.isHidden = false
            viewEmty.isHidden = true
            
        }
        
        
    }
    
    @objc func segmentValueChanged(_ sender:SegementAdd){
        switch sender.selectedIndex {
        case 0:
            index = 0
            self.listLiveBase = listLive
        default:
            index  = 1
            self.listLiveBase = listStill
        }
        
        
    }
    
    func fetchMyWallpaper(){
        var list:[MyWallpaperModel] = []
        ManagerFile.shared.getMyWallpapers().forEach { url in
            
            if url.containsImage{
                var image = UIImage(contentsOfFile: url.path)
                image = image?.resized(toWidth: 200)
                let wall = MyWallpaperModel(imageThumb: image!, liveImage: url, dateCreate: url.dateCreate)
                list.append(wall)
            }
            else{
                let image = ManagerFile.shared.thumbImageVideo(url: url)
                let wall = MyWallpaperModel(imageThumb: image ?? UIImage(), liveImage: url, dateCreate: url.dateCreate)
                list.append(wall)
            }
            
            
        }
        
        list = list.sorted(by: { s1, s2 -> Bool in
            return s1.dateCreate > s2.dateCreate
        })
        
        self.listMyWallPapers = list
    }

    @IBAction func clickDownload(_ sender: Any) {
        
        if let tabbar = tabBarController as? BaseTabbar{
            if !UserDefaults.getOnlineAPP(){
                tabbar.selectedIndex = 1
                tabbar.animate(index: 1)
            }else{
                tabbar.selectedIndex = 3
                tabbar.animate(index: 3)
            }
           
        }
       
    }
    

}
extension MyWallPaperListVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listLiveBase.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = clv.dequeueReusableCell(withReuseIdentifier: Cell_Item_Paper.description(), for: indexPath) as! Cell_Item_Paper
        let wall = listLiveBase[indexPath.item]
        if wall.liveImage.containsImage{
            cell.iconLive.isHidden = true
        }
        else{
            cell.iconLive.isHidden = false
        }
        cell.bindDataMyWall(image: wall.imageThumb)
        cell.btnDelete.isHidden = false
        
        cell.didDelete = { [weak self] in
            
            let alert = UIAlertController(title: "Delete", message: "Do you want delete file?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                ManagerFile.shared.removeItem(url: wall.liveImage) {
                    self?.listLiveBase.remove(at: indexPath.item)
                    
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self?.present(alert, animated: true, completion: nil)
            
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentImage = listLiveBase[indexPath.item]
        
        let link = currentImage.liveImage.path
        print("link", link)
        let browserVC = BrowserLiveVC(urlLive: link, flagBrowser: .myWallPaper)
        browserVC.listMyWall = listLiveBase
        browserVC.modalPresentationStyle = .fullScreen
        self.present(browserVC, animated: true, completion: nil)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 2 - 30

        return CGSize(width: width, height: width*1.5)
    }
    
    
    
}

