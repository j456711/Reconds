//
//  HomeViewController.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/1.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class HomeViewController: UIViewController {

    let rcVideoPlayer = RCVideoPlayer()
    
    var videoData: [VideoData] = []
    
    var longPressedEnabled = false
    
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
        
        if videoData[0].dataPathArray.count == 1 {
        
            collectionView.isHidden = false
            
            guard let videoUrl =
                URL(string: FileManager.documentDirectory.absoluteString + videoData[0].dataPathArray[0])
            else { return }
            
            rcVideoPlayer.setUpAVPlayer(with: self.view, videoUrl: videoUrl, videoGravity: .resizeAspect)
            
            rcVideoPlayer.play()
            
        } else if videoData[0].dataPathArray.count == 2 {
            
            collectionView.isHidden = false
            
            merge()
        }
        
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

        if videoData.count == 0 {
            
            return 25
        
        } else {
            
            return videoData[0].dataPathArray.count
        }
        
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: HomeCollectionViewCell.self), for: indexPath)
        
        guard let homeCell = cell as? HomeCollectionViewCell else { return cell }
        
        if longPressedEnabled {

            homeCell.removeButton.isHidden = false
            
        } else {

            homeCell.removeButton.isHidden = true
        }

        homeCell.removeButton.addTarget(self, action: #selector(removeButtonPressed), for: .touchUpInside)

        if videoData.count == 0 {
            
            return cell
            
        } else {
            
            let dataPath =
                FileManager.documentDirectory.appendingPathComponent(videoData[0].dataPathArray[indexPath.item])
            
//            rcVideoPlayer.setUpAVPlayer(with: homeCell, videoUrl: dataPath, videoGravity: .resizeAspectFill)
            
            homeCell.thumbnail.image = rcVideoPlayer.generateThumbnail(path: dataPath)
        
            return homeCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {

        return true
    }

    func collectionView(_ collectionView: UICollectionView,
                        moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        print("Start index: \(sourceIndexPath.item)")
        print("End index: \(destinationIndexPath.item)")
        
        let dataString = videoData[0].dataPathArray.remove(at: sourceIndexPath.item)

        videoData[0].dataPathArray.insert(dataString, at: destinationIndexPath.item)

        collectionView.reloadData()
    }
    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        return CGSize(width: self.view.frame.size.width / 5, height: self.view.frame.size.width / 5)
//    }
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
        
        let alert = UIAlertController.addConfirmAndCancelAlertWith(alertTitle: "確定要刪除影片嗎？",
                                                                   alertMessage: "刪除後不可回復。",
                                                                   confirmActionHandler: { [weak self] (_) in
            
            do {
                
                guard let strongSelf = self else { return }
                
                let dataPath =
                    FileManager.documentDirectory.appendingPathComponent(
                        strongSelf.videoData[0].dataPathArray[hitIndex.item])
                
                try FileManager.default.removeItem(at: dataPath)
                
                strongSelf.videoData[0].dataPathArray.remove(at: hitIndex.item)
                
                VideoDataManager.shared.save()
                
                 print("Remove successfully")
                
                print("**********\(strongSelf.videoData[0].dataPathArray)**********")
                
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
        
        let dataPath = FileManager.documentDirectory.appendingPathComponent(videoData[0].dataPathArray[hitIndex.item])
        
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
        
        print("############\(videoData)##################")
    }
    
//    func deleteData() {
//
//        VideoDataManager.shared.context.delete(self.videoData[0])
//
//        VideoDataManager.shared.save()
//    }
}

extension HomeViewController {
    
    @IBAction func pressed(_ sender: UIButton) {

        merge()
    }

    func merge() {

        let videoDataStringArray = videoData[0].dataPathArray.map({ FileManager.documentDirectory.absoluteString + $0 })

        guard let videoDataUrlArray = videoDataStringArray.map({ URL(string: $0) }) as? [URL] else { return }

        let videoDataAVAssetArray = videoDataUrlArray.map({ AVAsset(url: $0) })

            MergeVideoManager.shared.doMerge(arrayVideos: videoDataAVAssetArray,
                                             completion: { [weak self] (outputUrl, error) in

                guard let strongSelf = self else { return }

                if let error = error {

                    print("Error: \(error.localizedDescription)")

                } else {

                    if let url = outputUrl {

                        strongSelf.rcVideoPlayer.setUpAVPlayer(with: strongSelf.videoView,
                                                               videoUrl: url,
                                                               videoGravity: .resizeAspect)

                        strongSelf.rcVideoPlayer.play()
//                        PHPhotoLibrary.shared().performChanges({
//
//                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
//
//                            print("success")
//
//                        }, completionHandler: nil)
                    }
                }
            })
    }
}
