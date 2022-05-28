//
//  WallpaperModel.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/11/21.
//

import Foundation



struct WallpaperBase : Codable {
    
    let data : [CategoryWallpaper]?
    let date : String?
    let error : Bool?
    
    
    
}


struct CategoryWallpaper : Codable {
    
    let id : Int?
    let image : String?
    let title : String?
    
    
}


struct CategoryWallpagerLive : Codable {
    
    let data : [WallpaperLive]?
    let date : String?
    let error : Bool?
    
}


struct WallpaperLive : Codable {
    
    let id : Int?
    let original : String?
    let resolution : String?
    let size : String?
    let thumbnail : String?
    let title : String?

}
