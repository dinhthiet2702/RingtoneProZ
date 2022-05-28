//
//  HeaderHome.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/2/21.
//

import UIKit


protocol SearchHomeDelegate:class {
    func beginSearch()
}

class HeaderHome: BaseViewXib {

   
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var lbTitle: UILabel!
    
    weak var delegate:SearchHomeDelegate?
    
    override func setUpViews() {
        
        

        configureSearch()
        
//        view?.addBottomBorderWithColor(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), width: 0.5)
        
    }
    func configureSearch() {
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search by song, artist..."
        searchBar.showsCancelButton = false
        
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            
            searchField.frame = CGRect(x: 0, y: 0, width: searchBar.frame.width, height: 44)
            searchField.layer.cornerRadius = 22
            searchField.clipsToBounds = true
            searchField.textColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.3)
            searchField.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
            searchField.font = UIFont(name: "SFUIText-Regular", size: 14)
        }
        
    }
    
    @IBAction func clickRight(_ sender: Any) {
    }
    
    
}

extension HeaderHome:UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        delegate?.beginSearch()
        searchBar.endEditing(true)
    }
    
}
