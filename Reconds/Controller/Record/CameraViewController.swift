//
//  CameraViewController.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/4.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    private struct Segue {

        static let showVideoPlaybackVC = "ShowVideoPlaybackVC"
    }
    
    let cameraManager = CameraManager()

    let cameraButton = UIButton()

    let flashButton = UIButton()
    
    let cancelButton = UIButton()
    
    let cameraButtonLayer = CAShapeLayer()  //使用CAShapeLayer製作動畫

    var outputUrl: URL?

    @IBOutlet weak var authorizedView: UIView!
    
    @IBAction func authorizedButtonPressed(_ sender: UIButton) {
    
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                
                if granted == true {
                    
                    AVAudioSession.sharedInstance().requestRecordPermission({ [weak self] granted in
                        
                        guard let strongSelf = self else { return }
                        
                        if granted == true {
                            
                            DispatchQueue.main.async {
                                
                                if strongSelf.cameraManager.setUpCaptureSession() {
                                    
                                    strongSelf.authorizedView.isHidden = true
                                    
                                    strongSelf.cameraManager.setUpVideoLayer(in: strongSelf.view)
                                    
                                    strongSelf.setUpProgressBar()
                                    
                                    strongSelf.setUpCancelButton()
                                    
                                    strongSelf.cameraManager.startSession()
                                }
                            }
                        }
                    })
                }
            })
            
        case .denied, .restricted:
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }

        case .authorized: break
        default: break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraManager.delegate = self
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        
        authorizedView.addGestureRecognizer(gesture)
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {

        case .notDetermined, .denied, .restricted:
            self.view.bringSubviewToFront(authorizedView)

        case .authorized:
            if cameraManager.setUpCaptureSession() {

                authorizedView.isHidden = true

                cameraManager.setUpVideoLayer(in: self.view)

                setUpProgressBar()

                setUpCancelButton()

//                setUpFlashButton()
                
                cameraManager.startSession()
            }

        default: break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let touch = touches.first else { return }

        let point = touch.location(in: self.view)

        if let path = cameraButtonLayer.path {
        
            if path.contains(point) {
                
                guard let filteredArray = StorageManager.shared.filterData() else { return }
                
                if filteredArray.count == 9 {
                    
                    UIAlertController.addConfirmAlertWith(viewController: self,
                                                          alertTitle: "無法新增影片",
                                                          alertMessage: "影片數量已達上限，請刪除影片或進行輸出。",
                                                          actionHandler: { [weak self] (_) in
                                                            
                        self?.dismiss(animated: true, completion: nil)
                    })
                    
                } else {
                    
                    let movieOutput = cameraManager.startRecording()
                    movieOutput?.startRecording(to: outputUrl!, recordingDelegate: self)
                }
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let videoPlaybackVC = segue.destination as? VideoPlaybackViewController else { return }

        videoPlaybackVC.videoUrl = sender as? URL
    }
    
    func setUpCancelButton() {
        
        cancelButton.frame = CGRect(x: 24, y: UIScreen.main.bounds.height - 90, width: 50, height: 45)
        cancelButton.setTitle("返回", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 22)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        
        self.view.addSubview(cancelButton)
    }
    
    @objc func cancelButtonAction() {
        
        dismiss(animated: true, completion: nil)
    }
    
//    func setUpFlashButton() {
//
//        flashButton.frame =  CGRect(x: UIScreen.main.bounds.width - 80,
//                                    y: UIScreen.main.bounds.height - 90,
//                                    width: 50,
//                                    height: 45)
//        flashButton.setImage(UIImage.assets(.Icon_35px_Flash_Off), for: .normal)
//        flashButton.addTarget(self, action: #selector(flashButtonAction), for: .touchUpInside)
//
//        self.view.addSubview(flashButton)
//    }
    
//    @objc func flashButtonAction() {
//
//         guard let device = activeInput?.device else { return }
//
//        if flashButton.imageView?.image == UIImage.assets(.Icon_35px_Flash_On) {
//
//            flashButton.setImage(UIImage.assets(.Icon_35px_Flash_Off), for: .normal)
//
//            if device.isFlashAvailable {
//
//            }
//
//        } else if flashButton.imageView?.image == UIImage.assets(.Icon_35px_Flash_Off) {
//
//            flashButton.setImage(UIImage.assets(.Icon_35px_Flash_On), for: .normal)
//        }
//    }
}

// MARK: - Camera Setting
extension CameraViewController: CameraManagerDelegate {
    
    func manager(_ manager: CameraManager, outputUrl: URL?) {
        
        self.outputUrl = outputUrl
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {

    func fileOutput(_ output: AVCaptureFileOutput,
                    didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
        strokeAnimationStarted()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if error != nil {

            print("Error recording movie: \(error!.localizedDescription)")

        } else {

            guard let videoUrl = outputUrl else { return }

            self.performSegue(withIdentifier: Segue.showVideoPlaybackVC, sender: videoUrl)
        }
    }
}

// MARK: - Gesture
extension CameraViewController {
    
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

// MARK: - Animation
extension CameraViewController {

    private func setUpProgressBar() {

        let center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 70)  //設定圖案的位置

        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: 30, startAngle: -(.pi / 2), endAngle: (.pi * 2), clockwise: true)
        
        cameraButtonLayer.path = circularPath.cgPath
        cameraButtonLayer.fillColor = UIColor.clear.cgColor
        cameraButtonLayer.strokeColor = UIColor.red.cgColor
        cameraButtonLayer.lineWidth = 5
        cameraButtonLayer.strokeEnd = 0

        setUpTrackLayer()

        view.layer.addSublayer(cameraButtonLayer)
    }

    private func setUpTrackLayer() {

        let center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 70)  //設定圖案的位置

        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: 30, startAngle: -(.pi / 2), endAngle: (.pi * 2), clockwise: true)

        let trackLayer = CAShapeLayer()

        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.white.cgColor
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 5

        view.layer.addSublayer(trackLayer)
    }

    //紅線動畫
    private func strokeAnimationStarted() {
        
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        strokeAnimation.delegate = self
        strokeAnimation.toValue = 1
        strokeAnimation.duration = 3.0 //動畫維持
        strokeAnimation.fillMode = .forwards
        
        cameraButtonLayer.add(strokeAnimation, forKey: "basic")
    }
}

extension CameraViewController: CAAnimationDelegate {

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.cameraManager.stopRecording()
        }
    }
}
