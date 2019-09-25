//
//  CoreDataModel.swift
//  SmartTag
//
//  Created by Nagarajan S on 26/07/18.
//  Copyright © 2018 Naga. All rights reserved.
//

import UIKit
import CoreData

let  ZSCoreDataModelFileName : String =   "SmartTag"
let  ZSCoreDataSQLFileName : String = "SmartTag.sqlite"

class CoreDataModel: NSObject {

    static let sharedInstance = CoreDataModel()

    // MARK: - Initialization
    
    override public init() {
        super.init()
        
    }
    
    // MARK: - Core Data Stack
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: ZSCoreDataModelFileName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent(ZSCoreDataSQLFileName)
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ,
                            NSPersistentStoreFileProtectionKey: FileProtectionType.complete] as [String : Any]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
            self.addSkipBackupAttributeToItemAtURL(filePath: (url?.path)!);
            
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    @objc public lazy var managedObjectContext: NSManagedObjectContext = {
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.parent = self.privateManagedObjectContext
        
        return managedObjectContext
    }()
    
    // MARK: - Notification Handling
    
    @objc public func saveChangesToDB() {
        managedObjectContext.performAndWait({
            do {
                if self.managedObjectContext.hasChanges {
                    try self.managedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
        })
        
        privateManagedObjectContext.perform({
            do {
                if self.privateManagedObjectContext.hasChanges {
                    try self.privateManagedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Private Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
        })
    }
    
    // MARK: - Helper Methods
    
    @objc public func saveContext() {
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.cocoacasts.Core_Data" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    private func setupNotificationHandling() {
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(CoreDataModel.saveChangesToDB
//            ), name: NSNotification.Name.ter.willTerminateNotification, object: nil)
//        notificationCenter.addObserver(self, selector: #selector(CoreDataModel.saveChangesToDB), name: NSNotification.Name.UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    
    func addSkipBackupAttributeToItemAtURL(filePath:String)
    {
        let URL:NSURL = NSURL.fileURL(withPath: filePath) as NSURL
        
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try URL.setResourceValue(true, forKey:URLResourceKey.isExcludedFromBackupKey)
            } catch let error as NSError {
                print("Error excluding \(String(describing: URL.lastPathComponent)) from backup \(error)");
            }
        }
    }

}
