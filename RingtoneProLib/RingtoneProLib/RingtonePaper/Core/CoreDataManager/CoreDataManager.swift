//
//  CoreDataManager.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/23/21.
//

import Foundation
import CoreData
import UIKit


public class CoreDataManger:NSObject {
    public static let shared = CoreDataManger()
    public var persistentContainer: NSPersistentContainer?
    
    
    
    func getListSongOff() -> [Song]{
        var listSong:[SongOffline] = []
        var songs:[Song] = []
        guard let persistentContainer = persistentContainer else { return [] }
        
        let managedContext = persistentContainer.viewContext
        
        
        do {
            listSong = try managedContext.fetch(SongOffline.fetchRequest())
            
            listSong.forEach { song in
                songs.append(song.mapData())
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
        return songs
        
        
    }
    
    
    
    func deleteSong(id:String, completion:@escaping ()->Void){
        guard let persistentContainer = persistentContainer else { return }

        let managedContext = persistentContainer.viewContext
        
        var listSong:[SongOffline] = []
        
        do {
            listSong = try managedContext.fetch(SongOffline.fetchRequest())
            
            listSong.forEach { songCore in
                if songCore.id == id{
                    managedContext.delete(songCore)
                }
            }
            
            try managedContext.save()
            completion()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    
    
    func saveSongOffline(id:String?,
                         image:Data?,
                         name:String?,
                         artist:String?,
                         album:String?,
                         filename:String?,
                         filesize:String?,
                         duration:String?,
                         idPlaylist:String?,
                         type:String?, completion: @escaping () ->Void, failure: @escaping (_ error:NSError?) -> Void) {
        
        
        if let idString = id, let idInt = Int(idString){
            let index = getListSongOff().firstIndex { song -> Bool in
                return song.id ?? 0 == idInt
            }
            if index != nil{
                return
            }else{
                guard let persistentContainer = persistentContainer else { return }

                let managedContext = persistentContainer.viewContext
                
                // 2
                guard let entity = NSEntityDescription.entity(forEntityName: "SongOffline",
                                                              in: managedContext) else { return }
                
                let songCoreData = SongOffline(entity: entity, insertInto: managedContext)
                
                // 3
                songCoreData.setValue(id, forKey: "id")
                songCoreData.setValue(image, forKey: "image")
                songCoreData.setValue(name, forKey: "name")
                songCoreData.setValue(artist, forKey: "artist")
                songCoreData.setValue(album, forKey: "album")
                songCoreData.setValue(filename, forKey: "filename")
                songCoreData.setValue(filesize, forKey: "filesize")
                songCoreData.setValue(duration, forKey: "duration")
                songCoreData.setValue(idPlaylist, forKey: "id_playlist")
                songCoreData.setValue(type, forKey: "type")
                
                
                
                do {
                    try managedContext.save()
                    
                    completion()
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                    failure(error)
                }
            }
        }
        else{
            failure(nil)
        }
        
        
        
       
    }
    
}
