//
//  Data+Extension.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/12/21.
//

import Foundation
import UIKit


extension Data{
    func dataToFile(fileName: String) -> URL? {

        // Make a constant from the data
        let data = self

        // Make the file path (with the filename) where the file will be loacated after it is created
        let filePath = ManagerFile.shared.urlWallPapersDownload+"/"+fileName

        do {
            // Write the file from data into the filepath (if there will be an error, the code jumps to the catch block below)
            try data.write(to: URL(fileURLWithPath: filePath))

            // Returns the URL where the new file is located in NSURL
            return URL(fileURLWithPath: filePath)

        } catch {
            // Prints the localized description of the error from the do block
            print("Error writing the file: \(error.localizedDescription)")
        }

        // Returns nil if there was an error in the do-catch -block
        return nil

    }
}
