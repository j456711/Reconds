//
//  VideoTitleView.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/5/11.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit

class VideoTitleView: UIView {

    @IBOutlet weak var descriptionTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            if UserDefaults.standard.string(forKey: "Title") != nil {
             
                titleLabel.text = UserDefaults.standard.string(forKey: "Title")
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
