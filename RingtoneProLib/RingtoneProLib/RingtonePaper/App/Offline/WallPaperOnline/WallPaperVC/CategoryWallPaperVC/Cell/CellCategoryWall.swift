//
//  CellCategoryWall.swift
//  RingtonesNew
//
//  Created by vinova on 4/28/21.
//

import UIKit
import SDWebImage

class CellCategoryWall: UICollectionViewCell {


    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var imv: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        setupUI()
        // Initialization code
    }
    
    
    func setupUI(){
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
    }
    
    
    func bindData(category:CategoryWallpaper?){
        
        if let category = category{
            
            lbTitle.text = category.title
            if let image = category.image, let url = URL(string: image){
                imv.sd_imageIndicator =  SDWebImageActivityIndicator.gray
                imv.sd_setImage(with: url, completed: nil)
            }
            
            
        }
        
    }

}
