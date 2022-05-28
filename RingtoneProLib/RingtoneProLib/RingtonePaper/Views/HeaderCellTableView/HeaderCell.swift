//
//  HeaderCell.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/2/21.
//

import UIKit




class HeaderCell: BaseViewXib {
    
    @IBOutlet weak var btnSeeAll: UIButton!
    
    var didClickSeeAll:(()->Void?)? = nil
    
    @IBOutlet weak var titleHeader: UILabel!
    
    
    
    @IBAction func clickSeeAll(_ sender: Any) {
        guard let didClickSeeAll = didClickSeeAll else {return}
        didClickSeeAll()
    }
    
}
