//
//  HomeCollectionViewCell.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/3.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var removeButton: UIButton! {
        
        didSet {

            removeButton.isHidden = true
        }
    }

}
