//
//  UIAlertController+Extension.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/7.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit

extension UIAlertController {

    typealias UIAlertActionHandler = ((UIAlertAction) -> Void)?

    static func addConfirmAlertWith(viewController: UIViewController,
                                    alertTitle: String?,
                                    alertMessage: String?,
                                    actionHandler: UIAlertActionHandler = nil) {

        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "確定", style: .default, handler: actionHandler)

        alert.addAction(confirmAction)

        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func addConfirmAndCancelAlertWith(viewController: UIViewController,
                                             alertTitle: String?,
                                             alertMessage: String?,
                                             confirmActionHandler: UIAlertActionHandler = nil) {
    
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "確定", style: .default, handler: confirmActionHandler)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func addDeleteActionSheet(viewController: UIViewController, deleteActionHandler: UIAlertActionHandler) {
        
        let alert = UIAlertController(title: "即將刪除此影片，此動作無法還原。", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "刪除影片", style: .destructive, handler: deleteActionHandler)
        
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
