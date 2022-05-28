//
//  CellImport.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/10/21.
//

import UIKit

class CellImport: UICollectionViewCell {
    @IBOutlet weak var imv: UIImageView!
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var viewContent: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        // Initialization code
    }
    
    
    func setupUI(){
        viewContent.layer.cornerRadius = 30
        viewContent.clipsToBounds = true
        
    }
    
    func bindData(addModel:AddModel){
        imv.image = addModel.image
        lbName.text = addModel.name
        viewContent.backgroundColor = addModel.color
    }

}
