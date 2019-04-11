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

    static func addConfirmAlertWith(alertTitle: String?,
                                           alertMessage: String?,
                                           actionHandler: UIAlertActionHandler = nil) -> UIAlertController {

        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "確定", style: .default, handler: actionHandler)

        alert.addAction(confirmAction)

        return alert
    }
    
    static func addConfirmAndCancelAlertWith(alertTitle: String?,
                                             alertMessage: String?,
                                             actionHandler: UIAlertActionHandler = nil) -> UIAlertController {
    
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "確定", style: .default, handler: actionHandler)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: actionHandler)
        
        alert.addAction(confirmAction)
        
        alert.addAction(cancelAction)
        
        return alert
    }
}
