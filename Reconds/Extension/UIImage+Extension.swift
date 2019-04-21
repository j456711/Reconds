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
    
    case Icon_Check
    case Icon_Export
    case Icon_Film
    case Icon_FilmSelected
    case Icon_Music
    case Icon_Play
    case Icon_Remove
    case Icon_Shoot

    // RCVideoPlayer
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
