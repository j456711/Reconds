//
//  VideoData+CoreDataProperties.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/11.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//
//

import Foundation
import CoreData

extension VideoData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoData> {
        return NSFetchRequest<VideoData>(entityName: "VideoData")
    }

    @NSManaged public var dataPathArray: [String]
    
}
