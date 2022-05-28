//
//  URL+Extension.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/10/21.
//

import Foundation
import UIKit
import MobileCoreServices
import AVKit

extension URL{
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    var containsImage: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeImage)
    }
    var containsDocument: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypePDF)
    }
    
    var containsText: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeText)
    }
    var containsPresentation: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypePresentation)
    }
    var containsWebloc: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeHTML)
    }
    var containsArchive: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeArchive)
    }
    var containsAudio: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeAudio)
    }
    var containsVideo: Bool {
        let mimeType = self.mimeType()
        guard  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeMovie)
    }
    var containsQuickTime: Bool {
        let mimeType = self.mimeType()
        guard  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeQuickTimeMovie)
    }
    
    func getSizeVideo() -> Double{
        
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: path)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                let numberOfPlaces = 1.0
                let multiplier = pow(10.0, numberOfPlaces)
                let num = size.doubleValue / 1000000.0
                let rounded = round(num * multiplier) / multiplier
                return rounded
            }
        } catch {
            print("Error: \(error)")
        }
        return 0.0
    }
    
    func getDuration()->Double{
        let item = AVPlayerItem(url: self)
        let duration = Double(item.asset.duration.value) / Double(item.asset.duration.timescale)
        return duration
    }
    
    public var originalFileName: String? {
        get {
            
            return self.deletingPathExtension().lastPathComponent
        }
    }
    
    public var dateCreate: Date {
        get {
            if let date = (try? FileManager.default.attributesOfItem(atPath: path))?[.creationDate] as? Date{
                return date
            }
            else{
                return Date()
            }
            
            
        }
    }
    
    
    public var typeExtension:String?{
        get {
            
            return self.pathExtension
        }
    }
    
}
