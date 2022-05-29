//
//  SetRingtoneGrand.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/10/21.
//

import UIKit
import AVKit

class SetRingtoneGrand: UIViewController {
    @IBOutlet weak var txtDescription: UITextView!
    
    @IBOutlet var btnScreens: [UIButton]!
    
    var linkShare:URL?
    
    init(linkShare:URL?) {
        self.linkShare = linkShare
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
        
        
        btnScreens.forEach { btn in
            btn.layer.cornerRadius = 25
            btn.clipsToBounds = true
        }
        
        
        let attributedString = NSMutableAttributedString(string: "Garage Band app is requires to set ringtone, is you don’t have this app just Download Garage Band to continue   If you have downloaded it, press Move to Garage Band then select Share to Garage\n Band on Share Popup after this screen  If you have trouble, See Tutorial here or see later Settings 􀆊 Help & Support", attributes: [
          .font: UIFont.systemFont(ofSize: 15.0, weight: .regular),
          .foregroundColor: UIColor(white: 0.0, alpha: 1.0),
          .kern: -0.24
        ])
        attributedString.setAsLink(textToFind: "Download Garage Band", linkURL:  "https://apps.apple.com/us/app/garageband/id408709785")
        
        attributedString.addAttribute(.link, value: "OK", range: NSRange(location: 253, length: 13))
        
        txtDescription.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.green]
        
        txtDescription.dataDetectorTypes = [.link]
        txtDescription.attributedText = attributedString
        txtDescription.textAlignment = .center
        txtDescription.delegate = self
    }
    
    @IBAction func clickMoveGrand(_ sender: UIButton) {
        
        if let linkShare = linkShare{
            
            ShareAudio.sharedGarageband(audio: linkShare, nameProject: linkShare.originalFileName ?? "") { url, name in
                if let url = url{
                    let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    if let popoverController = activityViewController.popoverPresentationController {
                         popoverController.sourceView = sender
                         popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                    }
                    activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                        if completed{
                            DispatchQueue.main.async {
                                guard let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first else { return }
                                //---
                                let tabbarVC = BaseTabbar()
                                if !UserDefaults.getOnlineAPP(){
                                    tabbarVC.selectedIndex = 0
                                    tabbarVC.animate(index: 0)
                                }else{
                                    tabbarVC.selectedIndex = 2
                                    tabbarVC.animate(index: 2)
                                }
                                
                                window.rootViewController = tabbarVC
                            }
                        }
                    }
                    
                    // Show the share-view
                    self.present(activityViewController, animated: true, completion: nil)
                }
                
            }
            
        }
        
    }
    @IBAction func clickLate(_ sender: Any) {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first else { return }
            //---
            let tabbarVC = BaseTabbar()
            tabbarVC.selectedIndex = 0
            window.rootViewController = tabbarVC
        }
    }
    

}
extension SetRingtoneGrand:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if characterRange == NSRange(location: 253, length: 13) {
            self.playView()
        } else {
            UIApplication.shared.open(URL)
        }
            
        return false
    }
    
    func playView() {
        guard let path = Bundle.main.path(forResource: "tutorial", ofType:"mp4") else {
            debugPrint("tutorial.mov not found")
            return
        }
        
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.present(playerController, animated: true) {
            player.play()
        }
    }
}
