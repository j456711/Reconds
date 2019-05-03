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
    
    let rcVideoPlayer = RCVideoPlayer()

    var videoUrl: URL?

    @IBOutlet weak var controlView: UIView!

    @IBOutlet weak var retakeButton: UIButton!
    
    @IBOutlet weak var useButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!

    @IBOutlet weak var rcVideoPlayerView: UIView! {

        didSet {

            rcVideoPlayerView.layer.cornerRadius = 10

//            rcVideoPlayerView.isHidden = true
            rcVideoPlayerView.alpha = 0.0
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
    
    @IBOutlet weak var zoomButton: UIButton!

    @IBAction func controlButtonPressed(_ sender: UIButton) {

        if controlButton.imageView?.image == UIImage.assets(.Icon_PauseController) {

            rcVideoPlayer.pause()

            controlButton.setImage(UIImage.assets(.Icon_PlayController), for: .normal)

        } else {

            rcVideoPlayer.play()

            controlButton.setImage(UIImage.assets(.Icon_PauseController), for: .normal)
        }
    }
    
    @IBAction func zoomButtonPressed(_ sender: UIButton) {
        
        switch zoomButton.imageView?.image {
            
        case UIImage.assets(.Icon_128px_Expand):
            zoomButton.setImage(.assets(.Icon_128px_Minimize), for: .normal)
        
            rcVideoPlayer.avPlayerlayer.setAffineTransform(CGAffineTransform(rotationAngle: .pi / 2))
            rcVideoPlayer.avPlayerlayer.frame = self.view.layer.bounds
            rcVideoPlayer.avPlayerlayer.videoGravity = .resizeAspect
            
            rcVideoPlayerView.transform = CGAffineTransform(rotationAngle: .pi / 2)
            rcVideoPlayerView.frame = CGRect(x: 8,
                                             y: 28,
                                             width: 74,
                                             height: UIScreen.main.bounds.height - 36)
            
        case UIImage.assets(.Icon_128px_Minimize):
            zoomButton.setImage(.assets(.Icon_128px_Expand), for: .normal)
            
            rcVideoPlayer.avPlayerlayer.setAffineTransform(CGAffineTransform.identity)
            rcVideoPlayer.avPlayerlayer.frame = self.view.layer.bounds
            rcVideoPlayer.avPlayerlayer.videoGravity = .resizeAspect
            
            rcVideoPlayerView.transform = CGAffineTransform.identity
            rcVideoPlayerView.frame = CGRect(x: 8,
                                             y: UIScreen.main.bounds.height - 82,
                                             width: UIScreen.main.bounds.width - 16,
                                             height: 74)
            
        default: break
        }
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {

        rcVideoPlayer.avPlayer.seek(to: CMTime.zero)
        rcVideoPlayer.play()

        controlView.alpha = 0.0
        
        playButton.isHidden = true

//        rcVideoPlayerView.isHidden = false
        rcVideoPlayerView.alpha = 1.0
    }

    @IBAction func retakeButtonPressed(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func useButtonPressed(_ sender: UIButton) {
        
        guard let videoUrl = videoUrl,
              let videoData = try? Data(contentsOf: videoUrl) else { return }
        
        let time = Int(Date().timeIntervalSince1970)
        
        let fileName = "\(time).mp4"
        
        let dataPath = FileManager.videoDataDirectory.appendingPathComponent(fileName)
        
        do {
            
            try videoData.write(to: dataPath)
            
            let videoData = StorageManager.shared.fetch(VideoData.self)
            
            guard let filteredArray = StorageManager.shared.filterData() else { return }
            
            videoData[0].dataPathArray.insert(fileName, at: filteredArray.count)
            
            videoData[0].dataPathArray.removeLast()
                
            StorageManager.shared.save()
//            }
            
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
        
        view.addSubview(rcVideoPlayerView)
        
        rcVideoPlayerView.frame = CGRect(x: 8,
                                         y: UIScreen.main.bounds.height - 82,
                                         width: UIScreen.main.bounds.width - 16,
                                         height: 74)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(videoDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: rcVideoPlayer.avPlayer.currentItem)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        panGesture.delegate = self
        self.view.addGestureRecognizer(panGesture)

        guard let videoUrl = videoUrl else { return }
        
        rcVideoPlayer.setUpAVPlayer(with: self.view, videoUrl: videoUrl, videoGravity: .resizeAspect)
        rcVideoPlayer.fetchDuration(disPlayOn: endTimeLabel, setMaximumValueOn: slider)
        rcVideoPlayer.fetchCurrentTime(disPlayOn: startTimeLabel, setValueOn: slider)
        
        view.bringSubviewToFront(controlView)
        view.bringSubviewToFront(playButton)
        view.bringSubviewToFront(rcVideoPlayerView)
    }
    
    override var prefersStatusBarHidden: Bool {
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if controlView.alpha == 1.0 {
            
            rcVideoPlayerView.alpha = 0.0
            
        } else {
            
            if rcVideoPlayerView.alpha == 1.0 {
                
                rcVideoPlayerView.alpha = 0.0
                
            } else {
                
                rcVideoPlayerView.alpha = 1.0
            }
        }
    }
    
    @objc func videoDidFinishPlaying() {

        controlView.alpha = 1.0
        
        playButton.isHidden = false
        
//        rcVideoPlayerView.isHidden = true
        rcVideoPlayerView.alpha = 0.0
    }
}

// MARK: - Gesture
extension VideoPlaybackViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view is UISlider {
            
            return false
            
        } else {
            
            return true
        }
    }
}

extension VideoPlaybackViewController {
    
    @objc func panAction(_ gesture: UIGestureRecognizer) {

        var initialTouchPoint = CGPoint(x: 0, y: 0)

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
