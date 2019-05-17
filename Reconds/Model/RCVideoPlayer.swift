//
//  RCVideoPlayer.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/5/8.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit
import AVFoundation

enum ThumbnailGeneratedError: LocalizedError {
    
    case failToGenerateThumbnail
}

class RCVideoPlayer {
    
    let avPlayer = AVPlayer()
    
    var avPlayerLayer: AVPlayerLayer!
    
    let rcVideoPlayerView = RCVideoPlayerView()
    
    func setUpAVPlayer(with view: UIView, videoUrl: URL, videoGravity: AVLayerVideoGravity) {

        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = videoGravity
                
        view.layer.addSublayer(avPlayerLayer)
        
        let playerItem = AVPlayerItem(url: videoUrl)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        setUpPlayerView()
    }
    
    func play() {
        
        avPlayer.play()
    }
    
    func pause() {
        
        avPlayer.pause()
    }
    
    func mute(_ status: Bool) {
        
        avPlayer.isMuted = status
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
        
        let asset = AVURLAsset(url: path, options: nil)
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        imageGenerator.appliesPreferredTrackTransform = true
        
        imageGenerator.maximumSize = CGSize(width: 300, height: 300)
        
        do {
            
            let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            
            return UIImage(cgImage: cgImage)
            
        } catch {
            
            print("Error generating thumbnail: \(error.localizedDescription)")
            
            return nil
        }
    }
}

extension RCVideoPlayer {
    
    // Private Method
    private func setUpPlayerView() {
        
        rcVideoPlayerView.alpha = 0.0
        
        rcVideoPlayerView.avPlayer = avPlayer
        rcVideoPlayerView.avPlayerLayer = avPlayerLayer

        rcVideoPlayerView.fetchDuration()
        rcVideoPlayerView.fetchCurrentTime()
    }
}
