//
//  CompletionConvertVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/16/21.
//

import UIKit



class CompletionConvertVC: UIViewController {

    @IBOutlet var btnView: [UIButton]!
    
    @IBOutlet weak var lbConvert: UILabel!
    var didGotoLibary: (()->Void)? = nil
    
    var count = 0

    init() {
        super.init(nibName: "CompletionConvertVC", bundle: BundleProvider.bundle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        btnView.forEach { btn in
            btn.layer.cornerRadius = 25
            btn.clipsToBounds = true
        }
        
        lbConvert.text = "Converted \(count) videos to ringtones"
        
    }


    @IBAction func clickContinue(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func clickDismiss(_ sender: Any) {
        
        self.dismiss(animated: true, completion: {
            if self.didGotoLibary != nil{
                self.didGotoLibary!()
            }
        })
        
    }
    
}
