//
//  ShareAudio.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/13/21.
//

import Foundation
import AVKit


class ShareAudio : NSObject {
    
    static func sharedGarageband(audio: URL, nameProject:String, completion: @escaping (URL?, String?) -> Void) {
        let audioFileInput = audio
        let mixedAudio: String = "ringtone.aiff"
        let exportPathDirectory = NSTemporaryDirectory()
        let projectBandDirectory = exportPathDirectory + "\(nameProject).band"
        if (FileManager.default.fileExists(atPath: projectBandDirectory)) {
            try! FileManager.default.removeItem(at: URL(fileURLWithPath: projectBandDirectory))
        }
        
        try! FileManager.default.createDirectory(atPath: projectBandDirectory, withIntermediateDirectories: true, attributes: nil)
        let exportPath: String = projectBandDirectory + "/"
        
        let bundlePath = Bundle.main.path(forResource: "projectData", ofType: "")
        let fullDestPath = NSURL(fileURLWithPath: exportPath).appendingPathComponent("projectData")
        let fullDestPathString = (fullDestPath?.path)!
        
        
        
        try! FileManager.default.createDirectory(atPath: exportPath + "Media", withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(atPath: exportPath + "Output", withIntermediateDirectories: true, attributes: nil)
        
        let audioFileOutput = URL(fileURLWithPath: exportPathDirectory + mixedAudio)
        print("Will export to \(audioFileOutput.absoluteString)")
        
        try? FileManager.default.removeItem(at: audioFileOutput)
        
        let asset = AVAsset(url: audioFileInput)
        
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
        
        if (exportSession == nil) {
            DispatchQueue.main.async {
                completion(nil, "ExportSession is nil")
            }
            return
        }
        
        exportSession?.outputURL = audioFileOutput
        exportSession?.outputFileType = AVFileType.caf
        
        exportSession?.exportAsynchronously {
            switch (exportSession?.status) {
            case .completed:
                guard let url = exportSession?.outputURL else { return}

                let destUrl = URL(fileURLWithPath: exportPath + "Media/ringtone.aiff")
                
                do {
                    try FileManager.default.copyItem(atPath: bundlePath!, toPath: fullDestPathString)
                    try FileManager.default.copyItem(atPath: url.path, toPath: destUrl.path)
                    DispatchQueue.main.async {
                        completion(URL(fileURLWithPath: exportPath), nil)
                    }
                } catch let exception {
                    DispatchQueue.main.async {
                        completion(nil, exception.localizedDescription)
                    }
                   
                }
                break
            default:
                DispatchQueue.main.async {
                    completion(nil, exportSession?.error?.localizedDescription)
                }
                
                break
            }
        }
    }
    
}

