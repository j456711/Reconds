//
//  LongPressGesture.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/7.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import Foundation
import UIKit

//class LongPressGesture {
//
//    var target: Any?
//
//    func addGesture() {
//
//        let longPressGesture = UILongPressGestureRecognizer(target: target, action: #selector(longPress(_, <#UICollectionView#>:)))
//    }
//
//    @objc func longPress(_ gesture: UIGestureRecognizer, _ item: UICollectionView) {
//
//        switch gesture.state {
//
//        case .began:
//
//            guard let selectedIndexPath = item.indexPathForItem(at: gesture.location(in: item)) else { return }
//
//            item.beginInteractiveMovementForItem(at: selectedIndexPath)
//
//        case .changed:
//            
//            item.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
//
//        case .ended:
//
//            item.endInteractiveMovement()
//
//        }
//    }
//}
