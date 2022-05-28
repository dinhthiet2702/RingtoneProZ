//
//  DropboxCell.swift
//  AudiConverter
//
//  Created by vinova on 4/19/21.
//

import UIKit


class DropboxCell: UITableViewCell {
    
    var listImageView: UIImageView = UIImageView()
    var fileName: UILabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(listImageView)
        self.contentView.addSubview(fileName)
        contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fileName.textColor = .black
        listImageView.frame = CGRect(x: 15, y: 10, width: 30, height: 30)
        fileName.frame = CGRect(x: (listImageView.frame.origin.x + listImageView.frame.size.width + 10), y: 10, width: UIScreen.main.bounds.size.width-65, height: 30)
    }
    
    func bindImage(image:UIImage?){
        
        listImageView.image = image?.withRenderingMode(.alwaysTemplate)
        
    }
    
}
