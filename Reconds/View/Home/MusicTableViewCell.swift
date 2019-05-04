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
            
            indicatorView.type = .audioEqualizer
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected == true {

            titleLabel.textColor = UIColor.orange
        }
    }

}
