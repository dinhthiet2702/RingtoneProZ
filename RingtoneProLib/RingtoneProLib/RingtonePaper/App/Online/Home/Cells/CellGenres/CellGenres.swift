//
//  CellHome.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/2/21.
//

import UIKit


class CellGenres: UITableViewCell, Reusable {

    @IBOutlet weak var clvGenres: UICollectionView!
    
    
    var genresList:[CategoryModel] = []{
        didSet{
            self.clvGenres.reloadData()
        }
    }
    
    
    
    
    weak var delegate:ActionClickItemHomeDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

        
        setupUI()
        // Initialization code
    }
    
    
    
    func setupUI(){
        clvGenres.delegate = self
        clvGenres.dataSource = self
        clvGenres.register(CellHomeItem.self)
        clvGenres.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        
    }
    
    func bindDataGenres(genres:[CategoryModel]){
        self.genresList = genres
 
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
    
}

extension CellGenres:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return genresList.count
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = clvGenres.dequeueReusableCell(withReuseIdentifier: CellHomeItem.defaultIdentifier, for: indexPath) as! CellHomeItem
        let genre = genresList[indexPath.item]
        cell.bindDataGenres(genres: genre)
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didClickGenres(genresList[indexPath.item])
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            return CGSize(width: UIScreen.main.bounds.width/3 - 30, height: 350)
        }else{
            return CGSize(width: UIScreen.main.bounds.width/2 - 30, height: 200)
        }
       
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
   
    
}
