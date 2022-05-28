//
//  String+Extension.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/11/21.
//

import Foundation
import UIKit

extension String{
    func splitText(_ character:String)->[String]{
        
        return self.components(separatedBy: character)
        
    }
    
    var queryURL:String?{
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    
    var isReallyEmpty: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
    }
    
}
