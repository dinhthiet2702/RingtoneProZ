//
//  CellLive.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/11/21.
//

import UIKit
import AsyncDisplayKit
import AVKit
import SDWebImage


protocol ActionCellLiveDelegate:class {
    func didTapDismiss()
    func didTapShare(_ cell:CellLive)
    func didTapDownload(_ cell:CellLive)
    func didTapAdd(_ cell:CellLive)
}


class CellLive: UICollectionViewCell {
    
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var viewWallpaper: UIView!
    @IBOutlet weak var imvLoad: SDAnimatedImageView!
    @IBOutlet weak var btnShare: UIButton!
    var mainNode = ASDisplayNode()
    var videoNode = ASVideoNode()
    
    weak var delegate:ActionCellLiveDelegate?
    
    deinit {
        print("cell live deinit")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        // Initialization code
    }
    
    
    func setupUI(){
        btnDownload.layer.cornerRadius = 22.5
        btnDownload.clipsToBounds = true
        btnAdd.layer.cornerRadius = 24
        btnShare.layer.cornerRadius = 24
        btnAdd.clipsToBounds = true
        btnShare.clipsToBounds = true
    }
    
    func bindData(url:URL){
        
        if url.containsImage{
            imvLoad.image = UIImage(contentsOfFile: url.path)
            ManagerFile.shared.getMyWallpapers().forEach { urlLocal in
                if urlLocal.originalFileName == url.originalFileName{
                    
                    print("urlll", urlLocal, url)
                    self.btnAdd.isUserInteractionEnabled = false
                    self.btnAdd.setImage(ImageProvider.image(named: "checkAdd"), for: .normal)
                }
            }
        }
        else{
            imvLoad.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
        
            DispatchQueue.main.async {
                        
                self.videoNode.asset = AVAsset(url: url)
                self.videoNode.frame = self.contentView.bounds
                self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                self.videoNode.shouldAutoplay = true
                self.videoNode.shouldAutorepeat = true
                self.videoNode.muted = true
                
                        
                DispatchQueue.main.async {
                    self.mainNode.addSubnode(self.videoNode)
                    self.viewWallpaper.addSubview(self.mainNode.view)
                    
                    ManagerFile.shared.getMyWallpapers().forEach { urlLocal in
                        if urlLocal.originalFileName == url.originalFileName{
                            
                            print("urlll", urlLocal, url)
                            self.btnAdd.isUserInteractionEnabled = false
                            self.btnAdd.setImage(ImageProvider.image(named: "checkAdd"), for: .normal)
                        }
                    }
                    
                }
            }
        }
        
        
        
        
    }
    
    
    @IBAction func clickShare(_ sender: Any) {
        delegate?.didTapShare(self)
    }
    @IBAction func clickAddLib(_ sender: UIButton) {
        delegate?.didTapAdd(self)
    }
    
    @IBAction func clickDownload(_ sender: Any) {
        delegate?.didTapDownload(self)
    }
    @IBAction func tapDismiss(_ sender: Any) {
        self.delegate?.didTapDismiss()
    }
    
    
}
