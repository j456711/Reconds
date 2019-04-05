//
//  TabBarViewController.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/3.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit
import MobileCoreServices

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        if viewController is RecordViewController {

            let cameraController = CameraViewController()
            
            present(cameraController, animated: true, completion: nil)
//            let imagePicker = UIImagePickerController()
//
//            imagePicker.delegate = self
//
//            imagePicker.sourceType = .camera
//
//            imagePicker.mediaTypes = [kUTTypeMovie as String]
//
//            imagePicker.cameraCaptureMode = .video
//
//            imagePicker.allowsEditing = false
//
//            imagePicker.videoMaximumDuration = 1.0
//
//            present(imagePicker, animated: true, completion: nil)

            return false

        } else {

            return true
        }
    }

}

extension TabBarController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}
