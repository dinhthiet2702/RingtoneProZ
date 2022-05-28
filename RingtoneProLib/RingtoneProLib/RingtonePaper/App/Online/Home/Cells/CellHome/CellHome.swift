//
//  CellHome.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/2/21.
//

import UIKit


protocol ActionClickItemHomeDelegate:class {
    func didClickItemPlayList(_ playList: PlayList?, _ cell: CellHome)
    func didClickGenres(_ genres:CategoryModel?)
}

enum FlagCellHome:String{
    case playlist
    case recommend
}


class CellHome: UITableViewCell, Reusable {

    @IBOutlet weak var clvHome: UICollectionView!
    
    
    
    var playLists:[PlayList] = []{
        didSet{
            clvHome.reloadData()
        }
    }
    
    var flagCell:FlagCellHome = .playlist
    
    weak var delegate:ActionClickItemHomeDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

        
        setupUI()
        // Initialization code
    }
    
    
    
    func setupUI(){
        clvHome.delegate = self
        clvHome.dataSource = self
        clvHome.register(CellHomeItem.self)
        
    }
    
    func bindDataCate(playLists:[PlayList], flagCell:FlagCellHome = .playlist){
        self.playLists = playLists
        self.flagCell = flagCell
        
        switch flagCell {
        case .recommend:
            clvHome.isScrollEnabled = false
            clvHome.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            clvHome.isScrollEnabled = true
            clvHome.contentInset = UIEdgeInsets(top: 20, left: 12, bottom: 20, right: 10)
        }
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
    
}

extension CellHome:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playLists.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = clvHome.dequeueReusableCell(withReuseIdentifier: CellHomeItem.defaultIdentifier, for: indexPath) as! CellHomeItem
        let playlist = playLists[indexPath.item]
        cell.bindDataHome(playlist: playlist)
        switch flagCell {
        case .recommend:
            cell.lbSub.isHidden = true
            cell.lbTitle.isHidden = true
        default:
            cell.lbSub.isHidden = false
            cell.lbTitle.isHidden = false
        }
        return cell
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    
        self.delegate?.didClickItemPlayList(playLists[indexPath.item], self)
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch flagCell {
        case .recommend:
            return CGSize(width: UIScreen.main.bounds.width - 30, height: 220)
        default:
            return CGSize(width: 160, height: 250)
        }
        
        
        
    }
    

    
    
}
