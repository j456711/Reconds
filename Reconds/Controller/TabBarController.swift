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
            
            let filteredArray = StorageManager.shared.filterData()
            
            // 不能是空 [] 的原因是因為剛開啟專案會沒有mp4檔案，但是已經有collectionView可以拍影片了，所以要修改
            if filteredArray == nil {

                let alert =
                    UIAlertController.addConfirmAlertWith(alertTitle: "請先新增專案", alertMessage: "新增後即可開始錄製。")

                present(alert, animated: true, completion: nil)

            } else if filteredArray?.count == 25 {
                
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
}
