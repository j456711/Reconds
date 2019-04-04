//
//  RecordViewController.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/2.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        setUpCamera()
    }
    
    func setUpCamera() {
        
        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera)
            else { return }
        
        captureSession.addInput(input)
        
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.frame = self.view.bounds
        
        self.view.layer.addSublayer(layer)
        
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


extension RecordViewController {
 
    
}
