//
//  MyVideosViewController.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/22.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit

class MyVideosViewController: UIViewController {

    struct Segue {
        
        static let showMyVideosDetail = "showMyVideosDetail"
    }
    
    let rcVideoPlayer = RCVideoPlayer()
    
    var videoCollection: [VideoCollection] = []
    
    @IBOutlet weak var emptyLabel: UILabel! {
        
        didSet {
        
            emptyLabel.isHidden = false
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.delegate = self
            collectionView.dataSource = self
            
            collectionView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let videoCollection = StorageManager.shared.fetch(VideoCollection.self)
        
        self.videoCollection = videoCollection
        
        if videoCollection.count > 0 {
            
            emptyLabel.isHidden = true
        }
        
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let myVideosDetailVC = segue.destination as? MyVideosDetailViewController else { return }
        
        if let sender = sender as? IndexPath {
        
            myVideosDetailVC.indexPath = sender
            myVideosDetailVC.videoTitle = videoCollection[sender.item].videoTitle
            myVideosDetailVC.videoUrl =
                FileManager.exportedDirectory.appendingPathComponent("\(videoCollection[sender.item].dataPath)")
        }
    }
}

extension MyVideosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return videoCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MyVideosCollectionViewCell.self),
                                               for: indexPath)
        
        guard let myVideosCell = cell as? MyVideosCollectionViewCell else { return cell }
        
        let filePath =
            FileManager.exportedDirectory.appendingPathComponent("\(videoCollection[indexPath.item].dataPath)")
                
        myVideosCell.titleLabel.text = videoCollection[indexPath.item].videoTitle
        myVideosCell.thumbnail.image = rcVideoPlayer.generateThumbnail(path: filePath)
        
        return myVideosCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: Segue.showMyVideosDetail, sender: indexPath)
    }
}

extension MyVideosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (UIScreen.main.bounds.size.width - 57) / 2,
                      height: (UIScreen.main.bounds.size.width - 57) / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 25
    }
}
