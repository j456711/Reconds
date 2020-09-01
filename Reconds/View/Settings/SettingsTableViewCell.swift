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

protocol SettingsTableViewCellDelegate: AnyObject {
    
    func shareApp(_ cell: SettingsTableViewCell)
}

class SettingsTableViewCell: UITableViewCell {

    weak var delegate: SettingsTableViewCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var switcher: UISwitch! {
        didSet {
            switcher.isHidden = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func didSelectedAppSettingsSection(at indexPath: IndexPath) {
        
        switch indexPath.row {

        case 0:
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

        case 1:
            delegate?.shareApp(self)

        default: break
        }
    }
}
