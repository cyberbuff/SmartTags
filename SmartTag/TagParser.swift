//
//  DataParser.swift
//  SmartTag
//
//  Created by Nagarajan S on 26/07/18.
//  Copyright © 2018 Naga. All rights reserved.
//

import UIKit

enum Groups : String {
    //NLP
    case place //location
    case person
    case organization
    
    //Data detectors
    case links
    case phoneNumber
    case address
    case date
    case flightDetails
    
    //Image classification
    case autoMobiles = "Automobile"
    case food = "Food"
    case animal = "Animal"
    
    //Text classification
    //place,automobiles,hotel    
    case business = "Business"
    case entertainment = "Entertainment"
    case politics = "Politics"
    case sports = "Sports"
    case technology = "Technology"
    
    //Common
    case others
    
}

struct ML_Tag {
    var name : String?
    var group : Groups = .others
}


class TagParser: NSObject {
  
    let dataDetector = DataDetector()
    let nlpDetector = NLPDetector()
    let docClassifier = DocumentClassifier()
    let imageClassifier = ImageClassifier()
    let textClassifier = TextClassifier()

    
    func detectTagsFromDocument(_ attrStr : NSAttributedString,completion: (([ML_Tag]) -> Void))  {
        
        
       // Images classification
        let parts = attrStr.getParts()
        var imageObjectTypeTags : [ML_Tag] = []
        for part in parts{
            if let image = part as? UIImage{
               let objectName =  imageClassifier.classifyImage(image)
                if let arr : [String] = (objectName as NSString?)?.components(separatedBy: ","){
                    
                    let categories =    textClassifier.findCategories(str: arr)
                    for category in categories{
                        let tag = ML_Tag(name: category , group: Groups(rawValue: category)!)
                        imageObjectTypeTags.append(tag)
                    }
                    
                }
            }
        }
        completion(imageObjectTypeTags)
        
        

        
        
        
        let text = attrStr.string

        //Type classification
        if let output =  docClassifier.classify(text){
            var typeTags : [ML_Tag] = []
            if(output.prediction.probability >= 0.4){
                let tag = ML_Tag(name:output.prediction.category.rawValue , group: output.prediction.category)
                
                typeTags.append(tag)
//                print(output.prediction.category , output.prediction.probability);
            }
                
            completion(typeTags)
        }
  
        //Data detector
        dataDetector.detectDataTagsFromDocument(text) { (dataDetectorTags) in
            completion(dataDetectorTags)
//            print(dataDetectorTags)
        }
        
        //NLP
        nlpDetector.detectNLPTagsFromDocument(text) { (nlpTags) in
            completion(nlpTags)
            //print(nlpTags)
        }
        
        
        
        /* //Data detector
         dataDetector.detectDataTagsFromDocument(str) { (tags) in
         result.append(contentsOf: tags)
         //            print(tags)
         
         //NLP
         nlpDetector.detectNLPTagsFromDocument(str) { (tags) in
         result.append(contentsOf: tags)
         
         completion(result)
         //                print(result)
         }
         }*/
        
        
    }
}
