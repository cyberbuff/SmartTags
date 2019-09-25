//
//  PreviewController.swift
//  SmartTag
//
//  Created by yokesh-7095 on 27/07/18.
//  Copyright © 2018 Naga. All rights reserved.
//

import UIKit
import CoreData

class PreviewController: UIViewController {
    
    let coredatamanager = CoreDataManager.sharedInstance
    
    var documentTags : Set<Tag> {
        return (document?.tags)! as! Set<Tag>
    }
 
    @IBOutlet weak var previewTextView: UITextView!
    
    @IBOutlet weak var previewCollectionView: UICollectionView!
    
    var document : Document? = nil
    
    override func viewDidLoad() {
        
        guard let data = document?.data else {
            return
        }
        
        let attributeString = data.toAttributedString
//        attributeString?.enumerateAttribute(.attachment, in: NSMakeRange(0, (attributeString?.length)!), options: NSAttributedString.EnumerationOptions(rawValue: 0), using: { (value, range, stop) in
//            
//            if let attach = value as? NSTextAttachment{
//                let screenSize = UIScreen.main.bounds.width
//                let scale = screenSize / attach.bounds.width
//                let newRect = CGRect(x: attach.bounds.origin.x, y: attach.bounds.origin.y, width: screenSize, height: attach.bounds.size.height * scale)
//                attach.bounds = newRect
//        
//            }
//        })
        
        
        
        previewTextView.attributedText = attributeString//data.toAttributedString
        
    }
    
}

extension PreviewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documentTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionCell", for: indexPath) as? TagCollectionCell else {
            return UICollectionViewCell()
        }
        
        let obj = Array(documentTags)[indexPath.item]
        cell.tagLabel.text = obj.name
        cell.tagTypeLabel.text = obj.type ?? ""
        return cell;
    }
}
