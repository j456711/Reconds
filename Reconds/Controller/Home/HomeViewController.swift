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

    struct Segue {
        
        static let showMusicPage = "showMusicPage"
    }
    
    var feedbackGenerator: UIImpactFeedbackGenerator?
    
    let rcVideoPlayer = RCVideoPlayer()
    
    lazy var videoUrl: URL? = nil
    
    var videoData: [VideoData] = []
    
    var longPressedEnabled = false
    
    @IBOutlet weak var remindLabel: UILabel!
    
    @IBOutlet weak var videoView: UIView!

    @IBOutlet weak var collectionView: UICollectionView! {

        didSet {

            collectionView.delegate = self
            collectionView.dataSource = self

            collectionView.isHidden = true
            
            collectionView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    @IBOutlet weak var clapperButton: UIButton!
    
    @IBOutlet weak var exportButton: UIButton! {
        
        didSet {
            
            exportButton.isHidden = true
            
            setUpButtonStyle(for: exportButton)
        }
    }
    
    @IBOutlet weak var doneButton: UIButton! {

        didSet {

            doneButton.isHidden = true

            setUpButtonStyle(for: doneButton)
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {

        doneButton.isHidden = true

        exportButton.isHidden = false
        
        longPressedEnabled = false

        collectionView.reloadData()
    }

    @IBAction func clapperButtonPressed(_ sender: UIBarButtonItem) {

        if collectionView.isHidden == true {

            createProjectNameAlert()
        }
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FileManager.default.jy_createDirectory("Exported")
        FileManager.default.jy_createDirectory("VideoData")
        
        if UserDefaults.standard.string(forKey: "Title") == "" {

            self.navigationItem.title = "Reconds"
        
        } else {
            
            self.navigationItem.title = UserDefaults.standard.string(forKey: "Title")
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        
        collectionView.addGestureRecognizer(longPressGesture)
        collectionView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
        
        let filteredArray = StorageManager.shared.filterData()
        
        if filteredArray != nil {
        
            print("----------\(videoData[0].dataPathArray.count)-----------")
            
            if filteredArray?.count == 0 {
                
                exportButton.isHidden = true
                
            } else if filteredArray?.count == 1 {
                
                exportButton.isHidden = false
                
                collectionView.isHidden = false
                
                guard let videoUrl =
                    URL(string: FileManager.videoDataDirectory.absoluteString + videoData[0].dataPathArray[0])
                    else { return }
                
                DispatchQueue.main.async { [weak self] in
                    
                    guard let strongSelf = self else { return }
                    
                    strongSelf.rcVideoPlayer.setUpAVPlayer(with: strongSelf.videoView,
                                                           videoUrl: videoUrl,
                                                           videoGravity: .resizeAspect)
                    
                    strongSelf.rcVideoPlayer.play()
                }
                
            } else {
                
                exportButton.isHidden = false
                
                collectionView.isHidden = false
                
                DispatchQueue.global().async { [weak self] in
                    
                    self?.merge()
                }
            }
            
        } else {

            reset()
        }
        
        collectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let musicVC = segue.destination as? MusicViewController else { return }
        
        musicVC.videoUrl = videoUrl
    }
    
    func setUpButtonStyle(for button: UIButton) {
        
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 18
        button.layer.borderColor = UIColor(red: 32 / 255, green: 184 / 255, blue: 221 / 255, alpha: 1).cgColor
    }
    
    func createProjectNameAlert() {
        
        let alert = UIAlertController(title: "請輸入影片名稱", message: "命名後仍可更改，若未輸入名稱將預設為「未命名」。", preferredStyle: .alert)

        alert.addTextField(configurationHandler: { textField in

            textField.placeholder = "未命名"
        })

        let confirmAction = UIAlertAction(title: "確定", style: .default) { [weak self] (_) in

            guard let strongSelf = self,
                  let textField = alert.textFields?.first,
                  let text = textField.text else { return }

            if text.isEmpty {

                strongSelf.collectionView.isHidden = false

                strongSelf.navigationItem.title = textField.placeholder
                                
            } else {

                strongSelf.collectionView.isHidden = false

                strongSelf.navigationItem.title = text
            }
            
            if strongSelf.videoData.count == 0 {
                
                StorageManager.shared.createVideoData()
                
                strongSelf.collectionView.reloadData()
            }
            
            if let title = strongSelf.navigationItem.title {
                
                UserDefaults.standard.set(title, forKey: "Title")
            }
            
            strongSelf.remindLabel.isHidden = true
            
            strongSelf.clapperButton.isHidden = true
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
  
            if videoData[0].dataPathArray[indexPath.item] == "" {
                
                homeCell.removeButton.isHidden = true
                
                homeCell.thumbnail.image = nil
                
            } else {
                
                let dataPath =
                    FileManager.videoDataDirectory.appendingPathComponent(videoData[0].dataPathArray[indexPath.item])
                
                homeCell.thumbnail.image = rcVideoPlayer.generateThumbnail(path: dataPath)
                
            }

//            rcVideoPlayer.setUpAVPlayer(with: homeCell, videoUrl: dataPath, videoGravity: .resizeAspectFill)

            return homeCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {

        if videoData[0].dataPathArray[indexPath.item] == "" {
            
            return false
        
        } else {
        
            return true
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        print("Start index: \(sourceIndexPath.item)")
        print("End index: \(destinationIndexPath.item)")
        
        let dataString = videoData[0].dataPathArray.remove(at: sourceIndexPath.item)

        videoData[0].dataPathArray.insert(dataString, at: destinationIndexPath.item)

        StorageManager.shared.save()
        
        collectionView.reloadData()
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (UIScreen.main.bounds.size.width - 4) / 5,
                      height: (UIScreen.main.bounds.size.width - 4) / 5)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1
    }
}

// MARK: - Gestures
extension HomeViewController {
    
    @objc func longPressAction(_ gesture: UIGestureRecognizer) {

        switch gesture.state {

        case .began:
            
            feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            
            feedbackGenerator?.impactOccurred()
            
            guard let selectedIndexPath =
                collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { return }

            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)

        case .changed:
            
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))

        case .ended, .cancelled, .failed:

            feedbackGenerator = nil
            
            collectionView.endInteractiveMovement()
            
            exportButton.isHidden = true
            
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
        
        UIAlertController.addConfirmAndCancelAlertWith(viewController: self,
                                                       alertTitle: "確定要刪除影片嗎？",
                                                       alertMessage: "刪除後不可回復。",
                                                       confirmActionHandler: { [weak self] (_) in
            
            do {
                
                guard let strongSelf = self else { return }
                
                if strongSelf.videoData.count != 0 {
                
                    let dataPath =
                        FileManager.videoDataDirectory.appendingPathComponent(
                            strongSelf.videoData[0].dataPathArray[hitIndex.item])
                    
                    try FileManager.default.removeItem(at: dataPath)
                    
                    strongSelf.videoData[0].dataPathArray.remove(at: hitIndex.item)
                    
                    strongSelf.videoData[0].dataPathArray.insert("", at: 24)
                    
                    StorageManager.shared.save()
                    
                    print("Remove successfully")
                    
                    print("**********\(strongSelf.videoData[0].dataPathArray)**********")
                    
                    strongSelf.collectionView.reloadData()
                }
                
            } catch {
                
                print("Remove fail", error.localizedDescription)
            }
        })        
    }
    
    @objc func tapAction(_ gesture: UIGestureRecognizer) {
        
        let hitPoint = gesture.location(in: collectionView)
        
        guard let hitIndex = collectionView.indexPathForItem(at: hitPoint) else { return }
        
        let storyboard = UIStoryboard(name: "Record", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "VideoPlaybackViewController")
        guard let videoPlaybackVC = controller as? VideoPlaybackViewController else { return }
        
        if videoData[0].dataPathArray[hitIndex.item] != "" {
        
            let dataPath =
                FileManager.videoDataDirectory.appendingPathComponent(videoData[0].dataPathArray[hitIndex.item])
            
            videoPlaybackVC.videoUrl = dataPath
            
            videoPlaybackVC.view.bringSubviewToFront(videoPlaybackVC.controlView)
            videoPlaybackVC.view.bringSubviewToFront(videoPlaybackVC.retakeButton)
            videoPlaybackVC.view.bringSubviewToFront(videoPlaybackVC.useButton)
            
            videoPlaybackVC.controlView.isHidden = true
            videoPlaybackVC.retakeButton.isHidden = true
            videoPlaybackVC.useButton.isHidden = true
            
            videoPlaybackVC.modalPresentationStyle = .overFullScreen
            
            present(videoPlaybackVC, animated: true, completion: nil)
        }
    }
}

// MARK: - CoreData Function
extension HomeViewController {
    
    func fetchData() {
        
        let videoData = StorageManager.shared.fetch(VideoData.self)
        
        self.videoData = videoData
        
        print("#########\(videoData)############")
    }
}

extension HomeViewController {
    
    func merge() {
        
        guard let filteredArray = StorageManager.shared.filterData() else { return }

        let stringArray = filteredArray.map({ FileManager.videoDataDirectory.absoluteString + $0 })

        guard let urlArray = stringArray.map({ URL(string: $0) }) as? [URL] else { return }

        let avAssetArray = urlArray.map({ AVAsset(url: $0) })

        MergeVideoManager.shared.mergeVideos(arrayVideos: avAssetArray,
                                         completion: { [weak self] (videoUrl, error) in

            guard let strongSelf = self else { return }

            if let error = error {

                print("HomeVC merge error: \(error.localizedDescription)")

            } else {

                if let videoUrl = videoUrl {

                    strongSelf.videoUrl = videoUrl
                   
                    DispatchQueue.main.async {
                        
                        strongSelf.rcVideoPlayer.setUpAVPlayer(with: strongSelf.videoView,
                                                               videoUrl: videoUrl,
                                                               videoGravity: .resizeAspect)
                        
                    }
                }
            }
        })
    }
    
    func reset() {
        
//        let path = NSTemporaryDirectory().appending("mergedVideo.mp4")
//
//        let url = URL.init(fileURLWithPath: path)
//
//        print(url)
        
//        if let videoUrl = videoUrl {
//
//            FileManager.default.removeItemIfExisted(at: videoUrl)
//        }
        
        exportButton.isHidden = true
        
        collectionView.isHidden = true
        
        self.navigationItem.title = "Reconds"
    }
}
