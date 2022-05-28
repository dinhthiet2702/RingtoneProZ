//
//  CategoryModel.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/19/21.
//

import Foundation
import CoreData


//Get Home

struct BaseCategoryModel:Codable {
    
    var data: [CategoryModel]?
    var statusCode: Int?
    var statusMessage: String?
    
    
}

struct BaseGenresModel: Codable {
    
    var data: [CategoryModel]?
    var statusCode: Int?
    var statusMessage: String?
    
}

struct CategoryModel:Codable {
    
    var id: Int?
    var name: String?
    var playlists: [PlayList]?
    var image:String?

    
}




//Playlist


struct BasePlayListModel:Codable {
    
    var data: [PlayList]?
    var statusCode: Int?
    var statusMessage: String?
    
    
}

class PlayList:Codable {
    
    var details: String?
    var id: Int?
    var id_category: Int?
    var id_genres: Int?
    var image: String?
    var name: String?
    var imageOff:Data?
    var songs: [Song]?
    
}

//Song

struct BaseSongModel:Codable {
    var data: [Song]?
    var statusCode: Int?
    var statusMessage: String?
}

class Song: Codable {
    
    var album: String?
    var artist: String?
    var duration: Float?
    var filename: String?
    var filesize: String?
    var id: Int?
    var id_playlist: Int?
    var image: String?
    var name: String?
    var type: String?
    var imageOff:Data?
    
    
}
