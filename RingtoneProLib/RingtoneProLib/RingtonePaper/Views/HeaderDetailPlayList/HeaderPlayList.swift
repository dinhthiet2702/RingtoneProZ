//
//  HeaderPlayList.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/18/21.
//

import UIKit



class HeaderPlayList: BaseViewXib {
    
    
    @IBOutlet weak var lbTitle: UILabel!
    
    
    var clickDismiss: (() -> Void)? = nil
    
    override func setUpViews() {
        
    }
    @IBAction func clickDismiss(_ sender: Any) {
        guard let clickDismiss = clickDismiss else {
            return
        }
        clickDismiss()
    }
    
    
}
