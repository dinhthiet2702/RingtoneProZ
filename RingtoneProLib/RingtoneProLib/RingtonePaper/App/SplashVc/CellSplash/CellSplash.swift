//
//  CellSplash.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/29/21.
//

import UIKit
import AsyncDisplayKit
import AVKit

class CellSplash: UICollectionViewCell {
    
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var viewVideo: UIView!
    var mainNode = ASDisplayNode()
    var videoNode = ASVideoNode()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func bindData(videoSplash:VideoSPlash){
        
        
        DispatchQueue.main.async {
            
            self.videoNode.asset = AVAsset(url: videoSplash.url)
            self.videoNode.frame = self.contentView.bounds
            self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            self.videoNode.shouldAutoplay = true
            self.videoNode.shouldAutorepeat = true
            self.videoNode.muted = false
            
            
            DispatchQueue.main.async {
                self.mainNode.addSubnode(self.videoNode)
                self.viewVideo.addSubview(self.mainNode.view)
                self.lbTitle.text = videoSplash.title
                
            }
        }
    }
    
}
