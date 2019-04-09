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
//
//    let avPlayer = AVPlayer()
//
//    var avPlayerlayer: AVPlayerLayer!
    
    let rcVideoPlayer = RCVideoPlayer()
    
    var videoUrl: URL!
    
    @IBOutlet weak var controlView: UIView! 
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func playButtonPressed(_ sender: UIButton) {

        rcVideoPlayer.play()
        
        playButton.isHidden = true
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
        
//        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
    }

    override func viewDidAppear(_ animated: Bool) {

        rcVideoPlayer.setUpAVPlayer(with: self.view, videoUrl: videoUrl)

        view.bringSubviewToFront(controlView)
        view.bringSubviewToFront(playButton)

    }
    
    @objc func videoDidFinishPlaying() {
        
        playButton.isHidden = false
    }
}
