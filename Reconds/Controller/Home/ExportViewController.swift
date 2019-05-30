//
//  ExportViewController.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/21.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit
import JGProgressHUD

class ExportViewController: UIViewController {
    
    let indicator = JGProgressHUD(style: .dark)
    
    var videoUrl: URL?
    
    var audioUrl: URL?
    
    var credits: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        indicator.textLabel.text = "輸出中"
        indicator.show(in: self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let videoUrl = videoUrl, let audioUrl = audioUrl {
            
            MergeVideoManager.shared.mergeVideoAndAudio(videoUrl: videoUrl,
                                                        audioUrl: audioUrl,
                                                        credits: credits,
                                                        completionHandler: { [weak self] (outputUrl, fileName, error) in
                
                guard let strongSelf = self else { return }
                                                            
                if let fileName = fileName,
                   let outputUrl = outputUrl,
                   let videoTitle = UserDefaults.standard.string(forKey: "Title") {
                    
                    guard let videoData = try? Data(contentsOf: outputUrl) else { return }
                    
                    do {
                        
                        try videoData.write(to: outputUrl)
                        
                    } catch {
                        
                        print("Write to directory error", error)
                    }
                    
                    strongSelf.createData(videoTitle: videoTitle, dataPath: fileName)
                    
                    StorageManager.shared.deleteAll("VideoData")
                    
                    DataManager.shared.deleteFilesInVideoDataDirectory(completionHandler: { result in
                        
                        switch result {
                            
                        case .success:
                            DataManager.shared.deleteFilesInTemporaryDirectory(completionHandler: { result in
                                
                                switch result {
                                    
                                case .success:
                                    break
                                    
                                case .failure(let error):
                                    print(error)
                                }
                            })
                            
                        case .failure(let error):                            
                            print(error)
                        }
                    })
                    
                    strongSelf.indicator.indicatorView = JGProgressHUDSuccessIndicatorView()
                    
                    strongSelf.indicator.textLabel.text = "輸出成功"
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        
                        guard let tabBar = strongSelf.presentingViewController as? TabBarController,
                            let navVC = tabBar.selectedViewController as? UINavigationController
                            else { return }
                        
                        navVC.popToRootViewController(animated: true)
                        
                        let viewController = UIStoryboard.home.instantiateViewController(
                            withIdentifier: String(describing: MyVideosViewController.self))
                        guard let myVideosVC = viewController as? MyVideosViewController else { return }
                        
                        tabBar.dismiss(animated: true, completion: {
                            
                            navVC.show(myVideosVC, sender: nil)
                        })
                    })
                    
                } else {
                    
                    print(error as Any)
                }
            })
        }
    }
}

extension ExportViewController {

    func createData(videoTitle: String, dataPath: String) {

        let videoCollection = VideoCollection(context: StorageManager.shared.persistentContainer.viewContext)

        videoCollection.videoTitle = videoTitle
        
        videoCollection.dataPath = dataPath

        StorageManager.shared.save()
        
        print(videoCollection)
    }
}
