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
import NVActivityIndicatorView

class HomeViewController: UIViewController, NVActivityIndicatorViewable {
    
    private struct Segue {
        
        static let showMusicVC = "showMusicVC"
    }
    
    let rcVideoPlayer = RCVideoPlayer()
    
    var feedbackGenerator: UIImpactFeedbackGenerator?
    
    var videoUrl: URL?
    
    var filteredArray: [String]?
    
    var videoData: [VideoData] = []
    
    var longPressedEnabled = false
    
    @IBOutlet weak var remindLabel: UILabel!
    
    @IBOutlet weak var iconImage: UIImageView! {
        
        didSet {
            
            iconImage.isHidden = true
        }
    }
    
    @IBOutlet weak var videoTitleView: VideoTitleView! {
        
        didSet {
            
            videoTitleView.isHidden = true
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {

        didSet {

            collectionView.delegate = self
            collectionView.dataSource = self
            
            collectionView.isHidden = true
            collectionView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    @IBOutlet weak var previewButton: UIButton! {

        didSet {

            previewButton.isHidden = true
            
            setUpButtonStyle(for: previewButton, cornerRadius: 17)
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
    
    @IBAction func previewButtonPressed(_ sender: UIButton) {
        
        JYProgressHUD.show(.loading(text: "預覽載入中"))
        
        DispatchQueue.global().async { [weak self] in
            
            guard let strongSelf = self else { return }
            
            strongSelf.merge(completionHandler: {
                
                let viewController = UIStoryboard.record.instantiateViewController(
                    withIdentifier: String(describing: VideoPlaybackViewController.self))
                guard let videoPlaybackVC = viewController as? VideoPlaybackViewController else { return }
                
                if strongSelf.filteredArray?.count == 1 {
                    
                    guard let videoUrl =
                        URL(string: JYFileManager.videoDataDirectory.absoluteString +
                                    strongSelf.videoData[0].dataPathArray[0])
                        else { return }
                    
                    videoPlaybackVC.videoUrl = videoUrl
                    
                } else {
                    
                    videoPlaybackVC.videoUrl = strongSelf.videoUrl
                }
                
                videoPlaybackVC.loadViewIfNeeded()
                
                videoPlaybackVC.controlView.isHidden = true
                
                videoPlaybackVC.modalPresentationStyle = .overFullScreen
                
                strongSelf.present(videoPlaybackVC, animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {

        let filteredArray = StorageManager.shared.filterData()
        
        if filteredArray?.count == 0 {
            
            previewButton.isHidden = true

            exportButton.isHidden = true
        
        } else {
         
            previewButton.isHidden = false
            
            exportButton.isHidden = false
        }
        
        doneButton.isHidden = true
        
        longPressedEnabled = false

        self.filteredArray = filteredArray
        
        collectionView.reloadData()
    }

    @IBAction func exportButtonPressed(_ sender: UIButton) {
    
        JYProgressHUD.show(.loading())
        
        DispatchQueue.global().async { [weak self] in
            
            self?.merge(completionHandler: {
                
                self?.performSegue(withIdentifier: Segue.showMusicVC, sender: self?.videoUrl)
            })
        }
    }
    
    @IBAction func clapperButtonPressed(_ sender: UIBarButtonItem) {

        if collectionView.isHidden == true {

            createProjectNameAlert()
        }
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.jy_registerCellWithNib(indentifier: String(describing: HomeCollectionViewCell.self), bundle: nil)
        
        if UserDefaults.standard.string(forKey: "Title") != nil {

            videoTitleView.isHidden = false
            collectionView.isHidden = false
            iconImage.isHidden = false
        }
       
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        longPressGesture.delegate = self
        
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
                
            } else {
                
                videoTitleView.isHidden = false
                
                collectionView.isHidden = false
                
                iconImage.isHidden = false
                
                previewButton.isHidden = false
                
                exportButton.isHidden = false
            }
            
        } else {

            reset()
        }
        
        self.filteredArray = filteredArray

        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let musicVC = segue.destination as? MusicViewController else { return }
        
        if let videoUrl = sender as? URL {
        
            musicVC.videoUrl = videoUrl
        }
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

                strongSelf.videoTitleView.titleLabel.text = textField.placeholder
                
                UserDefaults.standard.set(textField.placeholder, forKey: "Title")
                                
            } else {

                strongSelf.videoTitleView.titleLabel.text = text
                
                UserDefaults.standard.set(text, forKey: "Title")
            }
            
            if strongSelf.videoData.count == 0 {
                
                StorageManager.shared.createVideoData()
                
                strongSelf.collectionView.reloadData()
            }
            
            strongSelf.collectionView.isHidden = false
            
            strongSelf.iconImage.isHidden = false

            strongSelf.videoTitleView.isHidden = false
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

            return 9

        } else {

            return videoData[0].dataPathArray.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: HomeCollectionViewCell.self), for: indexPath)
        
        guard let homeCell = cell as? HomeCollectionViewCell else { return cell }
        
        homeCell.removeButton.addTarget(self, action: #selector(removeButtonPressed), for: .touchUpInside)
        
        if longPressedEnabled {
            
            homeCell.removeButton.isHidden = false
            
        } else {

            homeCell.removeButton.isHidden = true
        }
        
        if videoData.count == 0 {

            return cell

        } else {
  
            if videoData[0].dataPathArray[indexPath.item] == "" {
                
                homeCell.removeButton.isHidden = true
                
                homeCell.thumbnail.image = nil
                
            } else {
                
                let dataPath =
                    JYFileManager.videoDataDirectory.appendingPathComponent(videoData[0].dataPathArray[indexPath.item])
                
                homeCell.thumbnail.image = rcVideoPlayer.generateThumbnail(path: dataPath)
            }

            return homeCell
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
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        
        if videoData[0].dataPathArray[indexPath.item] == "" {
            
            return false
            
        } else {
            
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
                        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        
        if videoData[0].dataPathArray[proposedIndexPath.item] == "" {

            return originalIndexPath

        } else {

            return proposedIndexPath
        }
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
        
        return CGSize(width: (UIScreen.main.bounds.size.width - 2) / 3,
                      height: (UIScreen.main.bounds.size.width - 2) / 3)
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
extension HomeViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if gestureRecognizer is UILongPressGestureRecognizer {
            
            if filteredArray?.count == 0 || filteredArray?.count == nil {
                
                return false
            }
        }
        
        return true
    }
    
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

        case .ended:
            feedbackGenerator = nil
            
            collectionView.endInteractiveMovement()
            
            exportButton.isHidden = true
            
            doneButton.isHidden = false
            
            longPressedEnabled = true
            
            collectionView.reloadData()
            
        case  .cancelled, .failed:
            feedbackGenerator = nil
            
            collectionView.cancelInteractiveMovement()
            
        default:
            feedbackGenerator = nil
            
            collectionView.cancelInteractiveMovement()
        }
    }

    @objc func removeButtonPressed(_ sender: UIButton) {

        let hitPoint = sender.convert(CGPoint.zero, to: collectionView)

        guard let hitIndex = collectionView.indexPathForItem(at: hitPoint) else { return }
        
        UIAlertController.addDeleteActionSheet(viewController: self, deleteActionHandler: { [ weak self] (_) in
            
            do {
                
                guard let strongSelf = self else { return }
                
                if strongSelf.videoData.count != 0 {
                    
                    let dataPath =
                        JYFileManager.videoDataDirectory.appendingPathComponent(
                            strongSelf.videoData[0].dataPathArray[hitIndex.item])
                    
                    try FileManager.default.removeItem(at: dataPath)
                    
                    strongSelf.videoData[0].dataPathArray.remove(at: hitIndex.item)
                    
                    strongSelf.videoData[0].dataPathArray.insert("", at: 8)
                    
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
        
        let viewController = UIStoryboard.record.instantiateViewController(
            withIdentifier: String(describing: VideoPlaybackViewController.self))
        guard let videoPlaybackVC = viewController as? VideoPlaybackViewController else { return }

        if videoData[0].dataPathArray[hitIndex.item] != "" {

            let dataPath =
                JYFileManager.videoDataDirectory.appendingPathComponent(videoData[0].dataPathArray[hitIndex.item])

            videoPlaybackVC.videoUrl = dataPath

            videoPlaybackVC.loadViewIfNeeded()

            videoPlaybackVC.controlView.isHidden = true

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
    
    func merge(completionHandler: @escaping () -> Void) {
        
        guard let filteredArray = StorageManager.shared.filterData() else { return }
        
        let stringArray = filteredArray.map({ JYFileManager.videoDataDirectory.absoluteString + $0 })

        guard let urlArray = stringArray.map({ URL(string: $0) }) as? [URL] else { return }

        let avAssetArray = urlArray.map({ AVAsset(url: $0) })

        MergeVideoManager.shared.mergeVideos(arrayVideos: avAssetArray,
                                             completionHandler: { [weak self] (videoUrl, _, error) in

            guard let strongSelf = self else { return }

            if let error = error {

                DispatchQueue.main.async {
                    
                    print("HomeVC merge error: \(error.localizedDescription)")
                }

            } else {

                if let videoUrl = videoUrl {

                    DispatchQueue.main.async {
                        
                        strongSelf.videoUrl = videoUrl
                        
                        JYProgressHUD.dismiss()
                        
                        completionHandler()
                    }
                }
            }
        })
    }
}

// MARK: - Element Settings
extension HomeViewController {
    
    func setUpButtonStyle(for button: UIButton, cornerRadius: CGFloat = 20) {
        
        button.layer.cornerRadius = cornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.rcOrange.cgColor
    }
    
    func reset() {
        
        videoTitleView.isHidden = true
        
        collectionView.isHidden = true
        
        iconImage.isHidden = true
        
        previewButton.isHidden = true
        
        exportButton.isHidden = true
    }
}
