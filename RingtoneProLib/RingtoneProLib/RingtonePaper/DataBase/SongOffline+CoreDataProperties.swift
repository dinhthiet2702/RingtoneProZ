//
//  SongOffline+CoreDataProperties.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/23/21.
//
//

import Foundation
import CoreData


extension SongOffline {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SongOffline> {
        return NSFetchRequest<SongOffline>(entityName: "SongOffline")
    }

    @NSManaged public var album: String?
    @NSManaged public var artist: String?
    @NSManaged public var duration: String?
    @NSManaged public var filename: String?
    @NSManaged public var id: String?
    @NSManaged public var filesize: String?
    @NSManaged public var id_playlist: String?
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var type: String?

    func mapData() -> Song{
        let song = Song()
        song.album = self.album
        song.artist = self.artist
        song.filesize = self.filesize
        if let idString  = self.id, let id = Int(idString){
            song.id = id
        }
        if let idStringList  = self.id_playlist, let idPlayList = Int(idStringList){
            song.id_playlist = idPlayList
        }
        song.filename = self.filename?.queryURL
        song.imageOff = self.image
        song.name = self.name
        song.type = self.type
        
        return song
        
        
    }
    
}
