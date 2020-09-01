//
//  MyVideosCollectionViewCell.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/22.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit

class MyVideosCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
 
    func layoutCell(title: String, thumbnail: UIImage?) {
        
        titleLabel.text = title
        self.thumbnail.image = thumbnail
    }
}
