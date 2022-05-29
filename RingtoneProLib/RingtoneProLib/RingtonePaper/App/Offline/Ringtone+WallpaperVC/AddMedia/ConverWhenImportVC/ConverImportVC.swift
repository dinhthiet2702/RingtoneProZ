//
//  ConverImportVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/16/21.
//

import UIKit

protocol DidConverSuccess:class {
    func didConvertSuccess(urls:[URL])
}

class ConverImportVC: UIViewController {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lbConvert: UILabel!
    
    var arrURL:[URL]?
    
    
    weak var delegate:DidConverSuccess?
    
    
    init(arrURL:[URL]?) {
        self.arrURL = arrURL
        super.init(nibName: "ConverImportVC", bundle: BundleProvider.bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
        convert()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       
    }
    
    
    func convert(){
        
        
        if let arrURL = arrURL{
            indicator.startAnimating()
            
            var urlConverts:[URL] = []
            arrURL.forEach { url in
                
                let index = arrURL.firstIndex(of: url)
                
                lbConvert.text = "Converting \(index!+1)/\(arrURL.count) to Ringtone"
                
                ConvertRingtone.convertAudio(name: url.originalFileName ?? "", url: url) { urlCOnvert in
                    
                    if index!+1 >= arrURL.count{
                        self.indicator.stopAnimating()
                        
                        self.dismiss(animated: true, completion: {
                            arrURL.forEach { urlDe in
                                ManagerFile.shared.removeItem(url: urlDe) {
                                    
                                }
                            }
                            self.delegate?.didConvertSuccess(urls: urlConverts)
                            
                        })
                    }
                    urlConverts.append(urlCOnvert)
                }
            }
            
            
        }
        
        
    }
    
    
    func setupUI(){
        btnCancel.layer.cornerRadius = 25
        btnCancel.clipsToBounds = true
    }
    
    
    @IBAction func clickCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
