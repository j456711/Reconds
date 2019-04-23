//
//  ExportViewController.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/21.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit

class ExportViewController: UIViewController {

    var videoUrl: URL?
    
    var audioUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let videoUrl = videoUrl, let audioUrl = audioUrl {
            
            MergeVideoManager.shared.mergeVideoAndAudio(videoUrl: videoUrl,
                                                        audioUrl: audioUrl,
                                                        completionHandler: { [weak self] (fileName, error) in
                                                            
                if let fileName = fileName,
                   let videoTitle = UserDefaults.standard.string(forKey: "Title") {
                    
                    self?.createData(videoTitle: videoTitle, dataPath: fileName)
                    
                } else {
                    
                    print(error as Any)
                }
            })
        }
    }
}

extension ExportViewController {

    func createData(videoTitle: String, dataPath: String) {

        let videoCollection = VideoCollection(context: StorageManager.shared.persistantContainer.viewContext)

        videoCollection.videoTitle = videoTitle
        
        videoCollection.dataPath = dataPath

        StorageManager.shared.save()
        
        print(videoCollection)
    }
}
