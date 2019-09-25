//
//  NewDocumentController.swift
//  SmartTag
//
//  Created by yokesh-7095 on 26/07/18.
//  Copyright © 2018 Naga. All rights reserved.
//

import UIKit

class NewDocumentController: UIViewController {
    
    var attachmentArray : [UIImage] = []

    @IBOutlet weak var imgCollectionView: UICollectionView!
    @IBOutlet weak var documentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Document"
        if attachmentArray.count == 0 {
            imgCollectionView.isHidden = true
        }
        
        let  save_button = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(NewDocumentController.saveClicked))
        self.navigationItem.rightBarButtonItem = save_button
        // Do any additional setup after loading the view.
    }
    
    @objc func saveClicked() {
        let attributedString = NSMutableAttributedString(string: documentTextView.text)
        
        let textAttachment = NSTextAttachment()

        if attachmentArray.count > 0 {
            textAttachment.image = attachmentArray[0]
        }

        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        attributedString.append(attrStringWithImage)
        
        let filename = "Document_\(arc4random())"
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(filename)
            
            //writing
            do {
                try attributedString.toData?.write(to: fileURL)
            }
            catch {/* error handling here */}
            
        }
        
        CoreDataManager.sharedInstance.parseAndAddDocument(attributedString)
        
        self.navigationController?.popViewController(animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func NewAttachment(_ sender: Any) {
        
        
        let alertController: UIAlertController = UIAlertController(title: "Please select", message: nil, preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        alertController.addAction(cancelActionButton)
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default)
        { _ in
            DispatchQueue.main.async {
                self.addAttachmentFrom(camera: true)
            }
        }
        alertController.addAction(cameraAction)
        
        let galleryAction = UIAlertAction(title: "Show Gallery", style: .default)
        { _ in
            DispatchQueue.main.async {
                self.addAttachmentFrom(camera: false)
            }
        }
        alertController.addAction(galleryAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addAttachmentFrom(camera : Bool) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = camera ? .camera : .photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
}

extension NewDocumentController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let image       =   info[UIImagePickerControllerOriginalImage] as? UIImage
        attachmentArray.append(image!)
        imgCollectionView.isHidden = false
        imgCollectionView.reloadData()
        
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension NewDocumentController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachmentArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewDocumentImageCell", for: indexPath) as? NewDocumentImageCell
        cell?.cellImageView.image = attachmentArray[indexPath.row]
        return cell!
    }
    
}


