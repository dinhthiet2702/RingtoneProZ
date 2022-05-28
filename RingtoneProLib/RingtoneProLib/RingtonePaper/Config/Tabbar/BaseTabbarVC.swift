//
//  BaseTabbar.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/3/21.
//

import UIKit

class BaseTabbar: UITabBarController {
    
    
    lazy var indicator: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.06274509804, green: 0.8039215686, blue: 0.4901960784, alpha: 1)
        view.frame.size = CGSize(width: UIScreen.main.bounds.width/3, height: 3)
        view.layer.cornerRadius = 1
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.addSubview(indicator)

        
        self.delegate  = self
        setUpTabbar()
        // Do any additional setup after loading the view.
    }
    
    
    func animate(index: Int) {
        let buttons = tabBar.subviews
            .filter({ String(describing: $0).contains("Button") })
        
        guard index < buttons.count else {
            return
        }
        
        let selectedButton = buttons[index]
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                let point = CGPoint(
                    x: selectedButton.center.x,
                    y: selectedButton.frame.minY+1
                )
                
                self.indicator.center = point
                
            },
            completion: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animate(index: selectedIndex)
    }
    
    
    
    
    func setUpTabbar() {
        
        
        
        let homeVC = HomeVC(nibName: "HomeVC", bundle: nil)
        homeVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "homeOl")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "homeOl-selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
        
        let navHome = BaseNavVC(rootViewController: homeVC)
        
        
        
        let libraryVC = DownloadedVC(nibName: "DownloadedVC", bundle: nil)
        libraryVC.tabBarItem =  UITabBarItem(title: "", image: UIImage(named: "ringtone")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "ringtone-selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
        
        let navlibraryVC = BaseNavVC(rootViewController: libraryVC)
        
        
        let ringtone_wallPaperVC = Ringtone_WallpaperVC(nibName: "Ringtone+WallpaperVC", bundle: nil)
        ringtone_wallPaperVC.tabBarItem =  UITabBarItem(title: "", image: UIImage(named: "home")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "home-selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
        
        let navRingtone_wallPaperVC = BaseNavVC(rootViewController: ringtone_wallPaperVC)
        
        
        
        let wallPaperVC = WallPaperVC(nibName: "WallPaperVC", bundle: nil)
        wallPaperVC.tabBarItem =  UITabBarItem(title: "", image: UIImage(named: "wallpaper")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "wallper-selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
        
        let navWallPaperVC = BaseNavVC(rootViewController: wallPaperVC)
        
        
        
        
        let moreVC = MoreVC(nibName: "MoreVC", bundle: nil)
        moreVC.tabBarItem =  UITabBarItem(title: "", image: UIImage(named: "moreVC")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "more-selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
        
        let navMoreVC = BaseNavVC(rootViewController: moreVC)
        
        
        
        
        
        
        if !UserDefaults.getOnlineAPP(){
            self.viewControllers = [navRingtone_wallPaperVC, navWallPaperVC, navMoreVC]
        }
        else{
            self.viewControllers = [navHome, navlibraryVC, navRingtone_wallPaperVC, navWallPaperVC, moreVC]
        }

        if #available(iOS 15, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = self.tabBar.standardAppearance
        }
        
        
        
        
//        UITabBar.appearance().barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension BaseTabbar: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard
            let items = tabBar.items,
            let index = items.firstIndex(of: item)
        else {
            return
        }
        
        animate(index: index)
    }
}
