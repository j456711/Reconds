//
//  MyVideosViewController.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/22.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit

class MyVideosViewController: UIViewController {

    let rcVideoPlayer = RCVideoPlayer()
    
    lazy var videoCollection: [VideoCollection] = []
    
    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.delegate = self
            collectionView.dataSource = self
            
            collectionView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let videoCollection = StorageManager.shared.fetch(VideoCollection.self)
        
        self.videoCollection = videoCollection
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
        
        guard let path = URL(string: FileManager.documentDirectory.absoluteString + videoCollection[indexPath.item].dataPath) else { return cell }
        
        myVideosCell.titleLabel.text = videoCollection[indexPath.item].videoTitle
        myVideosCell.thumbnail.image = rcVideoPlayer.generateThumbnail(path: path)
        
        return myVideosCell
    }
}

extension MyVideosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 32, left: 16, bottom: 32, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (UIScreen.main.bounds.size.width - 48) / 2,
                      height: (UIScreen.main.bounds.size.width - 48) / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 16
    }
}
