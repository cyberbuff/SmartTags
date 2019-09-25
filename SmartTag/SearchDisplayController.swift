//
//  SearchDisplayController.swift
//  SmartTag
//
//  Created by yokesh-7095 on 27/07/18.
//  Copyright © 2018 Naga. All rights reserved.
//

import UIKit
import CoreData

protocol SearchDelegate {
    func selectedTag (tag : Tag)
}

class SearchDisplayController: UIViewController {

    @IBOutlet weak var searchTableView: UITableView!
    
    let coredatamanager = CoreDataManager.sharedInstance
    
    var delegate : SearchDelegate? = nil
    
    var tagArray : [Tag] {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
       // fetchRequest.fetchLimit = 15
        
        if searchText.count > 0 {
            fetchRequest.predicate = NSPredicate(format: "name contains[c] %@ || type contains[c] %@", searchText,searchText)
        }
        
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
    
    var searchText : String = "" {
        didSet {
            self.searchTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchDisplayController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        let obj = tagArray[indexPath.row]
        
        if let name = obj.name , let type = obj.type {
            cell.textLabel?.text = name
            
            cell.imageView?.image = UIImage(named: "\(type).png")

        }
        
        return cell
    }
}

extension SearchDisplayController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            if let delegate = delegate {
                delegate.selectedTag(tag: tagArray[indexPath.row])
                
            }
        
        self.dismiss(animated: true, completion: nil)
    }
}
