//
//  SplashScreenVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/29/21.
//

import UIKit

struct VideoSPlash{
    var url:URL
    var title:String
}

class SplashScreenVC: BaseViewControllers {

    @IBOutlet weak var clv: UICollectionView!
    
    @IBOutlet weak var btnContinue: UIButton!
    
    var listVideo:[VideoSPlash] = []{
        didSet{
            clv.reloadData()
        }
    }
    
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        // Do any additional setup after loading the view.
    }


    func setupUI(){
        let pathVideo1 = Bundle.main.path(forResource: "1", ofType: "mp4")
        let pathVideo2 = Bundle.main.path(forResource: "2", ofType: "mp4")
        let pathVideo3 = Bundle.main.path(forResource: "3", ofType: "mp4")
        
        let url1 = URL(fileURLWithPath: pathVideo1 ?? "")
        let url2 = URL(fileURLWithPath: pathVideo2 ?? "")
        let url3 = URL(fileURLWithPath: pathVideo3 ?? "")
        
        listVideo = [
            VideoSPlash(url: url1, title: "RINGTONE STORE, THE MOST TRENDING TIKTOK SONGS UPDATED REGULARLY"),
            VideoSPlash(url: url2, title: "DECORATIVE WALLPAPER STOCK FOR YOUR CALL"),
            VideoSPlash(url: url3, title: "DESIGN RINGTONES IN YOUR STYLE"),
        ]
        btnContinue.layer.cornerRadius = 25
        clv.delegate = self
        clv.dataSource = self
        clv.register(UINib(nibName: "CellSplash", bundle: nil), forCellWithReuseIdentifier: CellSplash.description())
        
    }
    @IBAction func clickContinue(_ sender: Any) {
        index += 1

        
        if index >= listVideo.count{
            index = listVideo.count-1
            
            
            self.showPremium(flagVC: .tabbar)
            
            
            
        }
        else{
            clv.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        index = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        
        
    }
    
}
extension SplashScreenVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return listVideo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = clv.dequeueReusableCell(withReuseIdentifier: CellSplash.description(), for: indexPath) as! CellSplash
        
        cell.bindData(videoSplash: listVideo[indexPath.item])
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? CellSplash{
            cell.videoNode.muted = true
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
