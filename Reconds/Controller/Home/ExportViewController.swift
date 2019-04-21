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

        if let videoUrl = videoUrl, let audioUrl = audioUrl {
            
            MergeVideoManager.shared.mergeVideoAndAudio(videoUrl: videoUrl, audioUrl: audioUrl)
        }
    }
    
}
