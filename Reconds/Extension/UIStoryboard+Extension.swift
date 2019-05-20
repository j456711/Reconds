//
//  UIStoryboard+Extension.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/25.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import Foundation
import UIKit

private struct StoryboardCategory {
    
    static let main = "Main"
    
    static let home = "Home"
    
    static let record = "Record"
    
    static let settings = "Settings"
}

extension UIStoryboard {
 
    static var main: UIStoryboard { return rcStoryboard(name: StoryboardCategory.main) }
    
    static var home: UIStoryboard { return rcStoryboard(name: StoryboardCategory.home) }
    
    static var record: UIStoryboard { return rcStoryboard(name: StoryboardCategory.record) }
    
    static var settings: UIStoryboard { return rcStoryboard(name: StoryboardCategory.settings) }
    
    private static func rcStoryboard(name: String) -> UIStoryboard {
        
        return UIStoryboard(name: name, bundle: nil)
    }
}
