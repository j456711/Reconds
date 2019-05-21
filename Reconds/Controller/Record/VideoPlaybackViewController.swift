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
    
    lazy var rcVideoPlayerView = rcVideoPlayer.rcVideoPlayerView
    
    var videoUrl: URL?
    
    @IBOutlet weak var controlView: UIView!

    @IBOutlet weak var retakeButton: UIButton!
    
    @IBOutlet weak var useButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func playButtonPressed(_ sender: UIButton) {

        rcVideoPlayer.avPlayer.seek(to: .zero)
        rcVideoPlayer.play()

        controlView.alpha = 0.0
        
        rcVideoPlayerView.alpha = 1.0

        playButton.isHidden = true
    }

    @IBAction func retakeButtonPressed(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func useButtonPressed(_ sender: UIButton) {
        
        DataManager.shared.dataSaved(videoUrl: videoUrl, completionHandler: { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success:
                JYProgressHUD.shared.showSuccess(in: strongSelf.view)
                
            case .failure(let error):
                JYProgressHUD.shared.showFailure(in: strongSelf.view)
                
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                strongSelf.dismiss(animated: true, completion: nil)
            })
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let videoUrl = videoUrl {
            
            rcVideoPlayer.setUpAVPlayer(with: self.view, videoUrl: videoUrl, videoGravity: .resizeAspect)
        }
        
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
        
        view.bringSubviewToFront(controlView)
        view.bringSubviewToFront(playButton)
    }
   
    override var prefersStatusBarHidden: Bool {
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        if touch.view != rcVideoPlayerView.contentView {
            
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
    }
    
    @objc func videoDidFinishPlaying() {

        controlView.alpha = 1.0
        
        playButton.isHidden = false
        
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
