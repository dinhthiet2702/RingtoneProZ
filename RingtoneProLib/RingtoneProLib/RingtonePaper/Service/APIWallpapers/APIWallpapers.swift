//
//  APIWallpapers.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/11/21.
//

import UIKit
import Alamofire
import PKHUD


typealias CategorySuccess = (_ categories:WallpaperBase?) -> Void
typealias CategoryError = (_ error:Error?) -> Void
typealias CategoryWallpaperSuccess = (_ categories:CategoryWallpagerLive?) -> Void
typealias CategoryWallpaperError = (_ error:Error?) -> Void
typealias ProgressWallpaperDownload = (_ progress:Double) -> Void
typealias WallpaperDownloadSuccess = (_ data:Data) -> Void


enum WALLPAPER {
    case category
    case getlist(id:Int, page:Int)
}

extension WALLPAPER{
    var url:String{
        switch self {
        case .category:
            return "http://138.68.49.223:8080/category?page=0&size=10000"
        case .getlist(let id, let page):
            return "http://138.68.49.223:8080/wallpaper/category/\(id)%20?page=\(page)&size=50"
        }
    }
}


class APIWallpapers{
    
    
    static func getListCategory(completion: @escaping CategorySuccess, fail: @escaping CategoryError) {
        let urlCate = URL(string:WALLPAPER.category.url)!
        HUD.show(.progress)
        Alamofire.request(urlCate).responseData { response in
            switch response.result{
            case .success(let data):
                do {
                    
                    
                    let json = try JSONDecoder.init().decode(WallpaperBase.self, from: data)
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
    
    
    static func getLiveFromCategory(id:Int, page:Int, completion: @escaping CategoryWallpaperSuccess, fail: @escaping CategoryWallpaperError ) {
        let urlWallet = URL(string:WALLPAPER.getlist(id: id, page: page).url)!
        Alamofire.request(urlWallet).responseData { response in
            switch response.result{
            case .success(let data):
                do {
                    
                    let json = try JSONDecoder.init().decode(CategoryWallpagerLive.self, from: data)
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
    
    static func downloadWallpaper(url:URL, progress: @escaping ProgressWallpaperDownload, completion: @escaping WallpaperDownloadSuccess, fail: @escaping CategoryError){
        
        
       
        let documentsURL = ManagerFile.shared.urlWallPapersDownload+"/"+url.lastPathComponent
        
        
        print("documentsURL", documentsURL)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in

            let fileURL = URL(fileURLWithPath: documentsURL)

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        
////
        let download = Alamofire.download(url, to: destination)

        download.responseData { response in
            switch response.result{
            case .success(let data):

                completion(data)
            case .failure(let error):
                fail(error)
            }
        }
        download.downloadProgress { pro in
            progress(Double(pro.fractionCompleted))
        }
    }
    
}
