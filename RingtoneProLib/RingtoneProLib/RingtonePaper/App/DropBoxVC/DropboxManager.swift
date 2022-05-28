//
//  DropboxManager.swift
//  AudiConverter
//
//  Created by vinova on 4/18/21.
//

import Foundation
import SwiftyDropbox
import PKHUD






struct DropboxManager {
    
    static func loginDropBox(controller:AddMediaVC, completion: ()->Void){
        
        if DropboxClientsManager.authorizedClient != nil{
            
            let ab = DBListFileVC()
            
            ab.delegate = controller
            ab.showDropboxData()
            let navRoot = BaseNavVC(rootViewController: ab)
            controller.present(navRoot, animated: true, completion: nil)
            
        }
        else{
            let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["account_info.read", "account_info.write", "files.metadata.read", "files.metadata.write", "files.content.read", "files.content.write"], includeGrantedScopes: true)
            DropboxClientsManager.authorizeFromControllerV2(
                UIApplication.shared,
                controller: controller,
                loadingStatusDelegate: nil,
                openURL: { (url: URL) -> Void in UIApplication.shared.open(url, options: [:], completionHandler: nil) }, scopeRequest: scopeRequest
            )
        }
        
    }
    
    static func getNameUser(completion: @escaping (_ name:String)->Void){
        guard let client = DropboxClientsManager.authorizedClient else {return}
        client.users.getCurrentAccount().response { response, error in
            print("*** Get current account ***")
            if let account = response {
                completion(account.name.givenName)
                
            } else {
                print(error!)
            }
        }
    }
    
    
    static func getListFolder(url:String, completion: @escaping (_ fileList:[Files.Metadata])->Void){
        guard let client = DropboxClientsManager.authorizedClient else {return}
        HUD.show(.progress)
        
        client.files.listFolder(path: url).response { response, err in
            print("*** List folder ***")
            if let result = response {
                
                completion(result.entries)
                HUD.hide()
            } else {
                HUD.show(.labeledError(title: "Error", subtitle: err?.description ?? ""))
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    HUD.hide()
                }
                //show error message
                print(err?.description ?? "")
            }
        }
    }
    
    
    static func downloadFile(path:String, nameFile:String, completion:@escaping (_ url:URL?)->Void){
        
        var documentsURL = URL(fileURLWithPath: NSTemporaryDirectory())
        documentsURL.appendPathComponent(nameFile)
        
        
        HUD.show(.labeledProgress(title: nil, subtitle: String(format: "%.0f %%", 0)))
       
        guard documentsURL.containsAudio || documentsURL.containsVideo || documentsURL.containsQuickTime  else {
            HUD.show(.labeledError(title: nil, subtitle: "file not format audio or video"))
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                HUD.hide()
            }
            return
        }
        
        
        let destination : (URL, HTTPURLResponse) -> URL = { temporaryURL, response in

            if FileManager.default.fileExists(atPath: documentsURL.path) {
                do {
                    try FileManager.default.removeItem(atPath: documentsURL.path)
                }
                catch let error as NSError {
                    print("Ooops! Something went wrong: \(error)")
                }
            }
            return documentsURL
        }
        guard let client = DropboxClientsManager.authorizedClient else {return }
        client.files.download(path: path, destination: destination)
            .progress{ progressData in
            
                HUD.show(.labeledProgress(title: nil, subtitle: String(format: "%.0f %%", (progressData.fractionCompleted*100))))
               
        }
        
        .response { response, error in

            if let (_, url) = response {
                HUD.show(.labeledSuccess(title: nil, subtitle: "Success"))
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    HUD.hide()
                }
                
                ConvertRingtone.convertAudio(name: url.originalFileName ?? "", url: URL(fileURLWithPath: NSTemporaryDirectory()+"/"+url.lastPathComponent)) { url in
                    completion(url)
                    
                }
            } else {
                HUD.show(.labeledError(title: nil, subtitle: error?.description ?? ""))
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    HUD.hide()
                }
            }
        }
        
        
    }
    
}

