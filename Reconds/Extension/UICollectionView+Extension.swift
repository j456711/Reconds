//
//  UICollectionView+Extension.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/5/4.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func jy_registerCellWithNib(indentifier: String, bundle: Bundle?) {
        
        let nib = UINib(nibName: indentifier, bundle: bundle)
        
        register(nib, forCellWithReuseIdentifier: indentifier)
    }
}
