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

    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController is RecordViewController {
            
            let index = StorageManager.shared.filterData()
            
            if index.count == 25 {
                
                let alert =
                    UIAlertController.addConfirmAlertWith(alertTitle: "無法新增影片", alertMessage: "影片數量已達到上限，快去輸出吧！")
                
                present(alert, animated: true, completion: nil)
            
            } else {
            
                let storyboard = UIStoryboard(name: "Record", bundle: nil)
                
                let cameraVC = storyboard.instantiateViewController(withIdentifier: "CameraViewController")
                
                present(cameraVC, animated: true, completion: nil)
            }
            
            return false
            
        } else {
            
            return true
        }
    }

//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//
//        let videoData = StorageManager.shared.fetch(VideoData.self)
//
//        if tabBarController.selectedIndex == 2 && videoData[0].dataPathArray.count == 25 {
//
//            let alert = UIAlertController.addConfirmAlertWith(alertTitle: "無法新增影片", alertMessage: "影片數量已達上限，快去輸出吧！")
//
//            present(alert, animated: true, completion: nil)
//        }
//    }
//
}
