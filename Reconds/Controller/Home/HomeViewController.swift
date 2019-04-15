//
//  HomeViewController.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/1.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {

    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    let rcVideoPlayer = RCVideoPlayer()
    
    var videoData: [VideoData] = [] {
        
        didSet {
            
            print(videoData)
            print(videoData.count)
        }
    }
    
    var longPressedEnabled = false
    
    
    var firstAsset: AVAsset?
    var secondAsset: AVAsset?
    
    
    @IBOutlet weak var videoView: UIView!

    @IBOutlet weak var collectionView: UICollectionView! {

        didSet {

            collectionView.delegate = self
            collectionView.dataSource = self

            collectionView.isHidden = true
        }
    }

    @IBOutlet weak var doneButton: UIButton! {

        didSet {

            doneButton.isHidden = true

            doneButton.layer.borderWidth = 1
            doneButton.layer.borderColor = UIColor(red: 32 / 255, green: 184 / 255, blue: 221 / 255, alpha: 1).cgColor
            doneButton.layer.cornerRadius = 18
        }
    }

    @IBAction func doneButtonPressed(_ sender: UIButton) {

        doneButton.isHidden = true

        longPressedEnabled = false

        collectionView.reloadData()
    }

    @IBAction func addVideoButtonPressed(_ sender: UIBarButtonItem) {

        if collectionView.isHidden == true {

            createProjectNameAlert()

        } else {

            let alert = UIAlertController.addConfirmAlertWith(alertTitle: "無法新增影片",
                                                              alertMessage: "尚未開放一次可編輯多支影片的功能，敬請期待！")

            present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        
        collectionView.addGestureRecognizer(longPressGesture)
        collectionView.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        fetchData()
        
        collectionView.reloadData()
    }

    func createProjectNameAlert() {
        
        let alert = UIAlertController(title: "請輸入影片名稱", message: "命名後仍可更改，若未輸入名稱將預設為「未命名」。", preferredStyle: .alert)

        alert.addTextField(configurationHandler: { textField in

            textField.placeholder = "未命名"
        })

        let confirmAction = UIAlertAction(title: "確定", style: .default) { [weak self] (_) in

            guard let textField = alert.textFields?.first,
                  let text = textField.text else { return }

            if text.isEmpty {

                self?.collectionView.isHidden = false

                self?.navigationItem.title = textField.placeholder

            } else {

                self?.collectionView.isHidden = false

                self?.navigationItem.title = text
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        fetchData()
        
        return videoData.count
    }

    func collectionView(
        _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: HomeCollectionViewCell.self), for: indexPath)

        guard let homeCell = cell as? HomeCollectionViewCell else { return cell }

        if longPressedEnabled {

            homeCell.removeButton.isHidden = false

        } else {

            homeCell.removeButton.isHidden = true
        }
        
        homeCell.removeButton.addTarget(self, action: #selector(removeButtonPressed), for: .touchUpInside)
        
        let dataPath = documentDirectory.appendingPathComponent(videoData[indexPath.item].dataPath)
        
//        guard let dataPath = URL(string: videoData[indexPath.item].dataPath) else { return homeCell }
        
//        rcVideoPlayer.setUpAVPlayer(with: homeCell, videoUrl: dataPath, videoGravity: .resizeAspectFill)
        
        homeCell.thumbnail.image = rcVideoPlayer.generateThumbnail(path: dataPath)
        
        return homeCell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {

        return true
    }

    func collectionView(
        _ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        print("Start index: - \(sourceIndexPath.item)")
        print("End index: - \(destinationIndexPath.item)")

        let tmp = videoData[sourceIndexPath.item].dataPath
        videoData[sourceIndexPath.item].dataPath = videoData[destinationIndexPath.item].dataPath
        videoData[destinationIndexPath.item].dataPath = tmp
        
        VideoDataManager.shared.save()
        
        collectionView.reloadData()
    }

}

// MARK: - Gestures
extension HomeViewController {
    
    @objc func longPressAction(_ gesture: UIGestureRecognizer) {

        switch gesture.state {

        case .began:

            guard let selectedIndexPath =
                collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { return }

            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)

        case .changed:

            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))

        case .ended:

            collectionView.endInteractiveMovement()
            
            doneButton.isHidden = false

            longPressedEnabled = true
            
            collectionView.reloadData()

        default:

            collectionView.cancelInteractiveMovement()
        }
    }

    @objc func removeButtonPressed(_ sender: UIButton) {

        let hitPoint = sender.convert(CGPoint.zero, to: collectionView)

        guard let hitIndex = collectionView.indexPathForItem(at: hitPoint) else { return }
        
        let alert = UIAlertController.addConfirmAndCancelAlertWith(
            alertTitle: "確定要刪除影片嗎？", alertMessage: "刪除後不可回復。", confirmActionHandler: { [weak self] (_) in
            
            do {
                
                guard let strongSelf = self,
                      let videoUrl = URL(string: (strongSelf.videoData[hitIndex.item].dataPath)) else { return }
                
                let dataPath =
                    strongSelf.documentDirectory.appendingPathComponent(strongSelf.videoData[hitIndex.item].dataPath)
                
//                try FileManager.default.removeItem(at: videoUrl)
                
                try FileManager.default.removeItem(at: dataPath)
                
                print("Remove successfully")
                
                strongSelf.deleteData(at: hitIndex)
                
                strongSelf.collectionView.reloadData()
                
            } catch {
                
                print("Remove fail", error.localizedDescription)
            }
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func tapAction(_ gesture: UIGestureRecognizer) {
        
        let hitPoint = gesture.location(in: collectionView)
        
        guard let hitIndex = collectionView.indexPathForItem(at: hitPoint) else { return }
        
        let storyboard = UIStoryboard(name: "Record", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "VideoPlaybackViewController")
        guard let videoPlaybackVC = controller as? VideoPlaybackViewController else { return }
        
        let dataPath = documentDirectory.appendingPathComponent(videoData[hitIndex.item].dataPath)
        
//        videoPlaybackVC.videoUrl = URL(string: videoData[hitIndex.item].dataPath)
        
        videoPlaybackVC.videoUrl = dataPath
        
        videoPlaybackVC.view.addSubview(videoPlaybackVC.controlView)
        videoPlaybackVC.view.addSubview(videoPlaybackVC.retakeButton)
        videoPlaybackVC.view.addSubview(videoPlaybackVC.useButton)
        
        videoPlaybackVC.controlView.isHidden = true
        videoPlaybackVC.retakeButton.isHidden = true
        videoPlaybackVC.useButton.isHidden = true
        
        videoPlaybackVC.modalPresentationStyle = .overFullScreen
        
        present(videoPlaybackVC, animated: true, completion: nil)
    }
    
}

// MARK: - CoreData Function
extension HomeViewController {
    
    func fetchData() {
        
        let videoData = VideoDataManager.shared.fetch(VideoData.self)
        
        self.videoData = videoData
    }
    
    func deleteData(at hitIndex: IndexPath) {
        
        VideoDataManager.shared.context.delete(self.videoData[hitIndex.item])

        VideoDataManager.shared.save()
    }
}

extension HomeViewController {
    
    @IBAction func pressed(_ sender: UIButton) {

        merge()
    }
    
    func merge() {
        
        let firstDataPath = documentDirectory.appendingPathComponent(videoData[2].dataPath)
        let secondDataPath = documentDirectory.appendingPathComponent(videoData[1].dataPath)
        
        firstAsset = AVAsset(url: firstDataPath)
        secondAsset = AVAsset(url: secondDataPath)
        
        guard let firstAsset = firstAsset, let secondAsset = secondAsset else { return }
        
        let mixComposition = AVMutableComposition()
        
        guard let firstTrack =
            mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
        
        do {
            
            try firstTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: firstAsset.duration), of: firstAsset.tracks(withMediaType: .video)[0], at: .zero)
            
        } catch {
            
            print("Failed to load first track, \(error)")
        }
        
        guard let secondTrack =
            mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
        
        do {
            
            try secondTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: secondAsset.duration), of: secondAsset.tracks(withMediaType: .video)[0], at: .zero)
            
        } catch {
            
            print("Failed to load first track, \(error)")
        }
        
        let mergedVideoUrl = documentDirectory.appendingPathComponent("merged.mp4")
        
        do {
            
            try FileManager.default.removeItem(at: mergedVideoUrl)
            
        } catch {
            
            print(error.localizedDescription)
        }
        
        
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        
        exporter.outputURL = mergedVideoUrl
        exporter.outputFileType = .mp4
        exporter.shouldOptimizeForNetworkUse = true
        
        
        
        exporter.exportAsynchronously { () -> Void in
            
            switch exporter.status {
            
            case .completed:
                DispatchQueue.main.async {
                
                    
                    
                    print("success")
                    
                    self.rcVideoPlayer.setUpAVPlayer(with: self.videoView, videoUrl: exporter.outputURL!, videoGravity: .resizeAspect)
                    
                    self.rcVideoPlayer.play()
                }
                
            case .failed:
                print("failed \(exporter.error!)")
                
            case .cancelled:
                print("cancelled \(exporter.error!)")

            default:
                print("complete")
            }
        }
    }
}
