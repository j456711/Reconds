//
//  JGProgressHUDWrapper.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/5/15.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import JGProgressHUD

class JYProgressHUD {
    
    static let shared = JYProgressHUD()
    
    let hud = JGProgressHUD(style: .dark)
    
    func showSuccess(in view: UIView, with text: String = "儲存成功") {
        
        hud.textLabel.text = text
        
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        
        hud.show(in: view)
    }
    
    func showFailure(in view: UIView, with text: String = "儲存失敗") {
        
        hud.textLabel.text = text
        
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        
        hud.show(in: view)
    }
}
