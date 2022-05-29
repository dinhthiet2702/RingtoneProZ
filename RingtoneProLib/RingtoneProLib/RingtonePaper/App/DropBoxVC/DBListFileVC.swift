//
//  DBListFileVC.swift
//  AudiConverter
//
//  Created by vinova on 4/18/21.
//

import UIKit
import SwiftyDropbox
import PKHUD
import MobileCoreServices
import UniformTypeIdentifiers


enum DetectFile{
    case video
    case audio
    case document
    case text
    case image
    case web
    case pression
}



protocol SelectedDropboxData:class {
    func getDropboxSelectedData(_ url:URL)
}

class DBListFileVC: BaseViewControllers, UISearchBarDelegate {
    
    var filesArr: [Files.Metadata] = []{
        didSet{
            tableView.reloadData()
        }
    }
    
    var filteredArr:[Files.Metadata] = []{
        didSet{
            tableView.reloadData()
        }
    }
    
    var searchActive : Bool = false
    
    weak var delegate:SelectedDropboxData?
    
    var cache:NSCache<AnyObject, AnyObject> = NSCache()
    
    var searchBar = UISearchController(searchResultsController: nil)
    
    
    lazy var tableView : UITableView = {
        let tbv = UITableView()
        tbv.delegate = self
        tbv.dataSource = self
        tbv.register(DropboxCell.self, forCellReuseIdentifier: "DropboxCell")
        tbv.translatesAutoresizingMaskIntoConstraints = false
        return tbv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    
    func setupUI(){
        view.addSubview(tableView)
        changeLeftButton(image: ImageProvider.image(named: "backTrim"))
        tableView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let logoutBarBtn = UIBarButtonItem(title:"Log Out", style:UIBarButtonItem.Style.plain, target: self, action:#selector(self.logoutBtnClicked))
        self.navigationItem.rightBarButtonItem = logoutBarBtn
        
        addSearchBar()
        setupContraint()
    }
    
    
    func setupContraint(){
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    
    // Unlink dropbox
    @objc func logoutBtnClicked(_ sender: UIBarButtonItem)  {
        // signout
        DropboxClientsManager.unlinkClients()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func clickLeft(sender: UIButton) {
        if navigationController?.viewControllers.count == 1{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    /// show dropbox data in tableview
    func showDropboxData() {
        
        DropboxManager.getNameUser { name in
            self.navigationItem.title = name
        }
        DropboxManager.getListFolder(url: "") { arr in
            self.filesArr = arr
            self.filteredArr = arr
        }
    }
    
    
    func addSearchBar(){
        self.navigationItem.searchController = searchBar
        self.searchBar.searchBar.enablesReturnKeyAutomatically = false
        searchBar.searchBar.delegate = self
    }
    
    
    func loadImage(name: String) -> UIImage? {
        let podBundle = Bundle(for: DBListFileVC.self)
        if let url = podBundle.url(forResource: "DroplightIcons", withExtension: "bundle") {
            let bundle = Bundle(url: url)
            return UIImage(named: name, in: bundle, compatibleWith: nil)
        }
        return nil
    }
    
    //MARK: UISearchbarDelegate methods
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.isEmpty == true {
            filteredArr = self.filesArr
        }else{
            filteredArr = self.filesArr.filter ({ (fileInfo) -> Bool in
                let range = fileInfo.name.range(of: searchBar.text ?? "", options: String.CompareOptions.caseInsensitive)
                if range == nil
                {
                    return false
                }
                return true
            })
        }
    }
    
    
    func detectType(namePath:String)->DetectFile{
        
        let urlImport = ManagerFile.shared.urlAudios+"/"+namePath
        
        let dataPath = URL(fileURLWithPath: urlImport)
        
        if dataPath.containsImage{
            return .image
        }else if dataPath.containsAudio{
            return .audio
        }else if dataPath.containsVideo{
            return .video
        }else if dataPath.containsDocument{
            return .document
        }else if dataPath.containsWebloc{
            return .web
        }else if dataPath.containsText{
            return .text
        }
        else {
            return .pression
        }
        
        
    }
    
}

extension DBListFileVC : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DropboxCell") as! DropboxCell
        cell = DropboxCell(style: .default, reuseIdentifier: "DropboxCell")
        
        if let image = loadImage(name: "sp_folder") {
            cell.bindImage(image:image)
        }
        
        let fileInfo = filteredArr[indexPath.row]
        
        
        
        switch detectType(namePath: filteredArr[indexPath.row].name) {
        case .audio:
            if let image = loadImage(name: "sp_page_dark_mp3"){
                cell.bindImage(image:image)
            }
        case .video:
            if let image = loadImage(name: "sp_page_dark_film"){
                cell.bindImage(image:image)
            }
        case .document:
            if let image = loadImage(name: "sp_page_dark_excel"){
                cell.bindImage(image:image)
            }
        case .image:
            if self.cache.object(forKey: fileInfo.pathLower as AnyObject) != nil {
                cell.bindImage(image: self.cache.object(forKey: fileInfo.pathLower as AnyObject) as? UIImage)
            }
            else {
                
                if let image = loadImage(name: "sp_page_dark_picture"){
                    
                    cell.bindImage(image:image)
                }
                if let client = DropboxClientsManager.authorizedClient {
                    client.files.download(path: fileInfo.pathLower!)
                        .response(completionHandler: { (file, error) in
                            if let fileInfo = file {
                                cell.bindImage(image:UIImage(data: (fileInfo.1)))
                                self.cache.setObject(cell.listImageView.image!, forKey: fileInfo.0.id as AnyObject)
                            }
                        })
                }
            }
        case .pression:
            if let image = loadImage(name: "sp_folder"){
                
                cell.bindImage(image:image)
                
            }
        case .text:
            if let image = loadImage(name: "sp_page_dark_text"){
                cell.bindImage(image:image)
            }
        case .web:
            if let image = loadImage(name: "sp_page_dark_webcode") {
                cell.bindImage(image:image)
            }
        }
        
        
        cell.fileName.text = fileInfo.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (filteredArr[indexPath.row].name as NSString).pathExtension == "" {
            
            guard let url = filteredArr[indexPath.row].pathLower else {
                return
            }
            
            DropboxManager.getListFolder(url: url) { result in
                let listFileVC = DBListFileVC()
                listFileVC.filesArr = result
                listFileVC.filteredArr = result
                listFileVC.delegate = self
                self.pushVC(listFileVC)
            }
            
        } else {
            guard let path = self.filteredArr[indexPath.row].pathLower else {
                return
            }
            DropboxManager.downloadFile(path: path, nameFile: self.filteredArr[indexPath.row].name, completion: { url in
                
                guard let url = url else {
                    self.navigationController?.popViewController(animated: true)
                    return }
                self.delegate?.getDropboxSelectedData(url)
                self.dismiss(animated: true, completion: nil)
            })
            
            
        }
    }
    
}
extension DBListFileVC:SelectedDropboxData{
    func getDropboxSelectedData(_ url:URL) {
        self.delegate?.getDropboxSelectedData(url)
    }
    
    
}
