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

    let captureSession = AVCaptureSession()
    
    let cameraButtonLayer = CAShapeLayer()  //使用CAShapeLayer製作動畫
    
    let cancelButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCameraView()
        
        setUpProgressBar()
        
        setUpCancelButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        let point = touch.location(in: self.view)
        
        if cameraButtonLayer.path!.contains(point) {
            
            cameraButtonLayerTapped()
        }
    }
    
    func setUpCancelButton() {
        
        cancelButton.frame = CGRect(x: 16, y: UIScreen.main.bounds.height - 90, width: 45, height: 40)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        
        self.view.addSubview(cancelButton)
    }
    
    @objc func cancelButtonAction() {
        
        dismiss(animated: true, completion: nil)
    }
    
    func setUpCameraView() {
        
        guard let camera = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: camera) else { return }
        
        captureSession.addInput(input)
        
        let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.frame = self.view.bounds
        
        self.view.layer.addSublayer(videoLayer)
        
        captureSession.startRunning()
        
        saveOutput()
    }
    
    func saveOutput() {
        
        captureSession.beginConfiguration()
        
        guard captureSession.canSetSessionPreset(captureSession.sessionPreset) else { return }
        
        captureSession.sessionPreset = .hd1920x1080
        
        let output = AVCaptureVideoDataOutput()
        
        guard captureSession.canAddOutput(output) else { return }
        
        captureSession.addOutput(output)
        
        captureSession.commitConfiguration()
    }
    
}

extension CameraViewController {
    
    func setUpProgressBar() {
        
        let center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 70)  //設定圖案的位置
        
        let circularPath = UIBezierPath(arcCenter: center, radius: 30, startAngle: -(.pi / 2), endAngle: (.pi * 2), clockwise: true)  //使用UIBezierPath製作圓形
        
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
        
        let circularPath = UIBezierPath(arcCenter: center, radius: 30, startAngle: -(.pi / 2), endAngle: (.pi * 2), clockwise: true)  //使用UIBezierPath製作圓形
        
        let trackLayer = CAShapeLayer()
        
        trackLayer.path = circularPath.cgPath
        
        trackLayer.fillColor = UIColor.white.cgColor
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        
        trackLayer.lineWidth = 5
        
        view.layer.addSublayer(trackLayer)
    }
    
    //紅線動畫
    func cameraButtonLayerTapped() {
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 1
        
        basicAnimation.duration = 1 //動畫維持
        
        basicAnimation.fillMode = .forwards
        
        basicAnimation.isRemovedOnCompletion = false //動畫完成後不要移除紅線
        
        cameraButtonLayer.add(basicAnimation, forKey: "basic")
    }
}
