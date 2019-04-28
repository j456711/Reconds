//
//  UIImage+Extension.swift
//  Reconds
//
//  Created by 渡邊君 on 2019/4/9.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit

enum ImageAssets: String {

    // swiftlint:disable identifier_name
    
    case Icon_128px_FilmStrips_Selected
    case Icon_128px_FilmStrips
    case Icon_128px_Settings_Selected
    case Icon_128px_Settings
    case Icon_256px_DownArrow
    case Icon_256px_TrashCan
    case Icon_383px_Share
    case Icon_512px_Clapperboard
    case Icon_Check
    case Icon_Remove
    case Icon_Shoot

    // RCVideoPlayer
    case Icon_128px_Expand
    case Icon_128px_Minimize
    case Icon_Play
    case Icon_PlayController
    case Icon_PauseController
    case Slider_Thumb

    // swiftlint:enable identifier_name
}

extension UIImage {

    static func assets(_ asset: ImageAssets) -> UIImage? {

        return UIImage(named: asset.rawValue)
    }
}
