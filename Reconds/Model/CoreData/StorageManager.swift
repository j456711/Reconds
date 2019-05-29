//
//  StorageManager.swift
//  Reconds
//
//  Created by YU HSIN YEH on 2019/4/11.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import Foundation
import CoreData

final class StorageManager {
    
    private init() {}
    
    static let shared = StorageManager()
    
    lazy var context = persistantContainer.viewContext
        
    lazy var persistantContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Reconds")
        
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
    
    func deleteAll(_ entityName: String) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            for object in results {
                
                guard let objectData = object as? NSManagedObject else { return }
                
                context.delete(objectData)
                
                print("Deleted successfully")
                
                save()
            }
            
        } catch {
            
            print("Delete all data in \(entityName) error:", error)
        }
    }
}

extension StorageManager {
    
    func createVideoData() {
        
        let videoData = VideoData(context: persistantContainer.viewContext)
        
        videoData.dataPathArray.append(contentsOf: ["", "", "", "", "", "", "", "", ""])
        
        save()
    }
    
    func filterData() -> [String]? {
        
        let videoData = fetch(VideoData.self)
        
        let searchToSearch = ".mp4"
        
        if videoData == [] {

            return nil

        } else {
//
            let filteredArray = videoData[0].dataPathArray.filter({ (element: String) -> Bool in
                
                let stringMatch = element.lowercased().range(of: searchToSearch.lowercased())
                
                // question ? answer1 : answer2
                return stringMatch != nil ? true : false
            })
            
            return filteredArray
        }
    }
}
