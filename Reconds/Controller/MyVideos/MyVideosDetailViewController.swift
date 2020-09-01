//
//  MyVideosDetailViewController.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/24.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit

class MyVideosDetailViewController: UIViewController {
        
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }

    let rcVideoPlayer = RCVideoPlayer()
    
    var indexPath: IndexPath?
    var videoTitle: String?
    var videoUrl: URL?
    var videoCollection: [VideoCollection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let videoUrl = videoUrl {
            
            thumbnail.image = rcVideoPlayer.generateThumbnail(path: videoUrl)
        }
        
        textField.text = videoTitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let videoCollection = StorageManager.shared.fetch(VideoCollection.self)
        
        self.videoCollection = videoCollection
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
}

// MARK: - Actions
extension MyVideosDetailViewController {
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        
        let viewController = UIStoryboard.record.instantiateViewController(
            withIdentifier: String(describing: VideoPlaybackViewController.self))
        guard let videoPlaybackVC = viewController as? VideoPlaybackViewController else { return }
        
        videoPlaybackVC.videoUrl = videoUrl
        
        videoPlaybackVC.loadViewIfNeeded()
        
        videoPlaybackVC.controlView.isHidden = true
        
        videoPlaybackVC.modalPresentationStyle = .overFullScreen
        
        present(videoPlaybackVC, animated: true, completion: nil)
    }
    
    @IBAction func textFieldEdited(_ sender: UITextField) {
        
        if let indexPath = indexPath,
           let text = textField.text {
    
            videoCollection[indexPath.item].videoTitle = text
            
            StorageManager.shared.save()
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
    
        if let videoUrl = videoUrl {
        
            let activityController = UIActivityViewController(activityItems: [videoUrl], applicationActivities: nil)
            
            activityController.popoverPresentationController?.sourceView = view
            activityController.popoverPresentationController?.sourceRect = view.frame
            
            present(activityController, animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
    
        UIAlertController.addDeleteActionSheet(viewController: self, deleteActionHandler: { [weak self] (_) in
            
            guard let strongSelf = self else { return }
            
            if let indexPath = strongSelf.indexPath {
                
                StorageManager.shared.context.delete(strongSelf.videoCollection[indexPath.item])
                StorageManager.shared.save()
                
                strongSelf.navigationController?.popViewController(animated: true)
            }
        })
    }
}

// MARK: - UITextFieldDelegate
extension MyVideosDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
}
