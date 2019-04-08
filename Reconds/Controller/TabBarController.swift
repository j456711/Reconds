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
                            
                let storyboard = UIStoryboard(name: "Record", bundle: nil)
            
                let cameraVC = storyboard.instantiateViewController(withIdentifier: "CameraViewController")
            
                present(cameraVC, animated: true, completion: nil)

            return false

        } else {

            return true
        }
    }

}

extension TabBarController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}
