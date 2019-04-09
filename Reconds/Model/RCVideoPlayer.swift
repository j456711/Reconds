//
//  RCVideoPlayer.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/6.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class RCVideoPlayer {
    
    let avPlayer = AVPlayer()
    
    var avPlayerlayer: AVPlayerLayer!
    
    func setUpAVPlayer(with view: UIView, videoUrl: URL) {
        
        avPlayerlayer = AVPlayerLayer(player: avPlayer)
        avPlayerlayer.frame = view.bounds
        avPlayerlayer.videoGravity = AVLayerVideoGravity.resizeAspect
        
        view.layer.addSublayer(avPlayerlayer)
        
        let playerItem = AVPlayerItem(url: videoUrl)
        avPlayer.replaceCurrentItem(with: playerItem)
    }
    
    func play() {
        
        avPlayer.play()
    }
}
