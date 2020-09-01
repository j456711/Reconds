//
//  RCVideoPlayer.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/6.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit
import AVFoundation

class RCVideoPlayerView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var aspectButton: UIButton!
    
    @IBOutlet weak var slider: UISlider! {
        didSet {
            slider?.setThumbImage(UIImage.assets(.Slider_64px_Thumb), for: .normal)
        }
    }
    
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)

        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
}

// MARK: - Actions
extension RCVideoPlayerView {
    
    @IBAction func playPauseButtonPressed(_ sender: UIButton) {

        if playPauseButton.imageView?.image == UIImage.assets(.Icon_PauseController) {

            avPlayer?.pause()

            playPauseButton.setImage(UIImage.assets(.Icon_PlayController), for: .normal)

        } else {

            avPlayer?.play()

            playPauseButton.setImage(UIImage.assets(.Icon_PauseController), for: .normal)
        }
    }

    @IBAction func aspectButtonPressed(_ sender: UIButton) {

        if aspectButton.imageView?.image == UIImage.assets(.Icon_128px_Expand) {
            
            aspectButton.setImage(.assets(.Icon_128px_Minimize), for: .normal)

            avPlayerLayer?.setAffineTransform(CGAffineTransform(rotationAngle: .pi / 2))
            avPlayerLayer?.frame = UIScreen.main.bounds
            avPlayerLayer?.videoGravity = .resizeAspect

            self.transform = CGAffineTransform(rotationAngle: .pi / 2)
            self.frame = CGRect(x: 8, y: 28,
                                width: 74, height: UIScreen.main.bounds.height - 36)
            
        } else {
            
            aspectButton.setImage(.assets(.Icon_128px_Expand), for: .normal)

            avPlayerLayer?.setAffineTransform(CGAffineTransform.identity)
            avPlayerLayer?.frame = UIScreen.main.bounds
            avPlayerLayer?.videoGravity = .resizeAspect

            self.transform = CGAffineTransform.identity
            self.frame = CGRect(x: 8, y: UIScreen.main.bounds.height - 82,
                                width: UIScreen.main.bounds.width - 16, height: 74)
        }
    }

    @IBAction func sliderMoved(_ sender: UISlider) {

        let seconds = Int64(slider.value)
        let targetTime = CMTimeMake(value: seconds, timescale: 1)

        avPlayer?.seek(to: targetTime)
    }
}

extension RCVideoPlayerView {

    func fetchDuration() {
        
        guard let duration = avPlayer?.currentItem?.asset.duration else { return }
        
        let second = CMTimeGetSeconds(duration)
        
        endTimeLabel.text = timeFormatConversion(time: second)
        
        slider.maximumValue = Float(second)
        
        print(slider.maximumValue)
        
        slider.isContinuous = true
    }
    
    func fetchCurrentTime() {
        
        let cmTime = CMTimeMake(value: 1, timescale: 1)
        
        guard let avPlayer = avPlayer else { return }
        
        avPlayer.addPeriodicTimeObserver(forInterval: cmTime, queue: DispatchQueue.main, using: { [weak self] (_) in
            
            guard let strongSelf = self else { return }
            
            if avPlayer.currentItem?.status == .readyToPlay {
                
                let currentTime = CMTimeGetSeconds(avPlayer.currentTime())
                
                strongSelf.currentTimeLabel.text = strongSelf.timeFormatConversion(time: currentTime)
                
                strongSelf.slider.value = Float(currentTime)
            }
        })
    }
}

// MARK: - Private Methods
extension RCVideoPlayerView {
    
    private func initView() {
        
        Bundle.main.loadNibNamed(String(describing: RCVideoPlayerView.self),
                                 owner: self,
                                 options: nil)
                
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        
        addSubview(contentView)
    }
    
    private func timeFormatConversion(time: Float64) -> String {

        let videoLength = Int(time)

        let minutes = Int(videoLength / 60) // 求 songLength 的商，為分鐘數
        let seconds = Int(videoLength % 60) // 求 songLength 的餘數，為秒數

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
