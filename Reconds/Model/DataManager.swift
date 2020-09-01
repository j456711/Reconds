//
//  DataManager.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/5/15.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import Foundation

enum DataManagingError: Error {
    
    case failedToSaveAsVideoData
    case failedToSaveInDirectory
    
    case failedToRetrieveContents
    case failedToDeleteUrls
}

class DataManager {
    
    static let shared = DataManager()
    
    private init() {}
    
    typealias DataSavingHandler = (Result<(), DataManagingError>) -> Void
    
    func dataSaved(videoUrl: URL?, completionHandler: @escaping DataSavingHandler) {
        
        guard let videoUrl = videoUrl else { return }
        
        do {
            
            let videoData = try Data(contentsOf: videoUrl)
            
            let time = Int(Date().timeIntervalSince1970)
            
            let fileName = "\(time).mp4"
            
            let dataPath = JYFileManager.videoDataDirectory.appendingPathComponent(fileName)
            
            do {
                
                try videoData.write(to: dataPath)
                
                let videoData = StorageManager.shared.fetch(VideoData.self)
                
                guard let filteredArray = StorageManager.shared.filterData() else { return }
                
                videoData[0].dataPathArray.insert(fileName, at: filteredArray.count)
                
                videoData[0].dataPathArray.removeLast()
                
                StorageManager.shared.save()
                
                completionHandler(Result.success(()))
                
            } catch {
                
                completionHandler(Result.failure(.failedToSaveInDirectory))
            }
            
        } catch {
            
            completionHandler(Result.failure(.failedToSaveAsVideoData))
        }
    }
    
    func deleteFilesInVideoDataDirectory(completionHandler: (Result<(), DataManagingError>) -> Void) {
        
        do {
            
            let fileUrls = try FileManager.default.contentsOfDirectory(at: JYFileManager.videoDataDirectory,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: [.skipsHiddenFiles,
                                                                                 .skipsSubdirectoryDescendants])
            
            for fileUrl in fileUrls {
                
                do {
                    
                    try FileManager.default.removeItem(at: fileUrl)
                    
                    UserDefaults.standard.removeObject(forKey: "Title")
                    
                    completionHandler(Result.success(()))
                    
                } catch {
                    
                    completionHandler(Result.failure(.failedToDeleteUrls))
                }
            }
            
        } catch {
            
            completionHandler(Result.failure(.failedToRetrieveContents))
        }
    }
    
    func deleteFilesInTemporaryDirectory(completionHandler: (Result<(), DataManagingError>) -> Void) {
        
        do {
            
            let temporaryDirectory = FileManager.default.temporaryDirectory
            
            let tmpUrls = try FileManager.default.contentsOfDirectory(atPath: temporaryDirectory.path)
            
            for tmpUrl in tmpUrls {
                
                do {
                    
                    let fullTmpUrl = temporaryDirectory.appendingPathComponent(tmpUrl)
                    
                    try FileManager.default.removeItem(atPath: fullTmpUrl.path)
                    
                    completionHandler(Result.success(()))
                    
                } catch {
                    
                    completionHandler(Result.failure(.failedToDeleteUrls))
                }
            }
            
        } catch {
            
            completionHandler(Result.failure(.failedToRetrieveContents))
        }
    }
}
