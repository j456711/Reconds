//
//  JYFileManager.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2020/8/24.
//  Copyright © 2020 Yu-Hsin Yeh. All rights reserved.
//

import Foundation

class JYFileManager {
    
    static let shared = JYFileManager()
    
    private init() {}
    
    static let exportedDirectory = FileManager.default.urls(for: .documentDirectory,
                                                     in: .userDomainMask)[0].appendingPathComponent("Exported")
    
    static let videoDataDirectory = FileManager.default.urls(for: .documentDirectory,
                                                      in: .userDomainMask)[0].appendingPathComponent("VideoData")
}

extension JYFileManager {
    
    func removeItemIfExisted(at url: URL) {
        
        if FileManager.default.fileExists(atPath: url.path) {
        
            do {
            
                try FileManager.default.removeItem(atPath: url.path)
            
            } catch {
              
                print("Failed to delete file: \(error.localizedDescription)")
            }
        }
    }
    
    func createDirectory(_ name: String) {
        
        let savePath = FileManager.default.urls(for: .documentDirectory,
                                                in: .userDomainMask)[0].appendingPathComponent(name)
        
        do {
            
            try FileManager.default.createDirectory(atPath: savePath.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            
        } catch {
            
            print("Create path error", error.localizedDescription)
        }
    }
}
