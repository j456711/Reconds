//
//  VideoPlaybackViewController.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/6.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlaybackViewController: UIViewController {

    let avPlayer = AVPlayer()
    
    var avPlayerlayer: AVPlayerLayer!
    
    var videoUrl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        avPlayerlayer = AVPlayerLayer(player: avPlayer)
        avPlayerlayer.frame = self.view.bounds
        avPlayerlayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.view.layer.addSublayer(avPlayerlayer)
        
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoUrl as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        avPlayer.play()
    }


}
