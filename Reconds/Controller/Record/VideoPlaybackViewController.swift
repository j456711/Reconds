//
//  VideoPlaybackViewController.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/6.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class VideoPlaybackViewController: UIViewController {

    var initialTouchPoint = CGPoint(x: 0, y: 0)
    
    let rcVideoPlayer = RCVideoPlayer()

    var videoUrl: URL!
    
    @IBOutlet weak var controlView: UIView!

    @IBOutlet weak var retakeButton: UIButton!
    
    @IBOutlet weak var useButton: UIButton!
    
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
        
        let time = Int(Date().timeIntervalSince1970)
        
        let fileName = "\(time).mp4"
        
        let dataPath = FileManager.documentDirectory.appendingPathComponent(fileName)
        
        do {
            
            try videoData.write(to: dataPath)
            
            let videoData = VideoDataManager.shared.fetch(VideoData.self)
            
            if videoData.count == 0 {
                
                createData(fileName: fileName)
                
            } else {
                
                videoData[0].dataPathArray.append(fileName)
                
                VideoDataManager.shared.save()                
            }
            
//            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
//                let tabbar = appDelegate.window?.rootViewController as? TabBarController,
//                let navVC = tabbar.viewControllers?.first as? UINavigationController,
//                let homeVC = navVC.viewControllers.first as? HomeViewController {
//
//                homeVC.tmpVideoData.append(fileName)
//            }

        } catch {
            
            print(error)
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(videoDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: rcVideoPlayer.avPlayer.currentItem)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        
        self.view.addGestureRecognizer(gesture)
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

// MARK: - Gesture
extension VideoPlaybackViewController {
    
    @objc func panAction(_ gesture: UIGestureRecognizer) {
        
        let touchPoint = gesture.location(in: self.view.window)
        
        switch gesture.state {
            
        case .began:
            initialTouchPoint = touchPoint

        case .changed:
            if touchPoint.y - initialTouchPoint.y > 0 {
                
                self.view.frame = CGRect(x: 0,
                                         y: (touchPoint.y - initialTouchPoint.y),
                                         width: self.view.frame.size.width,
                                         height: self.view.frame.size.height)
            }
            
        case .ended, .cancelled:
            if touchPoint.y - initialTouchPoint.y > 100 {
                
                self.dismiss(animated: true, completion: nil)
                
            } else {
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.view.frame = CGRect(x: 0,
                                             y: 0,
                                             width: self.view.frame.size.width,
                                             height: self.view.frame.size.height)
                })
            }

        default: break
        }
    }
}

// MARK: - CoreData Function
extension VideoPlaybackViewController {
    
    func createData(fileName: String) {
        
        let videoData = VideoData(context: VideoDataManager.shared.persistantContainer.viewContext)
        
        videoData.dataPathArray.append(fileName)
        
        VideoDataManager.shared.save()
    }
}
