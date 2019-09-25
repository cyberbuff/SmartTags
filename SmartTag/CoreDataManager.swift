//
//  CoreDataManager.swift
//  SmartTag
//
//  Created by Nagarajan S on 26/07/18.
//  Copyright © 2018 Naga. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {

    static let sharedInstance = CoreDataManager()
    let coreDataModel = CoreDataModel.sharedInstance
    let managedObjContext = CoreDataModel.sharedInstance.managedObjectContext
    let tagParser = TagParser()
    
    
    
    func parseAndAddDocument(_ attrStr : NSAttributedString)  {
        let docName : String = String(attrStr.string.prefix(20))
        
        addDocument(attrStr,documentName: docName) { (doc) in
            tagParser.detectTagsFromDocument(attrStr, completion: { (tags) in
                
//                print(tags)
                addTags(tags, toDoc: doc, completion: { (status) in
                    coreDataModel.saveContext()
                })
            })
        }
    }
        
    
    fileprivate func addDocument(_ attrMsg : NSAttributedString,documentName : String ,completion: ((Document) -> Void))  {
        let newDocument = Document(context: managedObjContext)
        newDocument.data = attrMsg.toData
        newDocument.name = documentName
        
        
       
        completion(newDocument)
    }
    
    fileprivate func addTags(_ tagObjects : [ML_Tag], toDoc : Document, completion: ((Bool) -> Void)) {
        for tagObject in tagObjects {
            do {
                var tag : Tag?
                
                let fetchRequest : NSFetchRequest<Tag> = Tag.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "name == %@ && type == %@", tagObject.name!, tagObject.group.rawValue)
                
                let fetchedResults = try managedObjContext.fetch(fetchRequest)
                if let aTag = fetchedResults.first {
                   tag = aTag
                }
                else{
                    tag = Tag(context: managedObjContext)
                    tag?.name = tagObject.name
                    tag?.type = tagObject.group.rawValue
                }

                tag?.addToDocuments(toDoc)
            }
            catch{
                
            }
        }
        completion(true)
    }
    
    func purgeAllData()  {
        //getting context from your Core Data Manager Class
        let deleteTagFetch : NSFetchRequest<Tag>  = Tag.fetchRequest()
        let deleteTagRequest = NSBatchDeleteRequest(fetchRequest: deleteTagFetch as! NSFetchRequest<NSFetchRequestResult>)
        
        let deleteDocFetch : NSFetchRequest<Document>  = Document.fetchRequest()
        let deleteDocRequest = NSBatchDeleteRequest(fetchRequest: deleteDocFetch as! NSFetchRequest<NSFetchRequestResult>)
        
        
        do {
            try managedObjContext.execute(deleteTagRequest)
            try managedObjContext.execute(deleteDocRequest)
            try managedObjContext.save()
        } catch {
            print ("There is an error in deleting records")
        }
        
    }
    
}
