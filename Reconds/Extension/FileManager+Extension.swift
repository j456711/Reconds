//
//  FileManager+Extension.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/16.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import Foundation

extension FileManager {
    
    static let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func removeItemIfExisted(_ url: URL) {
        
        if FileManager.default.fileExists(atPath: url.path) {
        
            do {
            
                try FileManager.default.removeItem(atPath: url.path)
            
            } catch {
              
                print("Failed to delete file: \(error.localizedDescription)")
            }
        }
    }
}
