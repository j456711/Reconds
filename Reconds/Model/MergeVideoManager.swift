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

class MergeVideoManager {
    
    static let shared = MergeVideoManager()
    
    let defaultSize = CGSize(width: 1920, height: 1080)
    
    typealias ExportUrlHandler = (URL?, Error?) -> Void
    
    func doMerge(arrayVideos: [AVAsset], completion: @escaping ExportUrlHandler) {
        
        var insertTime = CMTime.zero
        
        var arrayLayerInstructions: [AVMutableVideoCompositionLayerInstruction] = []
        
        var outputSize = CGSize.init(width: 0, height: 0)
        
        // Determine video output size
        for videoAsset in arrayVideos {
            
            let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
            
            let assetInfo = orientationFromTransform(transform: videoTrack.preferredTransform)
            
            var videoSize = videoTrack.naturalSize
            
            if assetInfo.isPortrait == true {
            
                videoSize.width = videoTrack.naturalSize.height
                videoSize.height = videoTrack.naturalSize.width
            }
            
            if videoSize.height > outputSize.height {
                
                outputSize = videoSize
            }
        }
        
        if outputSize.width == 0 || outputSize.height == 0 {
            
            outputSize = defaultSize
        }
        
        // Silence sound (in case of video has no sound track)
//        let silenceURL = Bundle.main.url(forResource: "silence", withExtension: "mp3")
//        let silenceAsset = AVAsset(url:silenceURL!)
//        let silenceSoundTrack = silenceAsset.tracks(withMediaType: AVMediaType.audio).first
        
        // Init composition
        let mixComposition = AVMutableComposition.init()
        
        for videoAsset in arrayVideos {
            
            // Get video track
            guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else { continue }
            
            // Get audio track
            var audioTrack: AVAssetTrack?
            
            if videoAsset.tracks(withMediaType: AVMediaType.audio).count > 0 {
            
                audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio).first
            }
//            else {
//                audioTrack = silenceSoundTrack
//            }
            
            // Init video & audio composition track
            let videoCompositionTrack =
                mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                               preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            
            let audioCompositionTrack =
                mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                               preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            
            do {
                
                // Add video track to video composition at specific time
                try videoCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                           duration: videoAsset.duration),
                                                           of: videoTrack,
                                                           at: insertTime)
                
                // Add audio track to audio composition at specific time
                if let audioTrack = audioTrack {
                    
                    try audioCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                               duration: videoAsset.duration),
                                                               of: audioTrack,
                                                               at: insertTime)
                }
                
                // Add instruction for video track
                let layerInstruction = videoCompositionInstructionForTrack(track: videoCompositionTrack!,
                                                                           asset: videoAsset,
                                                                           standardSize: outputSize,
                                                                           atTime: insertTime)
                
                // Hide video track before changing to new track
                let endTime = CMTimeAdd(insertTime, videoAsset.duration)
                
                layerInstruction.setOpacity(0.0, at: endTime)
                
                arrayLayerInstructions.append(layerInstruction)
                
                // Increase the insert time
                insertTime = CMTimeAdd(insertTime, videoAsset.duration)
                
            } catch {
                
                print("Load track error")
            }
        }
        
        // Main video composition instruction
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: insertTime)
        mainInstruction.layerInstructions = arrayLayerInstructions
        
        // Main video composition
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mainComposition.renderSize = outputSize
        
        // Export to file
        let path = NSTemporaryDirectory().appending("mergedVideo.mp4")
        let exportURL = URL.init(fileURLWithPath: path)
        
        // Remove file if existed
        FileManager.default.removeItemIfExisted(exportURL)
        
        // Init exporter
        let exporter = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = exportURL
        exporter?.outputFileType = AVFileType.mp4
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = mainComposition
        
        // Do export
        exporter?.exportAsynchronously(completionHandler: {
            
            DispatchQueue.main.async {
                
                self.exportDidFinish(exporter: exporter, videoURL: exportURL, completion: completion)
            }
        })
    }
    
}

extension MergeVideoManager {
    
    fileprivate func exportDidFinish(exporter: AVAssetExportSession?,
                                     videoURL: URL, completion: @escaping ExportUrlHandler) {
        
        if exporter?.status == AVAssetExportSession.Status.completed {
        
            print("Exported file: \(videoURL.absoluteString)")
            
            completion(videoURL, nil)
        
        } else if exporter?.status == AVAssetExportSession.Status.failed {
          
            completion(videoURL, exporter?.error)
        }
    }
    
    fileprivate func orientationFromTransform(transform: CGAffineTransform) ->
                    (orientation: UIImage.Orientation, isPortrait: Bool) {
        
        var assetOrientation = UIImage.Orientation.up
        
        var isPortrait = false
        
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
        
            assetOrientation = .right
            
            isPortrait = true
        
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
        
            assetOrientation = .left
            
            isPortrait = true
        
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
        
            assetOrientation = .up
        
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
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform: transform)
        
        var aspectFillRatio: CGFloat = 1
        
        if assetTrack.naturalSize.height < assetTrack.naturalSize.width {
        
            aspectFillRatio = standardSize.height / assetTrack.naturalSize.height
        
        } else {
          
            aspectFillRatio = standardSize.width / assetTrack.naturalSize.width
        }
        
        if assetInfo.isPortrait {
            
            let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)
            
            let posX = standardSize.width / 2 - (assetTrack.naturalSize.height * aspectFillRatio) / 2
            let posY = standardSize.height / 2 - (assetTrack.naturalSize.width * aspectFillRatio) / 2
            let moveFactor = CGAffineTransform(translationX: posX, y: posY)
            
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(moveFactor),
                                     at: atTime)
            
        } else {
            
            let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)
            
            let posX = standardSize.width / 2 - (assetTrack.naturalSize.width * aspectFillRatio) / 2
            let posY = standardSize.height / 2 - (assetTrack.naturalSize.height * aspectFillRatio) / 2
            let moveFactor = CGAffineTransform(translationX: posX, y: posY)
            
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(moveFactor)
            
            if assetInfo.orientation == .down {
                
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                concat = fixUpsideDown.concatenating(scaleFactor).concatenating(moveFactor)
            }
            
            instruction.setTransform(concat, at: atTime)
        }
        
        return instruction
    }
}
