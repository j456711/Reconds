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

class MergeVideoManager {
    
    var videoArray = [AVAsset]() //Videos Array
    var atTimeM: CMTime = CMTimeMake(value: 0, timescale: 0)
    var lastAsset: AVAsset!
    var layerInstructionsArray = [AVVideoCompositionLayerInstruction]()
    var completeTrackDuration: CMTime = CMTimeMake(value: 0, timescale: 1)
    var videoSize: CGSize = CGSize(width: 0.0, height: 0.0)
    var totalTime = CMTimeMake(value: 0, timescale: 0)
    
    func mergeVideoArray(_ viewController: UIViewController) {
        
        let mixComposition = AVMutableComposition()
        
        for videoAsset in videoArray {
            
            guard let videoTrack =
                mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
            
            do {
                
                if videoAsset == videoArray.first {
                    
                    atTimeM = CMTime.zero
                    
                } else {
                    
                    atTimeM = totalTime
                }
                
                let cmTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration)
                
                try videoTrack.insertTimeRange(cmTimeRange, of: videoAsset.tracks(withMediaType: AVMediaType.video)[0], at: completeTrackDuration)
                
                videoSize = videoTrack.naturalSize
                
            } catch let error as NSError {
                
                print("error: \(error)")
            }
            
            totalTime = CMTimeAdd(totalTime, videoAsset.duration)
            
            completeTrackDuration = CMTimeAdd(completeTrackDuration, videoAsset.duration)
            let videoInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            
            if videoAsset != videoArray.last {
                
                videoInstruction.setOpacity(0.0, at: completeTrackDuration)
            }
            
            layerInstructionsArray.append(videoInstruction)
            lastAsset = videoAsset
        }
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: completeTrackDuration)
        mainInstruction.layerInstructions = layerInstructionsArray
        
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mainComposition.renderSize = CGSize(width: videoSize.width, height: videoSize.height)
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: NSDate() as Date)
        let savePath = (documentDirectory as NSString).appendingPathComponent("mergedVideo-\(date).mp4")
        let url = NSURL(fileURLWithPath: savePath)
        
        guard let exporter =
            AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.outputURL = url as URL
        exporter.outputFileType = .mp4
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = mainComposition
        
        exporter.exportAsynchronously {
            
            DispatchQueue.main.async {
                
                PHPhotoLibrary.shared().performChanges({
                    
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exporter.outputURL!)
                    
                }) { saved, error in
                    
                    if saved {
                        
                        let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        viewController.present(alertController, animated: true, completion: nil)
                    
                    } else {
                        
                        print("video error: \(error!)")
                        
                    }
                }
            }
            
        }
    }
}
