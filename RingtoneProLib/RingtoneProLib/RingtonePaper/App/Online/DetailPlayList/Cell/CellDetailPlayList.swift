//
//  CellDetailPlayList.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/18/21.
//

import UIKit
import SDWebImage


protocol ActionCellDetailPlayListProtocol:class {
    func didTapDownload(_ cell:CellDetailPlayList)
}

class CellDetailPlayList: UITableViewCell, Reusable {
    @IBOutlet weak var imvSong: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var lineTop: UIView!
    @IBOutlet weak var lbSub: UILabel!
    
    weak var delegate:ActionCellDetailPlayListProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imvSong.layer.cornerRadius = 3
        
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindData(song:Song){
        if let image = song.image?.queryURL, let url = URL(string: image){
            imvSong.sd_imageIndicator =  SDWebImageActivityIndicator.gray
            imvSong.sd_setImage(with: url) { (imv, err, _, _) in
                if err != nil{
                    self.imvSong.image = ImageProvider.image(named: "songdefault")
                }
                
            }
        }
        else{
            imvSong.image = ImageProvider.image(named: "songdefault")
        }
        
        lbName.text = song.name
        lbSub.text = song.artist
    }
    
    func bindDataOffline(song:Song){
        if let imageData = song.imageOff, let image = UIImage(data: imageData){
            imvSong.image = image
            
        }else{
            imvSong.image = ImageProvider.image(named: "songdefault")
        }
        
        lbName.text = song.name
        lbSub.text = song.artist
        btnDownload.setImage(ImageProvider.image(named: "deleteF"), for: .normal)
    }
    
    
    
    
    
    
    @IBAction func btnDownload(_ sender: Any) {
        delegate?.didTapDownload(self)
        
    }
    
}
