//
//  SearchDisplayViewController.swift
//  SmartTag
//
//  Created by yokesh-7095 on 27/07/18.
//  Copyright © 2018 Naga. All rights reserved.
//

import UIKit
import CoreData

class SearchDisplayViewController: UIViewController {

    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    
    let coredatamanager = CoreDataManager.sharedInstance
    
    var blockOperations: [BlockOperation] = []
    
    var shouldReloadCollectionView = false
    
    var selectedTags : Set<Tag> = []

    var searchViewController : SearchDisplayController {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let searchView = (storyBoard.instantiateViewController(withIdentifier: "SearchDisplayController") as? SearchDisplayController)!
        searchView.delegate = self
        return searchView
    }
    
    var searchController : UISearchController? {
        let controller = UISearchController(searchResultsController: searchViewController)
        controller.searchResultsUpdater = self
        controller.searchBar.delegate  = self
        controller.dimsBackgroundDuringPresentation = true
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearch()
        
        tagCollectionView.dataSource = nil
        mainCollectionView.dataSource = nil
        
        // Do any additional setup after loading the view.
    }
    
    func setUpSearch() {
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
    }
    
    func updateMainCollectionView() {
        
        var predicateArray = [NSPredicate]()
    
        var tagPredicate : NSPredicate? = nil;
        if selectedTags.count > 0 {
            tagPredicate = NSPredicate(format: "SOME tags IN %@", selectedTags)
            predicateArray.append(tagPredicate!)
        }
        
        self.fetchedResultsController.fetchRequest.predicate = (predicateArray.count > 0) ? NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray) : nil
        
        do {
            try  self.fetchedResultsController.performFetch()
            mainCollectionView.reloadData()
        } catch  {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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

}

extension SearchDisplayViewController : SearchDelegate {
    func selectedTag(tag: Tag) {
        selectedTags.insert(tag)
        mainCollectionView.dataSource = self
        tagCollectionView.dataSource = self
        
        tagCollectionView.reloadData()
        
        updateMainCollectionView()
        
        searchController?.searchBar.text = ""
//        searchController?.dismiss(animated: true, completion: nil)
        
    }
}

extension SearchDisplayViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            let searchResults = searchController.searchResultsController as? SearchDisplayController
            searchResults?.searchText = searchText
        }
        
    }
}

extension SearchDisplayViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if collectionView.tag == 100 {
            return 1;
        }
        
        return (fetchedResultsController.sections?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 100 {
            return selectedTags.count;
        }
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 100 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionCell", for: indexPath) as? TagCollectionCell else {
                return UICollectionViewCell()
            }
            
            let obj = Array(selectedTags)[indexPath.item]
            cell.tagLabel.text = obj.name
            cell.tagTypeLabel.text = obj.type 
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
    
    
}

extension SearchDisplayViewController : NSFetchedResultsControllerDelegate {
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == .insert {
            
            if (mainCollectionView?.numberOfSections)! > 0 {
                
                if mainCollectionView?.numberOfItems( inSection: newIndexPath!.section ) == 0 {
                    self.shouldReloadCollectionView = true
                    
                } else {
                    blockOperations.append(
                        BlockOperation(block: { [weak self] in
                            if let this = self {
                                DispatchQueue.main.async {
                                    this.mainCollectionView.insertItems(at: [newIndexPath!])
                                }
                            }
                        })
                    )
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
                            
                            this.mainCollectionView.reloadItems(at: [indexPath!])
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
                            this.mainCollectionView.moveItem(at: indexPath!, to: newIndexPath!)
                        }
                    }
                })
            )
        }
        else if type == .delete {
            if mainCollectionView?.numberOfItems( inSection: indexPath!.section ) == 1 {
                self.shouldReloadCollectionView = true
            } else {
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let this = self {
                            DispatchQueue.main.async {
                                this.mainCollectionView!.deleteItems(at: [indexPath!])
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
                            this.mainCollectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
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
                            this.mainCollectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
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
                            this.mainCollectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
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
                self.mainCollectionView.reloadData();
            }
        } else {
            DispatchQueue.main.async {
                self.mainCollectionView!.performBatchUpdates({ () -> Void in
                    for operation: BlockOperation in self.blockOperations {
                        operation.start()
                    }
                }, completion: { (finished) -> Void in
                    self.blockOperations.removeAll(keepingCapacity: false)
                })
            }
        }
    }
    
    
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return "Fetch"
    }
}

extension SearchDisplayViewController : UISearchBarDelegate{
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//            searchBar.text = ""
    }
}
