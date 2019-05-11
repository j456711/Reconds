//
//  MyVideosDetailViewController.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/24.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit

class MyVideosDetailViewController: UIViewController {

    let rcVideoPlayer = RCVideoPlayer()
    
    var indexPath: IndexPath?
    
    var videoTitle: String?
    
    var videoUrl: URL?
    
    var videoCollection: [VideoCollection] = []
        
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var textField: UITextField!
    
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
    
        let activityController = UIActivityViewController(activityItems: [videoUrl as Any], applicationActivities: nil)
        
        activityController.popoverPresentationController?.sourceView = view
        activityController.popoverPresentationController?.sourceRect = view.frame
        
        present(activityController, animated: true, completion: nil)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.delegate = self
        
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

extension MyVideosDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
}
