//
//  SettingsTableViewCell.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/28.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var switcher: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
