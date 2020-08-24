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
    
    private init() {}
    
    private let hud = JGProgressHUD(style: .dark)
}

extension JYProgressHUD {
    
    func showSuccess(in view: UIView) {
        
        hud.textLabel.text = "儲存成功"
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        
        hud.show(in: view)
    }
    
    func showFailure(in view: UIView) {
        
        hud.textLabel.text = "儲存失敗"
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        
        hud.show(in: view)
    }
    
    func showIndeterminate(in view: UIView, with text: String = "輸出中") {
        
        hud.textLabel.text = text
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        
        hud.show(in: view)
    }
    
    func dismiss() {
        
        hud.dismiss()
    }
}
