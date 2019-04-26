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
    
    @IBOutlet weak var indicatedView: UIView!
    
    @IBAction func returnButtonPressed(_ sender: UIButton) {
    
        guard let tabBar = self.presentingViewController as? TabBarController,
            let navVC = tabBar.selectedViewController as? UINavigationController else { return }

        navVC.popToRootViewController(animated: true)
        
        tabBar.dismiss(animated: true, completion: {
            
            navVC.pushViewController(MyVideosDetailViewController(), animated: true)
        })
    }
    
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
                    
                    do {
                        
                        let fileUrls =
                            try FileManager.default.contentsOfDirectory(at: FileManager.videoDataDirectory,
                                                                        includingPropertiesForKeys: nil,
                                                                        options: [.skipsHiddenFiles,
                                                                                  .skipsSubdirectoryDescendants])
                        
                        for fileUrl in fileUrls {

                            do {

                                try FileManager.default.removeItem(at: fileUrl)

                                UserDefaults.standard.removeObject(forKey: "Title")

                            } catch {

                                print("Can't remove fileUrl", error.localizedDescription)
                            }
                        }
                        
                    } catch {
                        
                        print(error.localizedDescription)
                    }
                    
                    do {
                        
                        let temporaryDirectory = FileManager.default.temporaryDirectory
                        
                        let tmpUrls = try FileManager.default.contentsOfDirectory(atPath: temporaryDirectory.path)
                        
                        print("$$$$$$$$$$$$$$$$", tmpUrls)
                        
                        for tmpUrl in tmpUrls {
                            
                            do {
                                
                                let fullTmpUrl = temporaryDirectory.appendingPathComponent(tmpUrl)
                                
                                try FileManager.default.removeItem(atPath: fullTmpUrl.path)
                                                                
                                strongSelf.indicator.indicatorView = JGProgressHUDSuccessIndicatorView()
                                
                                strongSelf.indicator.textLabel.text = "輸出成功"
                                                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                                    
                                    guard let tabBar = strongSelf.presentingViewController as? TabBarController,
                                        let navVC = tabBar.selectedViewController as? UINavigationController
                                        else { return }
                                    
                                    navVC.popToRootViewController(animated: true)
                                    
                                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                                    let viewController =
                                        storyboard.instantiateViewController(withIdentifier: "MyVideosViewController")
                                    guard let myVideoDetailVC =
                                        viewController as? MyVideosViewController else { return }
            
                                    tabBar.dismiss(animated: true, completion: {
                                        
                                        navVC.show(myVideoDetailVC, sender: nil)
                                    })
                                })
                                
                            } catch {
                                
                                print("Can't remove fullTmpUrl", error.localizedDescription)
                            }
                        }
                        
                    } catch {
                        
                        print(error.localizedDescription)
                    }
                    
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
