//
//  ConvertRingtone.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/10/21.
//

import Foundation
import AVKit
import UIKit

class ConvertRingtone{
    
    
    static func convertAudio(name:String, url: URL?,startTime: Double? = nil, endTime: Double? = nil, completion: @escaping ExportSuccess){
        
        
        var settings:[String:Any] = [:]
        
        settings[AVNumberOfChannelsKey] = 2
        settings[AVFormatIDKey] = kAudioFormatAppleLossless
        settings[AVEncoderAudioQualityKey] = AVAudioQuality.max.rawValue
        let composition = AVMutableComposition(urlAssetInitializationOptions: settings)
        do {
            guard let url = url else {
                
                return
            }
            let asset = AVURLAsset(url: url)
            guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else {  return }
            
            guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                          preferredTrackID: kCMPersistentTrackID_Invalid) else {   return  }
            try audioCompositionTrack.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: CMTime.zero)
        } catch {
            print(error)
        }
        
        let urlOutputStringConvert = "\(ManagerFile.shared.urlMyRingtone)/\(name).m4a"
        
        
        
        let outputUrl = URL(fileURLWithPath: urlOutputStringConvert)
        
        if FileManager.default.fileExists(atPath: outputUrl.path) {
            try? FileManager.default.removeItem(atPath: outputUrl.path)
        }
        
        
        // Create an export session
        let exportSession = AVAssetExportSession(asset: composition, presetName:AVAssetExportPresetAppleM4A)!
        
        if let startTime = startTime, let endTime = endTime{
            let start: CMTime = CMTimeMakeWithSeconds(startTime, preferredTimescale: composition.duration.timescale)
            let stop: CMTime = CMTimeMakeWithSeconds(endTime, preferredTimescale: composition.duration.timescale)
            let range: CMTimeRange = CMTimeRangeFromTimeToTime(start: start, end: stop)
            exportSession.timeRange = range
        }
        
        exportSession.outputFileType = AVFileType.m4a
        exportSession.outputURL = outputUrl
        
        
        
        // Export file
        
        
        exportSession.exportAsynchronously(completionHandler: {
            switch exportSession.status{
            case.completed:
                guard let url = exportSession.outputURL else { return}
                DispatchQueue.main.async {
                    completion(url)
                }
                
            case .failed:
                print("exportSession.error", exportSession.error?.localizedDescription)
//                SVProgressHUD.showError(withStatus: "can not convert file!");
            case .unknown:
                print("fail")
            case .waiting:
                print("fail")
//                SVProgressHUD.showProgress(exportSession.progress, status: "Converting...")
            case .exporting:
                print("fail")
//                SVProgressHUD.showProgress(exportSession.progress, status: "Converting...")
            case .cancelled:
                print("fail")
            @unknown default:
                print("fail")
            }
        })
        
        
    }
}
