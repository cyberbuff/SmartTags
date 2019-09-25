//
//  ViewController.swift
//  SmartTag
//
//  Created by Nagarajan S on 26/07/18.
//  Copyright © 2018 Naga. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var tagCollectionView: UICollectionView!
    
    let userDefaults = UserDefaults.standard
    let coredatamanager = CoreDataManager.sharedInstance
    
    var blockOperations: [BlockOperation] = []
    
    var shouldReloadCollectionView = false
    
    var tagArray : [Tag] {
        
            let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
            
            do {
                let tags =  try coredatamanager.managedObjContext.fetch(fetchRequest)
                return tags
            } catch  {
                let fetchError = error as NSError
                print("Unable to Perform Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
            return []
        
    }
    
    var selectedTags : Set<Tag> = []
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Document.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Configure Fetch Request
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coredatamanager.managedObjContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userDefaults.value(forKey: "initialSync") == nil {
            createDumpData()
        }
  
        
        // Fetch Data from Core Data
        do {
            try  fetchedResultsController.performFetch()
        } catch  {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewDocument" {
            // New Documents Controller
        }else if segue.identifier == "Preview" {
            let preview = segue.destination as? PreviewController
           let indexPath =  myCollectionView.indexPath(for: sender as! CollectionViewCell)
            let obj = fetchedResultsController.object(at: indexPath!) as? Document
            preview?.document = obj

        }
    }
    
    func createDumpData() {
        coredatamanager.purgeAllData()
        
        let files = ["Business","Entertainment","Politics","Sports","Technology"]

        for file in files {
                        let resourcePath = Bundle.main.path(forResource: file, ofType: "txt")
            guard let path = resourcePath else {
                return
            }

            let data = FileManager.default.contents(atPath: path)
            coredatamanager.parseAndAddDocument(NSAttributedString(string: String(data: data!, encoding: .utf8)!))

        }
        

/*        for i in 1...39{
            let filename = String(i)
            if(i != 23) {continue;}
            if let fileURL = Bundle.main.url(forResource: filename, withExtension: "rtfd") {

                do {

                    let attributedString = try NSAttributedString(url: fileURL, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                    let parts =  attributedString.getParts()
                    print(parts)
//                    coredatamanager.parseAndAddDocument(attributedString)
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
        }
        */
        
        let attachment  = NSTextAttachment()
        attachment.image = UIImage(named: "vehicle4.jpg")
        let iconStringdString = NSAttributedString(attachment: attachment)

        let attachment2  = NSTextAttachment()
        attachment2.image = UIImage(named: "food1.jpg")
        let iconStringdString2 = NSAttributedString(attachment: attachment2)

        let fString = NSMutableAttributedString(string: "")
        fString.append(iconStringdString)
        coredatamanager.parseAndAddDocument(fString)
        
        let fString1 = NSMutableAttributedString(string: "")
        fString1.append(iconStringdString2)
        coredatamanager.parseAndAddDocument(fString1)
        

        for i in 1...22{
            let filename = String(i)
            if let filePath = Bundle.main.path(forResource: filename, ofType: "txt") {

                let data = FileManager.default.contents(atPath: filePath)

                let attributedString = NSAttributedString(string: String(data: data!, encoding: .utf8)!)
                coredatamanager.parseAndAddDocument(attributedString)
            }
        }
        
//
//        for i in 1...39{
//            let filename = String(i)
//            if(i != 1) {return;}
//            if let fileURL = Bundle.main.url(forResource: filename, withExtension: "rtf") {
//
//
//                do {
//                    let attributedString = try NSAttributedString(url: fileURL, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
//                    coredatamanager.parseAndAddDocument(attributedString)
//                } catch {
//                    print("\(error.localizedDescription)")
//                }
//            }
//        }
        

    }
    
    deinit {
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    
    func updateMainCollectionView() {
        
      //  var searchPredicate : NSPredicate? = nil
        var predicateArray = [NSPredicate]()
        
//        if let searchText = searchController?.searchBar.text , searchText.count > 0 {
//            searchPredicate = NSPredicate(format: "name contains[c] %@", searchText)
//            predicateArray.append(searchPredicate!)
//        }
        
        var tagPredicate : NSPredicate? = nil;
        if selectedTags.count > 0 {
            tagPredicate = NSPredicate(format: "SOME tags IN %@", selectedTags)
            predicateArray.append(tagPredicate!)
        }
        
        self.fetchedResultsController.fetchRequest.predicate = (predicateArray.count > 0) ? NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray) : nil
        
        do {
            try  self.fetchedResultsController.performFetch()
            self.myCollectionView.reloadData()
        } catch  {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
    }
    
}




extension ViewController : UICollectionViewDataSource  {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if collectionView.tag == 100 {
            return 1;
        }
        
        return (fetchedResultsController.sections?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 100 {
            return tagArray.count;
        }
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 100 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionCell", for: indexPath) as? TagCollectionCell else {
                return UICollectionViewCell()
            }
            let obj = tagArray[indexPath.item]
            cell.tagLabel.text = obj.type
            if selectedTags.contains(obj) {
                cell.contentView.backgroundColor = .green
            }else{
                cell.contentView.backgroundColor = .yellow
            }
            return cell;
            
        }
    
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let obj = fetchedResultsController.object(at: indexPath) as? Document
        if let data = obj?.data {

            cell.label.attributedText = data.toAttributedString
           // cell.label.text = String(data: data, encoding: .utf8)!
            cell.docNameLabel.text = obj?.name
        }
        
        return cell
    
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let reuseView = collectionView.dequeueReusableSupplementaryView(ofKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "CollectionViewSearchBar", for: indexPath)
//        
//        reuseView.addSubview(searchController.searchBar)
//        searchController.searchBar.sizeToFit()
//        
//        return reuseView
//        
//    }
    
    
}


extension ViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 100 {
            let cell = collectionView.cellForItem(at: indexPath)
            
            let obj = tagArray[indexPath.item]
            if selectedTags.contains(obj) {
                selectedTags.remove(obj)
                cell?.contentView.backgroundColor = .yellow
            }else{
                selectedTags.insert(obj)
                cell?.contentView.backgroundColor = .green
            }
            
            updateMainCollectionView()
        }
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 100 {
            return CGSize(width: 80, height: 70)
        }
        
        let totalColumns : CGFloat = 2
        let padding: CGFloat =  30
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/totalColumns, height: collectionViewSize/totalColumns)
        
    }
}

extension ViewController : NSFetchedResultsControllerDelegate {
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == .insert {
            
            if (myCollectionView?.numberOfSections)! > 0 {
                
                if myCollectionView?.numberOfItems( inSection: newIndexPath!.section ) == 0 {
                    self.shouldReloadCollectionView = true

                } else {
                    myCollectionView.performBatchUpdates({
                        myCollectionView.insertItems(at: [newIndexPath!])
                    }) { (completion) in
                        
                    }
//                    blockOperations.append(
//                        BlockOperation(block: { [weak self] in
//                            if let this = self {
//                                DispatchQueue.main.async {
//                                    this.myCollectionView.insertItems(at: [newIndexPath!])
//                                }
//                            }
//                        })
//                    )
                }
                
            } else {
                self.shouldReloadCollectionView = true
            }
        }
        else if type == .update {
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            
                            this.myCollectionView.reloadItems(at: [indexPath!])
                        }
                    }
                })
            )
        }
        else if type == .move {
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.myCollectionView.moveItem(at: indexPath!, to: newIndexPath!)
                        }
                    }
                })
            )
        }
        else if type == .delete {
            if myCollectionView?.numberOfItems( inSection: indexPath!.section ) == 1 {
                self.shouldReloadCollectionView = true
            } else {
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let this = self {
                            DispatchQueue.main.async {
                                this.myCollectionView!.deleteItems(at: [indexPath!])
                            }
                        }
                    })
                )
            }
        }
    }
    
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if type == .insert {
            print("Insert Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.myCollectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    }
                })
            )
        }
        else if type == .update {
            print("Update Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.myCollectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    }
                })
            )
        }
        else if type == .delete {
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.myCollectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    }
                })
            )
        }
    }
    
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
        if (self.shouldReloadCollectionView) {
            DispatchQueue.main.async {
                self.myCollectionView.reloadData();
            }
        } else {
            DispatchQueue.main.async {
                self.myCollectionView!.performBatchUpdates({ () -> Void in
                    for operation: BlockOperation in self.blockOperations {
                        operation.start()
                    }
                }, completion: { (finished) -> Void in
                    self.blockOperations.removeAll(keepingCapacity: false)
                    self.myCollectionView.reloadData()
                })
            }
        }
    }
    
    
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return "Fetch"
    }
    
    
    
}


