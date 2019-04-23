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
    
    func mergeVideos(arrayVideos: [AVAsset], completion: @escaping ExportUrlHandler) {
        
        var insertTime = CMTime.zero
        
        var arrayLayerInstructions: [AVMutableVideoCompositionLayerInstruction] = []
        
        var outputSize = CGSize(width: 0, height: 0)

//         Determine video output size
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
        let exportUrl = URL.init(fileURLWithPath: path)
        
        // Remove file if existed
        FileManager.default.removeItemIfExisted(exportUrl)
        
        // Init exporter
        let exporter = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = exportUrl
        exporter?.outputFileType = AVFileType.mp4
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = mainComposition
        
        // Do export
        exporter?.exportAsynchronously(completionHandler: {
            
            DispatchQueue.main.async {
                
                self.exportDidFinish(exporter: exporter, videoURL: exportUrl, completion: completion)
            }
        })
    }
    
    typealias VideoExportedHandler = ((String?, Error?) -> Void)
    
    func mergeVideoAndAudio(videoUrl: URL, audioUrl: URL, completionHandler: @escaping VideoExportedHandler) {
        
        let audioMix = AVMutableAudioMix()
        let mixComposition = AVMutableComposition()
        var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        // Start Merge
        let aVideoAsset = AVAsset(url: videoUrl)
        let aAudioAsset = AVAsset(url: audioUrl)
        
        mutableCompositionVideoTrack.append(
            mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                           preferredTrackID: kCMPersistentTrackID_Invalid)!)
        mutableCompositionAudioTrack.append(
            mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                           preferredTrackID: kCMPersistentTrackID_Invalid)!)
        
        let aVideoAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let aAudioAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0]
        
        do {
            try mutableCompositionVideoTrack[0].insertTimeRange(
                CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration),
                of: aVideoAssetTrack,
                at: CMTime.zero)
            
            //In my case my audio file is longer then video file so i took videoAsset duration
            //instead of audioAsset duration
            
            try mutableCompositionAudioTrack[0].insertTimeRange(
                CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration),
                of: aAudioAssetTrack,
                at: CMTime.zero)
            
            //Use this instead above line if your audiofile and video file's playing durations are same
            
//            try mutableCompositionAudioTrack[0].insertTimeRange(
//            CMTimeRangeMake(kCMTimeZero,
//                            aVideoAssetTrack.timeRange.duration),
//            ofTrack: aAudioAssetTrack,
//            atTime: kCMTimeZero)
            
        } catch {
         
            print(error)
        }
        
        totalVideoCompositionInstruction.timeRange =
            CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration)
        
        let mutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        mutableVideoComposition.renderSize = CGSize(width: 1280, height: 720)
        
        let time = Int(Date().timeIntervalSince1970)
        
        let fileName = "\(time)-exported.mp4"
        
        // Find video on this URL
        guard let outputUrl = URL(string: FileManager.documentDirectory.absoluteString + fileName) else { return }
        
        // Music Fade Out
        let audioMixInputParameters = AVMutableAudioMixInputParameters(track: mutableCompositionAudioTrack[0])
        
        audioMixInputParameters.setVolumeRamp(fromStartVolume: 1, toEndVolume: 0, timeRange: aVideoAssetTrack.timeRange)
        
        audioMix.inputParameters = [audioMixInputParameters]
        
        // Export
        guard let assetExport = AVAssetExportSession(asset: mixComposition,
                                                     presetName: AVAssetExportPresetHighestQuality) else { return }
        assetExport.audioMix = audioMix
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = outputUrl
        assetExport.shouldOptimizeForNetworkUse = true
        
        assetExport.exportAsynchronously { () -> Void in
            
            switch assetExport.status {
                
            case AVAssetExportSession.Status.completed:
                
                //                Uncomment this if u want to store your video in asset
                DispatchQueue.main.async { [weak self] in
//                    let assetsLib = PHPhotoLibrary()
//                    assetsLib.writeVideoAtPath(toSavedPhotosAlbum: savePathUrl, completionBlock: nil)
                    
                    UISaveVideoAtPathToSavedPhotosAlbum(outputUrl.path, self, nil, nil)
                    
                    completionHandler(fileName, nil)
                    
                    print("success", outputUrl.absoluteString)
                }
                
            case  AVAssetExportSession.Status.failed:
                
                completionHandler(nil, assetExport.error)
                
                print("failed:", assetExport.error as Any)
            
            case AVAssetExportSession.Status.cancelled:
            
                completionHandler(nil, assetExport.error)
                
                print("cancelled", assetExport.error as Any)
            
            default:
                
                print("complete")
            }
        }
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

        if assetTrack.naturalSize.height > assetTrack.naturalSize.width {
          
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
