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
    
    var player: AVPlayer?
    
    var playerItem: AVPlayerItem?
    
    var playerlayer: AVPlayerLayer?
    
    func showVideoWith(_ view: UIView, url: URL) {
        
        player = AVPlayer(url: url)
        
        playerlayer = AVPlayerLayer(player: player)
        
        playerlayer?.frame = view.bounds
        
        view.layer.addSublayer(playerlayer!)
        
        player!.play()

    }
    
}
