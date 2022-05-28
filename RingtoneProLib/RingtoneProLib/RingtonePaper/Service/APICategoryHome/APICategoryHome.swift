//
//  APICategoryHome.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/19/21.
//

import UIKit
import Alamofire
import PKHUD


typealias GetHomeSuccess = (_ categories:BaseCategoryModel?, BaseGenresModel?) -> Void
typealias GetPlayListSuccess = (_ categories:BasePlayListModel?) -> Void
typealias GetGenresSuccess = (_ categories:BaseGenresModel?) -> Void
typealias SearchSongSuccess = (_ songs:BaseSongModel?) -> Void
typealias ProgressMusicDownload = (_ progress:Double) -> Void?
typealias MusicDownloadSuccess = (_ url:URL) -> Void
typealias MusicError = (_ error:Error?) -> Void?




enum PLAYLIST {
    case category(page:Int)
    case genres(page:Int)
    case getGenresById(id:Int)
    case getPlayListCategory(id:Int)
    case searchSong(name:String, page:Int)
    case searchPlayList(name:String, page:Int)
    case searchArtis(name:String, page:Int)
    
}

extension PLAYLIST{
    var url:String{
        switch self {
        case .category(let page):
            return "http://167.99.119.17/search/get-search-categories/\(page)"
        case .genres(let page):
            return "http://167.99.119.17/search/get-genres/\(page)"
        case .getGenresById(let id):
            return "http://167.99.119.17/search/get-genres-by-id/\(id)/0"
        case .getPlayListCategory(let id):
            return "http://167.99.119.17/search/get-playlist-id/\(id)"
        case .searchSong(let name, let page):
            return "http://167.99.119.17/search/get-search-song-by-name/\(name)/\(page)"
        case .searchPlayList(let name, let page):
            return "http://167.99.119.17/search/get-search-playlist-by-name/\(name)/\(page)"
        case .searchArtis(let name, let page):
            return "http://167.99.119.17/search/get-search-song-by-artist/\(name)/\(page)"
        }
    }
}


class APICategoryHome{
    
    
    static func getHome(page:Int, completion: @escaping GetHomeSuccess, fail: @escaping CategoryError) {
        let urlCate = URL(string:PLAYLIST.category(page: page).url)!
        Alamofire.request(urlCate).responseData { response in
            switch response.result{
            case .success(let data):
                
                self.getGenres(page: page) { genres in
                    do {
                        
                        let json = try JSONDecoder.init().decode(BaseCategoryModel.self, from: data)
                        DispatchQueue.main.async {
                            
                            completion(json, genres)
                            HUD.hide()
                        }
                        
                        
                    } catch {
                        DispatchQueue.main.async {
                            completion(nil, genres)
                            HUD.hide()
                        }
                    }
                    
                } fail: { err in
                    DispatchQueue.main.async {
                        fail(err)
                        HUD.show(.labeledError(title: "Error", subtitle: err?.localizedDescription))
                        HUD.hide()
                    }
                }
                
            //
            case .failure(let err):
                DispatchQueue.main.async {
                    fail(err)
                    HUD.show(.labeledError(title: "Error", subtitle: err.localizedDescription))
                    HUD.hide()
                }
            }
            
        }
    }
    static func getGenres(page:Int, completion: @escaping GetGenresSuccess, fail: @escaping CategoryError) {
        let urlCate = URL(string: PLAYLIST.genres(page: page).url)!
        
        Alamofire.request(urlCate).responseData { response in
            switch response.result{
            case .success(let data):
                do {
                    
                    
                    let json = try JSONDecoder.init().decode(BaseGenresModel.self, from: data)
                    DispatchQueue.main.async {
                        completion(json)
                        
                    }
                    
                    
                } catch {
                    DispatchQueue.main.async {
                        completion(nil)
                        
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    fail(err)
                    HUD.show(.labeledError(title: "Error", subtitle: err.localizedDescription))
                    HUD.hide()
                }
            }
            
        }
    }
    
    static func getGenresById(id:Int, completion: @escaping GetPlayListSuccess, fail: @escaping CategoryError ) {
        let urlPlayList = URL(string:PLAYLIST.getGenresById(id: id).url)!
        HUD.show(.progress)
        Alamofire.request(urlPlayList).responseData { response in
            switch response.result{
            case .success(let data):
                do {
                    
                    let json = try JSONDecoder.init().decode(BasePlayListModel.self, from: data)
                    DispatchQueue.main.async {
                        completion(json)
                        HUD.hide()
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil)
                        HUD.hide()
                    }
                    
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    fail(err)
                    HUD.show(.labeledError(title: "Error", subtitle: err.localizedDescription))
                    HUD.hide()
                }
                
            }
            
        }
        
    }
    
    
    static func getPlayListFromCategory(id:Int, completion: @escaping GetPlayListSuccess, fail: @escaping CategoryError ) {
        let urlPlayList = URL(string:PLAYLIST.getPlayListCategory(id: id).url)!
        HUD.show(.progress)
        Alamofire.request(urlPlayList).responseData { response in
            switch response.result{
            case .success(let data):
                do {
                    
                    let json = try JSONDecoder.init().decode(BasePlayListModel.self, from: data)
                    DispatchQueue.main.async {
                        completion(json)
                        HUD.hide()
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil)
                        HUD.hide()
                    }
                    
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    fail(err)
                    HUD.show(.labeledError(title: "Error", subtitle: err.localizedDescription))
                    HUD.hide()
                }
                
            }
            
        }
        
    }
    
    static func downloadMusic(url:URL, progress: @escaping ProgressWallpaperDownload, completion: @escaping MusicDownloadSuccess, fail: @escaping CategoryError){
        
        
        
        let documentsURL = ManagerFile.shared.urlAudioDownloaded+"/"+url.lastPathComponent
        
        
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            
            let fileURL = URL(fileURLWithPath: documentsURL)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        
        ////
        let download = Alamofire.download(url, to: destination)
        
        download.responseData { response in
            switch response.result{
            case .success(let data):
                print("documentsURL", documentsURL)
                completion(URL(fileURLWithPath: documentsURL))
            case .failure(let error):
                fail(error)
            }
        }
        download.downloadProgress { pro in
            progress(Double(pro.fractionCompleted))
        }
    }
    
    
    
    static func searchSongByName(name:String, page:Int, completion: @escaping SearchSongSuccess, fail: @escaping CategoryError) {
        let urlCate = URL(string:PLAYLIST.searchSong(name: name, page: page).url.queryURL ?? "")!
        
        Alamofire.request(urlCate).responseData { response in
            switch response.result{
            case .success(let data):
                do {
                    
                    
                    let json = try JSONDecoder.init().decode(BaseSongModel.self, from: data)
                    DispatchQueue.main.async {
                        completion(json)
                       
                        

                    }
                    
                    
                } catch {
                    DispatchQueue.main.async {
                        completion(nil)
                        
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    fail(err)
                    HUD.show(.labeledError(title: "Error", subtitle: err.localizedDescription))
                    HUD.hide()
                }
            }
            
        }
    }
    
    
    
    static func searchSongByArtis(name:String, page:Int, completion: @escaping SearchSongSuccess, fail: @escaping CategoryError) {
        let urlCate = URL(string:PLAYLIST.searchArtis(name: name, page: page).url.queryURL ?? "")!
        
        Alamofire.request(urlCate).responseData { response in
            switch response.result{
            case .success(let data):
                do {
                    
                    
                    let json = try JSONDecoder.init().decode(BaseSongModel.self, from: data)
                    DispatchQueue.main.async {
                        completion(json)
                        
                    }
                    
                    
                } catch {
                    DispatchQueue.main.async {
                        completion(nil)
                        
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    fail(err)
                    HUD.show(.labeledError(title: "Error", subtitle: err.localizedDescription))
                    HUD.hide()
                }
            }
            
        }
    }
    
    
    static func searchPlayListByName(name:String, page:Int, completion: @escaping GetPlayListSuccess, fail: @escaping CategoryError) {
        let urlCate = URL(string:PLAYLIST.searchPlayList(name: name, page: page).url.queryURL ?? "")!
        
        Alamofire.request(urlCate).responseData { response in
            switch response.result{
            case .success(let data):
                do {
                    
                    
                    let json = try JSONDecoder.init().decode(BasePlayListModel.self, from: data)
                    DispatchQueue.main.async {
                        completion(json)
                        
                    }
                    
                    
                } catch {
                    DispatchQueue.main.async {
                        completion(nil)
                        
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    fail(err)
                    HUD.show(.labeledError(title: "Error", subtitle: err.localizedDescription))
                    HUD.hide()
                }
            }
            
        }
    }
    
}
