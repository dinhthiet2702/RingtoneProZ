//
//  Cell_Essential_Item.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/17/21.
//

import UIKit
import SDWebImage


class CellHomeItem: UICollectionViewCell, Reusable {

    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var lbSub: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var imvPlaylist: UIImageView!
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        // Initialization code
    }

    func setupUI(){
//        clipsToBounds = true
        layer.cornerRadius = 10
        viewShadow.layer.cornerRadius = 10
        imvPlaylist.layer.cornerRadius = 6
        imvPlaylist.clipsToBounds = true
        viewShadow.dropShadow(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), opacity: 0.5, offSet: CGSize(width: 1, height: 10))
    }
    

    
    func bindDataHome(playlist:PlayList){
        
        if let image = playlist.image?.queryURL, let url = URL(string: image){
            
            imvPlaylist.sd_imageIndicator =  SDWebImageActivityIndicator.gray
            imvPlaylist.sd_setImage(with: url) { (img, err, _, _) in
                if err != nil{
                    self.imvPlaylist.image = ImageProvider.image(named: "songdefault")
                }
                
            }
        }
        lbTitle.text = playlist.name
        lbSub.text = playlist.details
        
    }
    func bindDataGenres(genres:CategoryModel){
        
        if let image = genres.image?.queryURL, let url = URL(string: image){
            
            imvPlaylist.sd_imageIndicator =  SDWebImageActivityIndicator.gray
            imvPlaylist.sd_setImage(with: url) { (img, err, _, _) in
                if err != nil{
                    self.imvPlaylist.image = ImageProvider.image(named: "songdefault")
                }
                
            }
        }
        lbTitle.text = genres.name?.uppercased()
        lbSub.isHidden = true
        
    }
    
    
}
