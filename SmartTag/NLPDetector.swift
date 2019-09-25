//
//  NLPDetector.swift
//  SmartTag
//
//  Created by Nagarajan S on 26/07/18.
//  Copyright © 2018 Naga. All rights reserved.
//

import UIKit

class NLPDetector: NSObject {
    let textClassifer  = TextClassifier()
    let nameTagger = NSLinguisticTagger(tagSchemes: [.tokenType, .language, .lexicalClass, .nameType, .lemma], options: 0)
    let nownTagger = NSLinguisticTagger(tagSchemes: [.lexicalClass], options: 0)
    let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
    
    

    func detectNLPTagsFromDocument(_ text : String,completion: (([ML_Tag]) -> Void))  {

        var resultTags : [ML_Tag] = []
        var nownArray : [String] = []
        var placeArray : [String] = []

        nameTagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        let lingusticTags: [NSLinguisticTag] = [.personalName, .placeName, .organizationName]
        nameTagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { lingusticTag, tokenRange, stop in
            if let lingusticTag = lingusticTag, lingusticTags.contains(lingusticTag) {
                let name = (text as NSString).substring(with: tokenRange)
                print("\(name): \(lingusticTag.rawValue)")
        
                
                if(lingusticTag == .personalName){
                    let aTag = ML_Tag(name: name, group: .person)
                    resultTags.append(aTag)
                }else if(lingusticTag == .placeName){
                    placeArray.append(name)
                    
                    let aTag = ML_Tag(name: name, group: .place)
                    resultTags.append(aTag)
                }else if(lingusticTag == .organizationName){
                    let aTag = ML_Tag(name: name, group: .organization)
                    resultTags.append(aTag)
                }
                
            }
            
//            nownTagger.string = text
//
//            
//            nownTagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange, _ in
//                if let tag = tag {
//                    let word = (text as NSString).substring(with: tokenRange)
//                    if (tag.rawValue == NSLinguisticTag.noun.rawValue){
//                        nownArray.append(word)
//                    }
//                }
//            }
        }
        let objCategories = textClassifer.findCategories(str: nownArray)
        for category in objCategories{
            let tag = ML_Tag(name: category , group: Groups(rawValue: category)!)
            resultTags.append(tag)
        }
        
        let placeCategories =  textClassifer.findPlaces(str: placeArray)
        for category in placeCategories{
            let tag = ML_Tag(name: category , group: .place)
            resultTags.append(tag)
        }

        
        completion(resultTags)
    }
}
