//
//  CameraManager.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/5/29.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol CameraManagerDelegate: AnyObject {
    
    func manager(_ manager: CameraManager, outputUrl: URL?)
}

class CameraManager {
    
    weak var delegate: CameraManagerDelegate?
    
    let captureSession = AVCaptureSession()
    
    var movieOutput = AVCaptureMovieFileOutput()
    
    var activeInput: AVCaptureDeviceInput?
    
    func setUpVideoLayer(in view: UIView) {
        
        let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.frame = view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        view.layer.addSublayer(videoLayer)
        
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
            
            DispatchQueue.main.async { [weak self] in
                
                self?.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        
        if captureSession.isRunning {
            
            DispatchQueue.main.async { [weak self] in
                
                self?.captureSession.stopRunning()
            }
        }
    }
    
    private func currentVideoOrientation() -> AVCaptureVideoOrientation {
        
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
    
    private func tmpUrl() -> URL? {
        
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            
            let path = directory.appendingPathComponent(UUID().uuidString + ".mp4")
            
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    func startRecording() -> AVCaptureMovieFileOutput? {
        
        if movieOutput.isRecording == false {
            
            guard let connection = movieOutput.connection(with: .video) else { return nil }
            
            if connection.isVideoOrientationSupported {
                
                connection.videoOrientation = currentVideoOrientation()
            }
            
            if connection.isVideoStabilizationSupported {
                
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            guard let device = activeInput?.device else { return nil }
            
            if device.isSmoothAutoFocusEnabled {
                
                do {
                    
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                    
                } catch {
                    
                    print("Error setting configuration: \(error)")
                }
            }
            
            delegate?.manager(self, outputUrl: tmpUrl())
        }
        
        return movieOutput
    }
    
    func stopRecording() {
        
        if movieOutput.isRecording == true {
            
            movieOutput.stopRecording()
        }
    }
}
