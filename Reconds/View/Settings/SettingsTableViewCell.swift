//
//  SettingsTableViewCell.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/28.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit
import Photos
import StoreKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var switcher: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func didSelectedAuthorizationSection(at indexPath: IndexPath) {
        
        switch indexPath.row {

        case 0: break

        case 1: break

        case 2:
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }

        default: break
        }
    }
    
    func didSelectedAboutSection(at indexPath: IndexPath) {
        
        switch indexPath.row {
            
        case 0:
            SKStoreReviewController.requestReview()
            
        case 1: break
            
        default: break
        }
    }
}
