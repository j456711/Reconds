//
//  MergeVideoManager.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/15.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import UIKit

enum MergeVideoError: LocalizedError {
    
    case failedToLoadVideoTrack
    case failedToLoadAudioTrack
}

class MergeVideoManager {
    
    static let shared = MergeVideoManager()
    
    let defaultSize = CGSize(width: 1920, height: 1080)
    
    typealias ExportedHandler = ((URL?, String?, Error?) -> Void)
    
    func mergeVideos(arrayVideos: [AVAsset], completionHandler: @escaping ExportedHandler) {
        
        var insertTime = CMTime.zero
        
        var arrayLayerInstructions: [AVMutableVideoCompositionLayerInstruction] = []
        
        var outputSize = CGSize(width: 0, height: 0)

        // Determine video output size
        for videoAsset in arrayVideos {

            // 獲得影片軌道
            let videoTrack = videoAsset.tracks(withMediaType: .video)[0]

            // 因為原本的影片不論直拍橫拍都會變成直向的畫面，所以利用 method 去協助取得正確的影片方向
            let assetInfo = orientationFromTransform(transform: videoTrack.preferredTransform)
            
            // 得到影片原始長寬，不論直拍橫拍都是 1920 x 1080
            var videoSize = videoTrack.naturalSize
            
//            print("start", videoTrack.preferredTransform)
            
            // 如果是直拍的話，就把影片尺寸轉成 1080 x 1920
            if assetInfo.isPortrait == true {

                videoSize.width = videoTrack.naturalSize.height
                videoSize.height = videoTrack.naturalSize.width
            }

            // 如果每個影片都保持橫向，最後得到的 outputSize 就會是 1920 x 1080
            // 只要其中有一個影片是直向，因為上面有做直拍尺寸轉換的判斷，所以之後的 outputSize 就一直會是 1080 x 1920
            if videoSize.height > outputSize.height {

                outputSize = videoSize
            }
        }

        if outputSize.width == 0 || outputSize.height == 0 {

            outputSize = defaultSize
        }

        // Init composition
        let mixComposition = AVMutableComposition()
        
        for videoAsset in arrayVideos {

            // 取得影像軌道和聲音軌道
            let videoTrack = videoAsset.tracks(withMediaType: .video)[0]
            let audioTrack = videoAsset.tracks(withMediaType: .audio)[0]
            
            // Init video & audio composition track
            guard let videoCompositionTrack =
                mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
                let audioCompositionTrack =
                mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                else { return }
            
            // 這裡出來的結果是：會幫 videoAsset 個別製作一個 video 跟 audio 的 mutable track
            // 假設總共有 4 個 videoAsset，就會產生 8 個 mutable track， video 跟 audio 各 4 個
            //            print("videoCompositionTrack", videoCompositionTrack)
            //            print("audioCompositionTrack", audioCompositionTrack)
            
            let timeRange = CMTimeRangeMake(start: .zero, duration: videoAsset.duration)

            do {

                // Add video track to video composition at specific time
                try videoCompositionTrack.insertTimeRange(timeRange, of: videoTrack, at: insertTime)

            } catch {

                completionHandler(nil, nil, MergeVideoError.failedToLoadVideoTrack)
            }

            do {

                // Add audio track to audio composition at specific time
                try audioCompositionTrack.insertTimeRange(timeRange, of: audioTrack, at: insertTime)

            } catch {

                completionHandler(nil, nil, MergeVideoError.failedToLoadAudioTrack)
            }

//            videoCompositionTrack.preferredTransform = videoTrack.preferredTransform
//            print("After - videoCompositionTrack", videoCompositionTrack)
//            print("After - audioCompositionTrack", audioCompositionTrack)

            // Add instruction for video track
            let layerInstruction = videoCompositionInstructionForTrack(track: videoCompositionTrack,
                                                                       asset: videoAsset,
                                                                       standardSize: outputSize,
                                                                       atTime: insertTime)
            
            // Hide video track before changing to new track
            let endTime = CMTimeAdd(insertTime, videoAsset.duration)
            
            layerInstruction.setOpacity(0.0, at: endTime)
            
            arrayLayerInstructions.append(layerInstruction)
            
            // Increase the insert time
            insertTime = CMTimeAdd(insertTime, videoAsset.duration)
        }
        
        // Main video composition instruction
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: .zero, duration: insertTime)
        mainInstruction.layerInstructions = arrayLayerInstructions
        
        // Main video composition
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mainComposition.renderSize = outputSize
        
        // Export to file
        let path = NSTemporaryDirectory().appending("mergedVideo.mp4")
        let exportUrl = URL(fileURLWithPath: path)
        
        // Remove file if existed
        FileManager.default.removeItemIfExisted(at: exportUrl)
        
        // Init exporter
        guard let assetExport = AVAssetExportSession(asset: mixComposition,
                                                     presetName: AVAssetExportPresetHighestQuality) else { return }
        assetExport.videoComposition = mainComposition
        assetExport.outputURL = exportUrl
        assetExport.outputFileType = .mp4
        assetExport.shouldOptimizeForNetworkUse = true
        
        // Do export
        assetExport.exportAsynchronously(completionHandler: { [weak self] in
            
            switch assetExport.status {
                
            case .completed:
                self?.exportDidFinish(exporter: assetExport, videoURL: exportUrl, completion: completionHandler)
                
            case  .failed, .cancelled:
                completionHandler(nil, nil, assetExport.error)
                
            default:
                completionHandler(nil, nil, assetExport.error)
            }
        })
    }
    
    func mergeVideoAndAudio(videoUrl: URL, audioUrl: URL, credits: String,
                            completionHandler: @escaping ExportedHandler) {
        
        let audioMix = AVMutableAudioMix()
        let mixComposition = AVMutableComposition()
        var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        // Start Merge
        let videoAsset = AVAsset(url: videoUrl)
        let audioAsset = AVAsset(url: audioUrl)
        
        mutableCompositionVideoTrack.append(
            mixComposition.addMutableTrack(withMediaType: .video,
                                           preferredTrackID: kCMPersistentTrackID_Invalid)!)
        mutableCompositionAudioTrack.append(
            mixComposition.addMutableTrack(withMediaType: .audio,
                                           preferredTrackID: kCMPersistentTrackID_Invalid)!)
        
        let videoTrack = videoAsset.tracks(withMediaType: .video)[0]
        let audioTrack = audioAsset.tracks(withMediaType: .audio)[0]
        
        let timeRange = CMTimeRangeMake(start: .zero, duration: videoTrack.timeRange.duration)
        
        do {
            
            try mutableCompositionVideoTrack[0].insertTimeRange(timeRange, of: videoTrack, at: .zero)

        } catch {
         
            completionHandler(nil, nil, MergeVideoError.failedToLoadVideoTrack)
        }
        
        do {
            
            //In my case my audio file is longer then video file so i took videoAsset duration
            //instead of audioAsset duration
            try mutableCompositionAudioTrack[0].insertTimeRange(timeRange, of: audioTrack, at: .zero)
            
        } catch {
            
            completionHandler(nil, nil, MergeVideoError.failedToLoadAudioTrack)
        }
        
        totalVideoCompositionInstruction.timeRange =
            CMTimeRangeMake(start: .zero, duration: videoTrack.timeRange.duration)
        
        let mixVideoTrack = mixComposition.tracks(withMediaType: .video)[0]
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: mixVideoTrack)
        
        guard let layerInstructionArray =
            NSArray(object: layerInstruction) as? [AVVideoCompositionLayerInstruction] else { return }
        totalVideoCompositionInstruction.layerInstructions = layerInstructionArray
        
        // Add Music Credits
        let titleLayer = CATextLayer()
        titleLayer.foregroundColor = UIColor.lightGray.cgColor
        titleLayer.string = credits
        titleLayer.font = UIFont(name: "PingFangTC-Regular", size: 10)
        titleLayer.shadowOpacity = 0.5
        titleLayer.alignmentMode = .left
        titleLayer.frame = CGRect(x: 0,
                                  y: 0,
                                  width: videoTrack.naturalSize.width,
                                  height: 50)
        
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(x: 0,
                                  y: 0,
                                  width: videoTrack.naturalSize.width,
                                  height: videoTrack.naturalSize.height)
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(x: 0,
                                   y: 0,
                                   width: videoTrack.naturalSize.width,
                                   height: videoTrack.naturalSize.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(titleLayer)
        
        let mutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mutableVideoComposition.renderSize = videoTrack.naturalSize
        mutableVideoComposition.animationTool =
            AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        guard let totalVideoCompositionInstructionArray =
            NSArray(object: totalVideoCompositionInstruction) as? [AVVideoCompositionInstructionProtocol]
            else { return }
        mutableVideoComposition.instructions = totalVideoCompositionInstructionArray
        
        // Music Fade Out
        let audioMixInputParameters = AVMutableAudioMixInputParameters(track: mutableCompositionAudioTrack[0])
        
        // File Name
        let time = Int(Date().timeIntervalSince1970)
        let fileName = "\(time)-exported.mp4"
        
        // Find video on this URL
        let outputUrl = FileManager.exportedDirectory.appendingPathComponent(fileName)
        
        audioMixInputParameters.setVolumeRamp(fromStartVolume: 1, toEndVolume: 0, timeRange: videoTrack.timeRange)
        
        audioMix.inputParameters = [audioMixInputParameters]
        
        // Export
        guard let assetExport = AVAssetExportSession(asset: mixComposition,
                                                     presetName: AVAssetExportPresetHighestQuality) else { return }
        assetExport.audioMix = audioMix
        assetExport.videoComposition = mutableVideoComposition
        assetExport.outputFileType = .mp4
        assetExport.outputURL = outputUrl
        assetExport.shouldOptimizeForNetworkUse = true
        
        assetExport.exportAsynchronously(completionHandler: { [weak self] in
            
            switch assetExport.status {
                
            case .completed:
                DispatchQueue.main.async { [weak self] in
                    
                    completionHandler(outputUrl, fileName, nil)
                    
                    print("success", outputUrl.absoluteString)
                    
                    switch PHPhotoLibrary.authorizationStatus() {
                    
                    case .notDetermined:
                        PHPhotoLibrary.requestAuthorization({ status in
                            
                            if status == .authorized {
                                
                                UISaveVideoAtPathToSavedPhotosAlbum(outputUrl.path, self, nil, nil)
                            }
                        })
                        
                    case .authorized:
                        UISaveVideoAtPathToSavedPhotosAlbum(outputUrl.path, self, nil, nil)

                    case .denied, .restricted: break
                                    
                    default: break
                    }
                }
                
            case  .failed, .cancelled:
                completionHandler(nil, nil, assetExport.error)
                
            default:
                completionHandler(nil, nil, assetExport.error)
            }
        })
    }
}

extension MergeVideoManager {
    
    fileprivate func exportDidFinish(exporter: AVAssetExportSession?,
                                     videoURL: URL, completion: @escaping ExportedHandler) {
        
        if exporter?.status == .completed {
        
            print("Exported file: \(videoURL.absoluteString)")
            
            completion(videoURL, nil, nil)
        
        } else if exporter?.status == .failed {
          
            completion(videoURL, nil, exporter?.error)
        }
    }
    
    // Analyzes an affine transform to determine the input video’s orientation
    fileprivate func orientationFromTransform(transform: CGAffineTransform) ->
                    (orientation: UIImage.Orientation, isPortrait: Bool) {

        var assetOrientation = UIImage.Orientation.up

        var isPortrait = false

        // 手機直向正拍
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {

            assetOrientation = .right

            isPortrait = true

        // 手機直向顛倒拍
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {

            assetOrientation = .left

            isPortrait = true

        // 手機橫向頭朝左拍
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {

            assetOrientation = .up
            
        // 手機橫向頭朝右拍
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {

            assetOrientation = .down

        }

        return (assetOrientation, isPortrait)
    }
    
    fileprivate func videoCompositionInstructionForTrack(track: AVCompositionTrack,
                                                         asset: AVAsset,
                                                         standardSize: CGSize,
                                                         atTime: CMTime) -> AVMutableVideoCompositionLayerInstruction {

        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let videoTrack = asset.tracks(withMediaType: .video)[0]

        let transform = videoTrack.preferredTransform
        
        let assetInfo = orientationFromTransform(transform: transform)
        
        var aspectFillRatio: CGFloat = 1
        
        if assetInfo.isPortrait {

            aspectFillRatio = standardSize.width / videoTrack.naturalSize.height
            
            let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)

            let posX = standardSize.width / 2 - (videoTrack.naturalSize.height * aspectFillRatio) / 2
            let posY = standardSize.height / 2 - (videoTrack.naturalSize.width * aspectFillRatio) / 2
            let moveFactor = CGAffineTransform(translationX: posX, y: posY)

            let concat = videoTrack.preferredTransform.concatenating(scaleFactor).concatenating(moveFactor)

            instruction.setTransform(concat, at: atTime)
            
//            print("^^^^^ Portrait aspectFillRatio", aspectFillRatio)
//            print("^^^^^ Portrait scaleFactor", scaleFactor)
//            print("^^^^^ Portrait moveFactor", moveFactor)
//            print("^^^^^ Portrait pos", posX, posY)
//            print("^^^^^ Portrait concat", concat)

        } else {

            aspectFillRatio = standardSize.width / videoTrack.naturalSize.width
            
            let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)

            let posX = standardSize.width / 2 - (videoTrack.naturalSize.width * aspectFillRatio) / 2
            let posY = standardSize.height / 2 - (videoTrack.naturalSize.height * aspectFillRatio) / 2
            let moveFactor = CGAffineTransform(translationX: posX, y: posY)

            var concat = videoTrack.preferredTransform.concatenating(scaleFactor).concatenating(moveFactor)

            if assetInfo.orientation == .down {

                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                concat = fixUpsideDown.concatenating(scaleFactor).concatenating(moveFactor)
            }

            instruction.setTransform(concat, at: atTime)
            
//            print("vvvvv Landscape aspectFillRatio", aspectFillRatio)
//            print("vvvvv Landscape scaleFactor", scaleFactor)
//            print("vvvvv Landscape moveFactor", moveFactor)
//            print("vvvvv Landscape pos", posX, posY)
//            print("vvvvv Landscape concat", concat)
        }

        return instruction
    }
}
