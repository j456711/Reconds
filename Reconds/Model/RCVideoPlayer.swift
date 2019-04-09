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
    
    func pause() {
        
        avPlayer.pause()
    }
    
    func fetchDuration(disPlayOn endTimeLabel: UILabel, setMaximumValueOn slider: UISlider) {
        
        guard let duration = avPlayer.currentItem?.asset.duration else { return }
        
        let second = CMTimeGetSeconds(duration)
        
        endTimeLabel.text = timeFormatConversion(time: second)
        
        slider.maximumValue = Float(second)
        
        slider.isContinuous = true
    }
    
    func fetchCurrentTime(disPlayOn startTimeLabel: UILabel, setValueOn slider: UISlider) {
        
        let cmTime = CMTimeMake(value: 1, timescale: 1)
        
        avPlayer.addPeriodicTimeObserver(forInterval: cmTime, queue: DispatchQueue.main, using: { [weak self] CMTime in
            
            guard let strongSelf = self else { return }
            
            if strongSelf.avPlayer.currentItem?.status == .readyToPlay {
                
                let currentTime = CMTimeGetSeconds(strongSelf.avPlayer.currentTime())
                
                startTimeLabel.text = strongSelf.timeFormatConversion(time: currentTime)
                
                slider.value = Float(currentTime)
            }
        })
    }
}

extension RCVideoPlayer {
    
    //Helper Method
    func timeFormatConversion(time: Float64) -> String {
        
        let songLength = Int(time)
        
        let minutes = Int(songLength / 60) // 求 songLength 的商，為分鐘數
        
        let seconds = Int(songLength % 60) // 求 songLength 的餘數，為秒數
        
        var time = ""
        
        if minutes < 10 {
            
            time = "0\(minutes):"
            
        } else {
            
            time = "\(minutes)"
        }
        
        if seconds < 10 {
            
            time += "0\(seconds)"
            
        } else {
            
            time += "\(seconds)"
        }
        
        return time
    }
}
