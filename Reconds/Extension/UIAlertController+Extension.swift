//
//  UIAlertController+Extension.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/7.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import Foundation
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
    
//    static func addActionSheetAlert(viewController: UIViewController,
//                                    alertTitle: String?,
//                                    alertMessage: String?,
//                                    actions: [String],
//                                    actionStyle: [UIAlertAction.Style],
//                                    actionHandler: UIAlertActionHandler) {
//
//        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
//
//        let actions = actions
//
//        for action in actions {
//
//            let action = UIAlertAction(title: action, style: .style, handler: actionHandler)
//
//            alert.addAction(action)
//        }
//
//        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
//
//        alert.addAction(cancelAction)
//
//        viewController.present(alert, animated: true, completion: nil)
//    }
}
