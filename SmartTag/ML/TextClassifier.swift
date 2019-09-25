//
//  TextClassifier.swift
//  SmartTag
//
//  Created by sudhan-6859 on 27/07/18.
//  Copyright © 2018 Naga. All rights reserved.
//

import Foundation


struct NL_Categories : Codable{
    let name : String
    let category : String
}

struct NL_Cities : Codable{
    let name : String
    let country : String
    let subcountry : String
}

class TextClassifier {
    
    var categories = [NL_Categories]()
    var cities     = [NL_Cities]()
    
    init(){
        if let json = Bundle.main.url(forResource: "Categories", withExtension: "json"){
            let data = try! Data(contentsOf: json, options: [])
            let models1 = try! JSONDecoder().decode([NL_Categories].self, from: data)
            categories = models1
        }
        
        if let json = Bundle.main.url(forResource: "WorldCities", withExtension: "json"),let data = try? Data(contentsOf: json, options: []),let models1 = try? JSONDecoder().decode([NL_Cities].self, from: data){
            cities = models1
        }
    }
    
    func findCategories(str: [String]) -> [String]{
        var modelsSet = [String]()
        for i in str{
            let models1 = categories.filter { (tag) -> Bool in
                return tag.name == i
            }
            for i in models1{
                modelsSet.append(i.category)
            }
        }
        return Array(Set(modelsSet))
    }
    
    func findPlaces(str: [String]) -> [String]{
        var modelsSet = [String]()
        for i in str{
            let models1 = cities.filter { (tag) -> Bool in
                return tag.name == i
            }
            for i in models1{
                modelsSet.append(i.country)
            }
        }
        return Array(Set(modelsSet))
    }
    
}
