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
    
    let rcVideoPlayer = RCVideoPlayer()
    
    var videoUrl: URL!
    
    @IBOutlet weak var controlView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    
    
    @IBOutlet weak var rcVideoPlayerView: UIView! {
        
        didSet {
            
            rcVideoPlayerView.layer.cornerRadius = 10
            
            rcVideoPlayerView.isHidden = true
        }
    }
    
    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var slider: UISlider! {
        
        didSet {
            
            slider.setThumbImage(UIImage.assets(.Slider_Thumb), for: .normal)
        }
    }
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        
        let seconds = Int64(slider.value)
        
        let targetTime = CMTimeMake(value: seconds, timescale: 1)
        
        rcVideoPlayer.avPlayer.seek(to: targetTime)
    }
    
    @IBOutlet weak var controlButton: UIButton!
    
    @IBAction func controlButtonPressed(_ sender: UIButton) {
        
        rcVideoPlayer.pause()
    }
    
    
    @IBAction func playButtonPressed(_ sender: UIButton) {

        rcVideoPlayer.play()
        
        playButton.isHidden = true
        
        controlView.isHidden = true
        
        rcVideoPlayerView.isHidden = false
    }
    
    @IBAction func retakeButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func useButtonPressed(_ sender: UIButton) {

        let videoData = NSData(contentsOf: videoUrl)

        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)

        let documentsDirectory = paths[0] as NSString

        let dataPath = documentsDirectory.appendingPathComponent(videoUrl.path)

        videoData?.write(toFile: dataPath, atomically: false)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let tabbar = appDelegate.window?.rootViewController as? TabBarController,
            let navVC = tabbar.viewControllers?.first as? UINavigationController,
            let homeVC = navVC.viewControllers.first as? HomeViewController {
            
            homeVC.videoUrl = self.videoUrl
            homeVC.videoUrls.append(videoUrl)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: rcVideoPlayer.avPlayer.currentItem)
    }

    override func viewDidAppear(_ animated: Bool) {

        rcVideoPlayer.setUpAVPlayer(with: self.view, videoUrl: videoUrl)

        view.bringSubviewToFront(playButton)
        view.bringSubviewToFront(controlView)
        view.bringSubviewToFront(rcVideoPlayerView)
    }
    
    @objc func videoDidFinishPlaying() {
        
        playButton.isHidden = false
        
        controlView.isHidden = false
        
        rcVideoPlayerView.isHidden = true
    }
}
