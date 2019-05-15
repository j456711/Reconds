//
//  MusicTableViewCell.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/21.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MusicTableViewCell: UITableViewCell {
    
    @IBOutlet weak var indicatorView: NVActivityIndicatorView! {
        
        didSet {
            
            indicatorView.color = UIColor.rcOrange
            indicatorView.type = .audioEqualizer
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    func layoutCell(title: String) {
        
        titleLabel.text = title
    }
    
    func cellStatus() {
        
        
    }
}
