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

    let rcVideoPlayer = RCVideoPlayer()

    var videoUrls: [String] = []
    
    var videoData: [VideoData] = [] {
        
        didSet {
            
            print("-----------------------------")
            print(videoData)
        }
    }
    
    var longPressedEnabled = false

    @IBOutlet weak var videoView: UIView! {

        didSet {

            videoView.isHidden = true
        }
    }

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

    override func viewDidLoad() {
        super.viewDidLoad()

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))

        collectionView.addGestureRecognizer(longPressGesture)
    }

    override func viewWillAppear(_ animated: Bool) {

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

        return homeCell
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {

        return true
    }

    func collectionView(_ collectionView: UICollectionView,
                        moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        print("Start index: - \(sourceIndexPath.item)")
        print("End index: - \(destinationIndexPath.item)")

//        let tmp = videoUrls[sourceIndexPath.item]
//        videoUrls[sourceIndexPath.item] = videoUrls[destinationIndexPath.item]
//        videoUrls[destinationIndexPath.item] = tmp

        let tmp = videoData[sourceIndexPath.item].dataPath
        videoData[sourceIndexPath.item].dataPath = videoData[destinationIndexPath.item].dataPath
        videoData[destinationIndexPath.item].dataPath = tmp
        
        VideoDataManager.shared.save()
        
        collectionView.reloadData()
    }

}

// MARK: - Long Press Gesture
extension HomeViewController {
    
    @objc func longPress(_ gesture: UIGestureRecognizer) {

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
        
        do {
            
            let alert = UIAlertController.addConfirmAndCancelAlertWith(alertTitle: "確定要刪除影片嗎？", alertMessage: "刪除後則不可回復。")
            
            present(alert, animated: true, completion: nil)
            
            guard let videoUrl = URL(string: videoData[hitIndex.item].dataPath) else { return }
            
            try FileManager.default.removeItem(at: videoUrl)
            
            print("Remove successfully")
        
        } catch {
            
            print("Remove fail", error)
        }
        
        deleteData(at: hitIndex)
        
//        videoUrls.remove(at: hitIndex.item)
        
//        UserDefaults.standard.set(videoUrls, forKey: "VideoUrls")
        
//        print("HomeVC", videoUrls)
        
        collectionView.reloadData()
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
