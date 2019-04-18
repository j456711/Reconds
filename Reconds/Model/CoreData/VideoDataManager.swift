//
//  VideoDataManager.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/11.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import Foundation
import CoreData

final class VideoDataManager {
    
    private init() {}
    
    static let shared = VideoDataManager()
    
    lazy var context = persistantContainer.viewContext
        
    lazy var persistantContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "VideoDataModel")
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    func save() {
                
        if context.hasChanges {
            
            do {
                
                try context.save()
                                
                print("saved successfully")
                                
            } catch {
                
                let nserror = error as NSError
                
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetch<T: NSManagedObject>(_ objectType: T.Type) -> [T] {
        
        let entityName = String(describing: objectType)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            
            let fetchedObject = try context.fetch(fetchRequest) as? [T]
            
            return fetchedObject ?? [T]()
            
        } catch {
            
            print(error)
            
            return [T]()
        }
    }
    
    func delete(_ entityName: String) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            
            for object in results {
                
                guard let objectData = object as? NSManagedObject else { return }
                
                context.delete(objectData)
                
                save()
            }
            
        } catch {
            
            print("Delete all data in \(entityName) error:", error)
        }
    }
}

extension VideoDataManager {
    
    func createData() {
        
        let videoData = VideoData(context: VideoDataManager.shared.persistantContainer.viewContext)
        
        videoData.dataPathArray.append(contentsOf: ["", "", "", "", "", "", "", "", "", "",
                                                    "", "", "", "", "", "", "", "", "", "",
                                                    "", "", "", "", ""])
        
        VideoDataManager.shared.save()
    }
}
