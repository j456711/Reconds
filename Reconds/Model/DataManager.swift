//
//  DataManager.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/5/15.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import Foundation

enum DataSavingError: Error {
    
    case failedToSaveAsVideoData
    case failedToSaveInDirectory
}

class DataManager {
    
    static let shared = DataManager()
    
    private init() {}
    
    typealias DataSavingHandler = (Result<(), DataSavingError>) -> Void
    
    func dataSaved(videoUrl: URL?, completionHandler: @escaping DataSavingHandler) {
        
        guard let videoUrl = videoUrl else { return }
        
        do {
            
            let videoData = try Data(contentsOf: videoUrl)
            
            let time = Int(Date().timeIntervalSince1970)
            
            let fileName = "\(time).mp4"
            
            let dataPath = FileManager.videoDataDirectory.appendingPathComponent(fileName)
            
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
}
