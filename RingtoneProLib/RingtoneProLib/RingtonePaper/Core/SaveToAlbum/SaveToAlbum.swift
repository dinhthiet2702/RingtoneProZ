//
//  SaveToAlbum.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/12/21.
//

import Foundation
import Photos


class SaveToAlbum: NSObject {
    static let albumName = "Ringtones-Wallpapers"
    static let shared = SaveToAlbum()
    
    private var assetCollection: PHAssetCollection!
    
    private override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
    }
    
    private func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool) -> Void)) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                self.checkAuthorizationWithHandler(completion: completion)
            })
        }
        else if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.createAlbumIfNeeded()
            completion(true)
        }
        else {
            completion(false)
        }
    }
    
    private func createAlbumIfNeeded() {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            // Album already exists
            self.assetCollection = assetCollection
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: SaveToAlbum.albumName)   // create an asset collection with the album name
            }) { success, error in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                } else {
                    // Unable to create album
                }
            }
        }
    }
    
    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", SaveToAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(image: UIImage, completion: @escaping () ->Void, fail: @escaping () ->Void) {
        self.checkAuthorizationWithHandler { (success) in
            if success, self.assetCollection != nil {
                PHPhotoLibrary.shared().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                    let enumeration: NSArray = [assetPlaceHolder!]
                    albumChangeRequest!.addAssets(enumeration)
                    
                }, completionHandler: {successa,err in
                    if successa{
                        DispatchQueue.main.async {
                            completion()
                        }
                    }else{
                        DispatchQueue.main.async {
                            fail()
                        }
                    }
                })
            }
        }
    }
    
    func saveLivePhotoToPhotosLibrary(livePhotoURL: URL, livePhotoMovieURL: URL, completion: @escaping ()->Void, fail:@escaping (_ error:Error?)->Void) {
        
        self.checkAuthorizationWithHandler { (success) in
            if success, self.assetCollection != nil {
                PHPhotoLibrary.shared().performChanges({
                    // Add the captured photo's file data as the main resource for the Photos asset.
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    
                    
                    creationRequest.addResource(with: .photo, fileURL: livePhotoURL, options: nil)
                    creationRequest.addResource(with: .pairedVideo, fileURL: livePhotoMovieURL, options: nil)
                    let assetPlaceHolder = creationRequest.placeholderForCreatedAsset
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                    guard let asset = assetPlaceHolder else {
                        fail(nil)
                        return
                        
                    }
                    let enumeration: NSArray = [asset]
                    albumChangeRequest?.addAssets(enumeration)
                    
                }) { successs, error in
                    if successs{
                        DispatchQueue.main.async {
                            completion()
                        }
                    }else{
                        DispatchQueue.main.async {
                            fail(error)
                        }
                        
                    }
                }
            }
        }
        
    }
}
