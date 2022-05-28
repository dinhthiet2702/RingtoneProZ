//
//  Cell_Item_Paper.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/2/21.
//

import UIKit
import SDWebImage

class Cell_Item_Paper: UICollectionViewCell {

    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var iconLive: UIImageView!
    @IBOutlet weak var imv: UIImageView!
    var didDelete:(()->Void)? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCellUI()
        // Initialization code
    }

    
    
    func setupCellUI(){
        
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
    }
    
    func bindDataMyWall(image:UIImage){
        imv.image = image
    }
    
    func bindData(url:URL) {
        imv.sd_imageIndicator =  SDWebImageActivityIndicator.gray
        imv.sd_setImage(with: url, completed: nil)
    }
    @IBAction func clickDelete(_ sender: Any) {
        
        didDelete?()
        
    }
}
