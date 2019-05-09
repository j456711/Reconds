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

class HomeViewController: UIViewController {
    
    private struct Segue {
        
        static let showMusicVC = "showMusicVC"
    }
    
    let rcVideoPlayer = RCVideoPlayer()
    
    var feedbackGenerator: UIImpactFeedbackGenerator?
    
    lazy var videoUrl: URL? = nil
    
    var filteredArray: [String]?
    
    var videoData: [VideoData] = []
    
    var longPressedEnabled = false
    
    @IBOutlet weak var remindLabel: UILabel!
    
    @IBOutlet weak var descriptionTitleLabel: UILabel! {
        
        didSet {
            
            descriptionTitleLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        
        didSet {
            
            titleLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var iconImage: UIImageView! {
        
        didSet {
            
            iconImage.isHidden = true
        }
    }
    
    @IBOutlet weak var indicatorView1: NVActivityIndicatorView!
    
    @IBOutlet weak var indicatorView2: NVActivityIndicatorView!
    
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

            setUpButtonStyle(for: exportButton, cornerRadius: 20)
        }
    }
    
    @IBOutlet weak var doneButton: UIButton! {

        didSet {

            doneButton.isHidden = true

            setUpButtonStyle(for: doneButton, cornerRadius: 20)
        }
    }
    
    @IBAction func previewButtonPressed(_ sender: UIButton) {
        
        let viewController = UIStoryboard.record.instantiateViewController(
            withIdentifier: String(describing: VideoPlaybackViewController.self))
        guard let videoPlaybackVC = viewController as? VideoPlaybackViewController else { return }
        
        if filteredArray?.count == 1 {
        
            guard let videoUrl =
                URL(string: FileManager.videoDataDirectory.absoluteString + videoData[0].dataPathArray[0])
                else { return }
        
            videoPlaybackVC.videoUrl = videoUrl
            
        } else {
            
            videoPlaybackVC.videoUrl = videoUrl
        }
        
        videoPlaybackVC.loadViewIfNeeded()
        
        videoPlaybackVC.controlView.isHidden = true
        
        videoPlaybackVC.modalPresentationStyle = .overFullScreen
        
        present(videoPlaybackVC, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {

        doneButton.isHidden = true
        
        previewButton.isHidden = true
        
        longPressedEnabled = false

        collectionView.reloadData()
        
        indicatorView1.startAnimating()
        
        indicatorView2.startAnimating()
        
        DispatchQueue.global().async { [weak self] in

            self?.merge()
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
        
        FileManager.default.jy_createDirectory("Exported")
        FileManager.default.jy_createDirectory("VideoData")
        
        collectionView.jy_registerCellWithNib(indentifier: String(describing: HomeCollectionViewCell.self), bundle: nil)
        
        guard let title = UserDefaults.standard.string(forKey: "Title") else { return }
        
        if title != "" {

            descriptionTitleLabel.isHidden = false
            titleLabel.isHidden = false
            titleLabel.text = title
            
            collectionView.isHidden = false
            iconImage.isHidden = false
        }
       
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
       
        collectionView.addGestureRecognizer(longPressGesture)
        collectionView.addGestureRecognizer(tapGesture)
        
//        longPressGesture.delegate = self
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
                
                descriptionTitleLabel.isHidden = false
                
                titleLabel.isHidden = false

                collectionView.isHidden = false
                
                iconImage.isHidden = false
                
                indicatorView1.startAnimating()
                
                indicatorView2.startAnimating()
                
                DispatchQueue.global().async { [weak self] in
 
                    self?.merge()
                }
            }
            
        } else {

            reset()
        }
        
        self.filteredArray = filteredArray
        
        collectionView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        previewButton.isHidden = true
        
        exportButton.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let musicVC = segue.destination as? MusicViewController else { return }
        
        musicVC.videoUrl = videoUrl
    }
    
    func setUpButtonStyle(for button: UIButton, cornerRadius: CGFloat) {
        
        button.layer.cornerRadius = cornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.rcOrange.cgColor
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

                strongSelf.titleLabel.text = textField.placeholder
                
                UserDefaults.standard.set(textField.placeholder, forKey: "Title")
                                
            } else {

                strongSelf.titleLabel.text = text
                
                UserDefaults.standard.set(text, forKey: "Title")
            }
            
            if strongSelf.videoData.count == 0 {
                
                StorageManager.shared.createVideoData()
                
                strongSelf.collectionView.reloadData()
            }
            
            strongSelf.collectionView.isHidden = false
            
            strongSelf.iconImage.isHidden = false

            strongSelf.descriptionTitleLabel.isHidden = false
            
            strongSelf.titleLabel.isHidden = false
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
        
        homeCell.removeButton.addTarget(self, action: #selector(removeButtonPressed), for: .touchUpInside)
        
        if longPressedEnabled {

            previewButton.isHidden = true
            
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
                    FileManager.videoDataDirectory.appendingPathComponent(videoData[0].dataPathArray[indexPath.item])
                
                    homeCell.thumbnail.image = rcVideoPlayer.generateThumbnail(path: dataPath)
            }

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
extension HomeViewController: UIGestureRecognizerDelegate {
    
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        
//        if let longPressGesture = gestureRecognizer as? UILongPressGestureRecognizer {
//
//            if filteredArray?.count == 0 {
//
//                return false
//
//            } else {
//
//                return true
//            }
//        }
//
//        return true
//    }
    
    @objc func longPressAction(_ gesture: UIGestureRecognizer) {

        switch gesture.state {

        case .began:
            feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            
//            if filteredArray?.count == 0 {
//
//                feedbackGenerator = nil
//
//            } else {
            
                feedbackGenerator?.impactOccurred()
//            }
            
            guard let selectedIndexPath =
                collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { return }
            
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))

        case .ended:
            
//            if filteredArray?.count == 0 {
//
//                break
//
//            } else {
            
                feedbackGenerator = nil
                
                collectionView.endInteractiveMovement()
                
                exportButton.isHidden = true
                
                doneButton.isHidden = false
                
                longPressedEnabled = true
                
                collectionView.reloadData()
//            }
            
        case  .cancelled, .failed:
            collectionView.cancelInteractiveMovement()
            
        default:
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
        
        let viewController = UIStoryboard.record.instantiateViewController(
            withIdentifier: String(describing: VideoPlaybackViewController.self))
        guard let videoPlaybackVC = viewController as? VideoPlaybackViewController else { return }

        if videoData[0].dataPathArray[hitIndex.item] != "" {

            let dataPath =
                FileManager.videoDataDirectory.appendingPathComponent(videoData[0].dataPathArray[hitIndex.item])

            videoPlaybackVC.videoUrl = dataPath

            videoPlaybackVC.loadViewIfNeeded()

            videoPlaybackVC.controlView.isHidden = true

            videoPlaybackVC.modalPresentationStyle = .overFullScreen

            present(videoPlaybackVC, animated: true, completion: nil)
        }
    }
    
    @objc func panAction(_ gesture: UIGestureRecognizer) {
        
        var initialTouchPoint = CGPoint(x: 0, y: 0)
        
        let touchPoint = gesture.location(in: self.view.window)
        
        switch gesture.state {
            
        case .began:
            initialTouchPoint = touchPoint
            
        case .changed:
            if touchPoint.y - initialTouchPoint.y > 0 {
                
                self.view.frame = CGRect(x: 0,
                                         y: (touchPoint.y - initialTouchPoint.y),
                                         width: self.view.frame.size.width,
                                         height: self.view.frame.size.height)
            }
            
        case .ended, .cancelled:
            if touchPoint.y - initialTouchPoint.y > 100 {
                
                self.dismiss(animated: true, completion: nil)
                
            } else {
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.view.frame = CGRect(x: 0,
                                             y: 0,
                                             width: self.view.frame.size.width,
                                             height: self.view.frame.size.height)
                })
            }
            
        default: break
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
                                             completionHandler: { [weak self] (videoUrl, _, error) in

            guard let strongSelf = self else { return }

            if let error = error {

                DispatchQueue.main.async {
                    
                    strongSelf.indicatorView1.stopAnimating()
                    
                    strongSelf.indicatorView2.stopAnimating()
                    
                    print("HomeVC merge error: \(error.localizedDescription)")
                }

            } else {

                if let videoUrl = videoUrl {

                    DispatchQueue.main.async {
                        
                        strongSelf.videoUrl = videoUrl
                        
                        strongSelf.previewButton.isHidden = false
                        
                        strongSelf.exportButton.isHidden = false
                        
                        strongSelf.indicatorView1.stopAnimating()
                        
                        strongSelf.indicatorView2.stopAnimating()
                    }
                }
            }
        })
    }
    
    func reset() {
        
        descriptionTitleLabel.isHidden = true
        
        titleLabel.isHidden = true
        
        collectionView.isHidden = true
        
        iconImage.isHidden = true
        
        exportButton.isHidden = true
    }
}
