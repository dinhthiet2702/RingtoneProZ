//
//  SaveRingToneVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/10/21.
//

import UIKit

class SaveRingToneVC: BaseViewControllers {

    @IBOutlet var btnScreen: [UIButton]!
    @IBOutlet weak var spaceBottom: NSLayoutConstraint!
    
    @IBOutlet weak var tfNameRingtone: UITextField!
    
    var ringtone:RingtoneModel?
    var startTime:Double?
    var endTime:Double?
    
    init(ringtone:RingtoneModel?, startTime:Double?, endTime:Double?) {
        self.ringtone = ringtone
        self.startTime = startTime
        self.endTime = endTime
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI(){
        btnScreen.forEach { btn in
            btn.layer.cornerRadius = 25
            btn.clipsToBounds = true
        }
        
        if let ringtone = ringtone{
            tfNameRingtone.text = ringtone.nameOriginal
        }
    }


    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification ,
                                                  object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardRectValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardRectValue.height
            UIView.animate(withDuration: 0.4) {
                self.spaceBottom.constant = keyboardHeight
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
       
        UIView.animate(withDuration: 0.4) {
            self.spaceBottom.constant = 10
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func clickDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func clickOnlySave(_ sender: Any) {
        guard let ringtone = self.ringtone, let name = tfNameRingtone.text, let startTime = startTime, let endTime = endTime else { return }
        
        ConvertRingtone.convertAudio(name: name, url: ringtone.url, startTime: startTime, endTime: endTime) { url in
            DispatchQueue.main.async {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let windowApp = appDelegate.window else { return }
                //---
                let tabbarVC = BaseTabbar()
                if !UserDefaults.getOnlineAPP(){
                    tabbarVC.selectedIndex = 0
                    tabbarVC.animate(index: 0)
                }else{
                    tabbarVC.selectedIndex = 2
                    tabbarVC.animate(index: 2)
                }
                windowApp.rootViewController = tabbarVC
                windowApp.makeKeyAndVisible()
            }
        }
        
    }
    @IBAction func clickSaveSet(_ sender: Any) {
        
        if UserDefaults.getOnlineAPP(){
            if UserDefaults.getPremiumUser(){
                guard let ringtone = self.ringtone, let name = tfNameRingtone.text, let startTime = startTime, let endTime = endTime else { return }
                
                ConvertRingtone.convertAudio(name: name, url: ringtone.url, startTime: startTime, endTime: endTime) { url in
                    DispatchQueue.main.async {
                        
                       let moveVC = SetRingtoneGrand(linkShare: url)
                        
                        self.present(moveVC, animated: true, completion: nil)
                    }
                }
            }
            else{
                self.showPremium()
            }
        }
        else{
            guard let ringtone = self.ringtone, let name = tfNameRingtone.text, let startTime = startTime, let endTime = endTime else { return }
            
            ConvertRingtone.convertAudio(name: name, url: ringtone.url, startTime: startTime, endTime: endTime) { url in
                DispatchQueue.main.async {
                    
                   let moveVC = SetRingtoneGrand(linkShare: url)
                    
                    self.present(moveVC, animated: true, completion: nil)
                }
            }
        }
        
        
        
        
        
        

    }
    
   

}
