//
//  SearchVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/3/21.
//

import UIKit

class SearchVC: BaseViewControllers {
    
    @IBOutlet weak var segeControl: UISegmentedControl!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var contentView: UIView!
    
    
    var indexLast = 0
    let songVC = SongSearchVC()
    let playListVC = PlayListVC(arrPlayList: nil)
    
    
    var songs:[Song] = []{
        didSet{
            self.songs = songs.filterDuplicates(includeElement: {$0.name == $1.name})
            songVC.songs = self.songs
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        setupUI()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    
    func setupUI(){
        
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search by song, artist..."
        searchBar.showsCancelButton = false
        searchBar.becomeFirstResponder()
        songVC.hidenKeyBroad = {
            self.searchBar.endEditing(true)
        }
        playListVC.hidenKeyBroad = {
            self.searchBar.endEditing(true)
        }
        
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            
            searchField.frame = CGRect(x: 0, y: 0, width: searchBar.frame.width, height: 44)
            searchField.layer.cornerRadius = 22
            searchField.clipsToBounds = true
            searchField.textColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.3)
            searchField.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
            searchField.font = UIFont(name: "SFUIText-Regular", size: 14)
        }
        changeLeftButton(image: #imageLiteral(resourceName: "backTrim"))
        navigationItem.title = "Search"
        segeControl.addUnderlineForSelectedSegment(heightLine: 3)
        updateView()
        
    }
    
    
    @IBAction func changeSegement(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.3) {
            self.segeControl.changeUnderlinePosition()
        }
        updateView()
    }
    

    override func clickLeft(sender: UIButton) {
        self.popViewController()
    }
    
    
    private func add(asChildViewController viewController: UIViewController) {
        
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        contentView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = contentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    //----------------------------------------------------------------
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
    private func updateView() {
    
        let index = segeControl.selectedSegmentIndex
        
        switch index {
        case 0:
            
            remove(asChildViewController: playListVC)
            add(asChildViewController: songVC)

            if indexLast > index{
                songVC.view.swipeLeft()
            }
            else{
                songVC.view.swipeRight()
            }
        
        default:
            remove(asChildViewController: songVC)
            add(asChildViewController: playListVC)

            if indexLast > index{
                playListVC.clv.swipeLeft()
            }
            else{
                playListVC.clv.swipeRight()
            }
        }
        
        
        indexLast = index
    }
    
    
    
}
extension SearchVC:UISearchBarDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.popViewController()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.songs = []
        
        APICategoryHome.searchSongByName(name: searchText, page: 0) { model in
            self.songs.append(contentsOf: model?.data ?? [])
        } fail: { err in
            
        }
        
        APICategoryHome.searchSongByArtis(name: searchText, page: 0) { model in
            self.songs.append(contentsOf: model?.data ?? [])
        } fail: { err in
            
        }
        
        APICategoryHome.searchPlayListByName(name: searchText, page: 0) { model in
            self.playListVC.arrPlayList = model?.data
        } fail: { err in
            
        }
        
        


    }
    
    
}
