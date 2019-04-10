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

        if controlButton.imageView?.image == UIImage.assets(.Icon_PauseController) {

            rcVideoPlayer.pause()

            controlButton.setImage(UIImage.assets(.Icon_PlayController), for: .normal)

        } else {

            rcVideoPlayer.play()

            controlButton.setImage(UIImage.assets(.Icon_PauseController), for: .normal)
        }
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
        
        //Data
        guard let videoData = try? Data(contentsOf: videoUrl) else { return }
        
        //Path
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        guard let documentsDirectory = paths.first else { return }

        let time = String(Int(Date().timeIntervalSince1970))
        
        let dataPath = documentsDirectory.appendingPathComponent("\(time).mp4")
        
        do {
            
            try videoData.write(to: dataPath)
            
            guard var videoUrls = UserDefaults.standard.array(forKey: "VideoUrls") as? [String] else { return }
            
            videoUrls.append(dataPath.absoluteString)
            
            print(videoUrls)
            
            UserDefaults.standard.set(videoUrls, forKey: "VideoUrls")
            
        } catch {
            
            print(error)
        }

//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
//            let tabbar = appDelegate.window?.rootViewController as? TabBarController,
//            let navVC = tabbar.viewControllers?.first as? UINavigationController,
//            let homeVC = navVC.viewControllers.first as? HomeViewController {
//
//            homeVC.videoUrl = self.videoUrl
//            homeVC.videoUrls.append(videoUrl)
//        }

        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(videoDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: rcVideoPlayer.avPlayer.currentItem)
    }

    override func viewDidAppear(_ animated: Bool) {

        rcVideoPlayer.setUpAVPlayer(with: self.view, videoUrl: videoUrl, videoGravity: .resizeAspect)
        rcVideoPlayer.fetchDuration(disPlayOn: endTimeLabel, setMaximumValueOn: slider)
        rcVideoPlayer.fetchCurrentTime(disPlayOn: startTimeLabel, setValueOn: slider)

        view.bringSubviewToFront(playButton)
        view.bringSubviewToFront(controlView)
        view.bringSubviewToFront(rcVideoPlayerView)
    }

    @objc func videoDidFinishPlaying() {

        playButton.isHidden = false

        controlView.isHidden = false

        rcVideoPlayerView.isHidden = true

        rcVideoPlayer.avPlayer.seek(to: CMTime.zero)
    }
}
