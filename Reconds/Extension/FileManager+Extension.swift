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
    
    static let exportedDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Exported")
    
    static let videoDataDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("VideoData")
    
    func removeItemIfExisted(at url: URL) {
        
        if FileManager.default.fileExists(atPath: url.path) {
        
            do {
            
                try FileManager.default.removeItem(atPath: url.path)
            
            } catch {
              
                print("Failed to delete file: \(error.localizedDescription)")
            }
        }
    }
    
    func jy_createDirectory(_ name: String) {
        
        let savePath = FileManager.documentDirectory.appendingPathComponent(name)
        
        do {
            
            try FileManager.default.createDirectory(atPath: savePath.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            
        } catch {
            
            print("Create path error", error.localizedDescription)
        }
    }
}
