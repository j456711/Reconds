//
//  CameraViewController.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/4.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class CameraViewController: UIViewController {

    private struct Segue {

        static let showVideoPlayback = "ShowVideoPlayback"
    }
    
    let cameraButton = UIView()

    let captureSession = AVCaptureSession()
    
    var movieOutput = AVCaptureMovieFileOutput()
    
    var activeInput: AVCaptureDeviceInput?

    var outputUrl: URL?
    
    let cameraButtonLayer = CAShapeLayer()  //使用CAShapeLayer製作動畫

    let cancelButton = UIButton()

    @IBOutlet weak var authorizedView: UIView!
    
    @IBAction func authorizedButtonPressed(_ sender: UIButton) {
    
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))

        self.view.addGestureRecognizer(gesture)
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            
        case .notDetermined, .denied, .restricted:
            
            self.view.bringSubviewToFront(authorizedView)
            
        case .authorized:
            
            if setUpCaptureSession() {
                
                authorizedView.isHidden = true
                
                setUpVideoLayer()
                
                setUpProgressBar()
                
                setUpCancelButton()
                
                startSession()
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
                
                if filteredArray.count == 25 {
                    
                    UIAlertController.addConfirmAlertWith(viewController: self,
                                                          alertTitle: "無法新增影片",
                                                          alertMessage: "影片數量已達到上限，快去輸出吧！",
                                                          actionHandler: { [weak self] (_) in
                                                            
                        self?.dismiss(animated: true, completion: nil)
                    })
                    
                } else {
                    
                    startRecording()
                }
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        
        return true
    }

    func setUpCancelButton() {

        cancelButton.frame = CGRect(x: 16, y: UIScreen.main.bounds.height - 90, width: 45, height: 40)
        cancelButton.setTitle("返回", for: .normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)

        self.view.addSubview(cancelButton)
    }

    @objc func cancelButtonAction() {

        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == Segue.showVideoPlayback {

            guard let videoPlaybackVC = segue.destination as? VideoPlaybackViewController else { return }

            videoPlaybackVC.videoUrl = sender as? URL
        }
    }
    
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

// MARK: - Camera Setting
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {

    func setUpVideoLayer() {

        let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.frame = self.view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        self.view.layer.addSublayer(videoLayer)

        captureSession.startRunning()
    }

    func setUpCaptureSession() -> Bool {

        captureSession.sessionPreset = AVCaptureSession.Preset.high

        // Setup Camera
        guard let camera = AVCaptureDevice.default(for: .video) else { return false }

        do {
            
            let input = try AVCaptureDeviceInput(device: camera)

            if captureSession.canAddInput(input) {

                captureSession.addInput(input)

                activeInput = input
            }

        } catch {

            print("Error setting device video input: \(error)")

            return false
        }

        // Setup Microphone
        guard let microphone = AVCaptureDevice.default(for: .audio) else { return false }

        do {

            let microphoneInput = try AVCaptureDeviceInput(device: microphone)

            if captureSession.canAddInput(microphoneInput) {

                captureSession.addInput(microphoneInput)
            }

        } catch {

            print("Error setting device audio input: \(error)")

            return false
        }

        // Movie Output
        if captureSession.canAddOutput(movieOutput) {
            
            captureSession.addOutput(movieOutput)
        }

        return true
    }

    // Camera Sesion
    func startSession() {

        if !captureSession.isRunning {

            DispatchQueue.main.async {

                self.captureSession.startRunning()
            }
        }
    }

    func stopSession() {

        if captureSession.isRunning {

            DispatchQueue.main.async {

                self.captureSession.stopRunning()
            }
        }
    }

    func currentVideoOrientation() -> AVCaptureVideoOrientation {

        var orientation: AVCaptureVideoOrientation

        switch UIDevice.current.orientation {

        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait

        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft

        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown

        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }

        return orientation
    }

    func tempUrl() -> URL? {

        let directory = NSTemporaryDirectory() as NSString

        if directory != "" {

            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")

            return URL(fileURLWithPath: path)
        }

        return nil
    }

    func startRecording() {
        
        if movieOutput.isRecording == false {
            
            guard let connection = movieOutput.connection(with: AVMediaType.video) else { return }

            if connection.isVideoOrientationSupported {

                connection.videoOrientation = currentVideoOrientation()
            }

            if connection.isVideoStabilizationSupported {

                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }

            guard let device = activeInput?.device else { return }

            if device.isSmoothAutoFocusEnabled {

                do {

                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()

                } catch {

                    print("Error setting configuration: \(error)")
                }
            }

            outputUrl = tempUrl()
            
            movieOutput.startRecording(to: outputUrl!, recordingDelegate: self)
        }
    }

    func stopRecording() {

        if movieOutput.isRecording == true {
            
            movieOutput.stopRecording()
        }
    }

    // AVCaptureFileOutputRecordingDelegate Method
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

            self.performSegue(withIdentifier: Segue.showVideoPlayback, sender: videoUrl)
        }
    }
}

// MARK: - Animation
extension CameraViewController: CAAnimationDelegate {

    func setUpProgressBar() {

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

    func setUpTrackLayer() {

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
    func strokeAnimationStarted() {

        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")

        strokeAnimation.delegate = self
        strokeAnimation.toValue = 1
        strokeAnimation.duration = 1.0 //動畫維持
        strokeAnimation.fillMode = .forwards

        cameraButtonLayer.add(strokeAnimation, forKey: "basic")
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {

        DispatchQueue.main.async {

            self.stopRecording()
        }
    }
}
