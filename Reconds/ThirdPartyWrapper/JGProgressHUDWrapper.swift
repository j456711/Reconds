//
//  JGProgressHUDWrapper.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/5/15.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import JGProgressHUD

enum HUDType {
    
    case success
    case failure
    case loading(text: String = "輸出中")
    
    var indicatorView: JGProgressHUDIndicatorView {
        switch self {
        case .success:
            return JGProgressHUDSuccessIndicatorView()
            
        case .failure:
            return JGProgressHUDErrorIndicatorView()
            
        case .loading(_):
            return JGProgressHUDIndeterminateIndicatorView()
        }
    }
    
    var text: String {
        switch self {
        case .success:
            return "輸出成功"
            
        case .failure:
            return "輸出失敗"
            
        case .loading(let text):
            return text
        }
    }
}

class JYProgressHUD {
    
    static private let shared = JYProgressHUD()
    
    private init() {}
    
    private var view: UIView {
        
        return AppDelegate.shared.window!.rootViewController!.view
    }
    
    private let hud = JGProgressHUD(style: .dark)
}

extension JYProgressHUD {
    
    static func show(_ hudType: HUDType) {
        
        if !Thread.isMainThread {
            
            DispatchQueue.main.async { show(hudType) }
            
            return
        }
        
        shared.hud.textLabel.text = hudType.text
        shared.hud.indicatorView = hudType.indicatorView
        
        shared.hud.show(in: shared.view)
        shared.hud.dismiss(afterDelay: 1.5)
    }
    
//    func showSuccess(in view: UIView) {
//
//        hud.textLabel.text = "儲存成功"
//        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
//
//        hud.show(in: view)
//    }
//
//    func showFailure(in view: UIView) {
//
//        hud.textLabel.text = "儲存失敗"
//        hud.indicatorView = JGProgressHUDErrorIndicatorView()
//
//        hud.show(in: view)
//    }
//
//    func showIndeterminate(in view: UIView, with text: String = "輸出中") {
//
//        hud.textLabel.text = text
//        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
//
//        hud.show(in: view)
//    }
    
    static func dismiss() {
        
        shared.hud.dismiss()
    }
}
