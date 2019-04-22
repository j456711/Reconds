//
//  VideoCollection+CoreDataProperties.swift
//  
//
//  Created by YU HSIN YEH on 2019/4/22.
//
//

import Foundation
import CoreData


extension VideoCollection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoCollection> {
        return NSFetchRequest<VideoCollection>(entityName: "VideoCollection")
    }

    @NSManaged public var dataPath: String?
    @NSManaged public var videoTitle: String?

}
