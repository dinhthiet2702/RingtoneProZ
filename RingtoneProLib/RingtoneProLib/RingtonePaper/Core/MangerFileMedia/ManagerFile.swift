//
//  ManagerFile.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/10/21.
//

import Foundation
import UIKit
import AVKit
import CoreServices




public typealias ExportSuccess = (_ url: URL) -> Void


public class ManagerFile {
    
    
    public static let shared = ManagerFile()
    
    
    
    var urlAudios:String{
        get{
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = "\(paths[0].path)/Audio"
            return documentsDirectory
        }
    }
    
    var urlMyRingtone:String{
        get{
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = "\(paths[0].path)/MyRingtone"
            return documentsDirectory
        }
    }
    
    var urlWallPapersDownload:String{
        
        get{
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = "\(paths[0].path)/WallPapersDownload"
            return documentsDirectory
        }
        
    }
    
    var urlMyWallPapers:String{
        
        get{
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = "\(paths[0].path)/MyWallPapers"
            return documentsDirectory
        }
        
    }
    
    var urlAudioDownloaded:String{
        
        get{
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = "\(paths[0].path)/AudioDownloaded"
            return documentsDirectory
        }
        
    }
    
    
    var urlImagesTemp:String?{
        
        get{
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = "\(paths[0].path)/TempImages"
            return documentsDirectory
        }
        
    }
    
    
    
    
    
    public func createFolderAudio(){
        
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = documentDirectoryURL.appendingPathComponent("Audio", isDirectory: true)
        
        if FileManager.default.fileExists(atPath: directoryURL.path) {
            print(directoryURL.path)
        } else {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                print(directoryURL.path)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    public func createFolderAudioDownloaded(){
        
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = documentDirectoryURL.appendingPathComponent("AudioDownloaded", isDirectory: true)
        
        if FileManager.default.fileExists(atPath: directoryURL.path) {
            print(directoryURL.path)
        } else {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                print(directoryURL.path)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    public func createFolderMyRingtone(){
        
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = documentDirectoryURL.appendingPathComponent("MyRingtone", isDirectory: true)
        
        if FileManager.default.fileExists(atPath: directoryURL.path) {
            print(directoryURL.path)
        } else {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                print(directoryURL.path)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    public func createFolderWallpaperDownload(){
        
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = documentDirectoryURL.appendingPathComponent("WallPapersDownload", isDirectory: true)
        
        if FileManager.default.fileExists(atPath: directoryURL.path) {
            print(directoryURL.path)
        } else {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                print(directoryURL.path)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    public func createFolderMyWallpapers(){
        
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = documentDirectoryURL.appendingPathComponent("MyWallPapers", isDirectory: true)
        
        if FileManager.default.fileExists(atPath: directoryURL.path) {
            print(directoryURL.path)
        } else {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                print(directoryURL.path)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func removeItem(url:URL, completion: @escaping ()->Void){
        if FileManager.default.fileExists(atPath: url.path){
            try? FileManager.default.removeItem(atPath: url.path)
            completion()
        }
    }
    
    func getAudios() ->[URL]{
        
        let fileManager = FileManager.default
        
        let booksURL = URL(fileURLWithPath: urlAudios)
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: booksURL, includingPropertiesForKeys: nil)
            return fileURLs
            // process files
        } catch {
            return []
            
        }
        
    }
    
    func getMyRingtones() ->[URL]{
        
        let fileManager = FileManager.default
        
        let booksURL = URL(fileURLWithPath: urlMyRingtone)
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: booksURL, includingPropertiesForKeys: nil)
            return fileURLs
            // process files
        } catch {
            return []
            
        }
        
    }
    
    func getWallpapersDownload() ->[URL]{
        
        let fileManager = FileManager.default
        
        let booksURL = URL(fileURLWithPath: urlWallPapersDownload)
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: booksURL, includingPropertiesForKeys: nil)
            return fileURLs
            // process files
        } catch {
            return []
            
        }
        
    }
    
    func getAudioDownloaded() ->[URL]{
        
        let fileManager = FileManager.default
        
        let booksURL = URL(fileURLWithPath: urlAudioDownloaded)
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: booksURL, includingPropertiesForKeys: nil)
            return fileURLs
            // process files
        } catch {
            return []
            
        }
        
    }
    
    
    
    func getMyWallpapers() ->[URL]{
        
        let fileManager = FileManager.default
        
        let booksURL = URL(fileURLWithPath: urlMyWallPapers)
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: booksURL, includingPropertiesForKeys: nil)
            return fileURLs
            // process files
        } catch {
            return []
            
        }
        
    }
    
    func moveWallpaperImage(urlImageLive:URL, completion: @escaping (_ urlLiv:URL)->Void, error:@escaping ()->Void){
        let urlImport = ManagerFile.shared.urlMyWallPapers
        let toUrlLiv = URL(fileURLWithPath: urlImport+"/"+urlImageLive.lastPathComponent )
        
        print("urlImageLive", urlImageLive)
        print("toUrlLiv", toUrlLiv)
        
        
        if FileManager.default.fileExists(atPath: urlImageLive.path) {
            
            try? FileManager.default.moveItem(at: urlImageLive, to: toUrlLiv)
            completion(toUrlLiv)
        }
        
        else{
            error()
        }
    }
    
    
    
    
    
    func moveItemAudio(atUrl:URL, completion: @escaping (_ url:URL)->Void, error:@escaping ()->Void){
        
        let urlImport = ManagerFile.shared.urlMyRingtone
        let toUrl = URL(fileURLWithPath: urlImport+"/"+atUrl.lastPathComponent )
        if FileManager.default.fileExists(atPath: toUrl.path) {
            try? FileManager.default.moveItem(at: atUrl, to: toUrl)
            try? FileManager.default.removeFileIfNecessary(at: atUrl)
            completion(toUrl)
        }
        
        else{
            error()
        }
    }
    
    
    
    
    
    func thumbImageVideo(url:URL) ->UIImage?{
        do {
            let asset = AVURLAsset(url: url, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 2, timescale: 3), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage).resized(toWidth: 150)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    //
    
    
    
    //    func saveImage(image:UIImage?=nil, url:URL?=nil)->Data?{
    //
    //        if let image = image{
    //            guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
    //                return nil
    //            }
    //            return data
    //        }
    //        else{
    //            guard let url = url, let data = thumbImageVideo(url: url)?.jpegData(compressionQuality: 1) ?? thumbImageVideo(url: url)?.pngData() else {
    //                return nil
    //            }
    //            return data
    //        }
    //
    //
    //
    //    }
    
    
    func getSavedImage(url: String) -> UIImage? {
        
        return UIImage(contentsOfFile: url)
        
    }
    
    
    func getTimeAudio(url:URL?) ->Double{
        guard let url = url else {
            return 0.0
        }
        let asset = AVURLAsset(url: url, options: nil)
        let audioDuration = asset.duration
        let audioDurationSeconds = CMTimeGetSeconds(audioDuration)
        
        return audioDurationSeconds
    }
    
    
}
public extension FileManager {
    func removeFileIfNecessary(at url: URL) throws {
        guard fileExists(atPath: url.path) else {
            return
        }
        
        do {
            try removeItem(at: url)
        } catch let _ {
            
        }
    }
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}
