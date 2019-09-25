//
//  DataDetector.swift
//  SmartTag
//
//  Created by Nagarajan S on 26/07/18.
//  Copyright © 2018 Naga. All rights reserved.
//

import UIKit


struct ML_Date {
    var date: Date?
    var timeZone: TimeZone?
    var duration: Double?
    let dateFormatter = DateFormatter()
    
    
    func tagObject() -> ML_Tag? {
        guard let _date = date else {
            return nil
        }
        return ML_Tag(name:DateFormatter.localizedString(from: _date, dateStyle: .short, timeStyle: .short) , group: .date)
    }
}

struct ML_Address {
    var name: String?
    var jobTitle: String?
    var organisation: String?
    var street: String?
    var city: String?
    var state: String?
    var zip: String?
    var country: String?
    var phone: String?
    var desc : String?
    
    func tagObject() -> ML_Tag? {
        
        return ML_Tag(name: desc, group: .address)
    }
}

struct ML_Link {
    var url: URL?
    
    func tagObject() -> ML_Tag? {
        return ML_Tag(name: url?.absoluteString, group: .links)
    }
}

struct ML_Phone{
    var phoneNumber: String?
    
    func tagObject() -> ML_Tag? {
        return ML_Tag(name: phoneNumber, group: .phoneNumber)
    }
}

struct ML_Transit{
    var flight: String?
    var airline: String?
    
    func tagObject() -> ML_Tag? {
        return ML_Tag(name: flight, group: .flightDetails)
    }
}


class DataDetector: NSObject {
    var phoneBook = [ML_Phone]()
    var addressBook = [ML_Address]()
    var links   =   [ML_Link]()
    var dates   =   [ML_Date]()
    var transits =   [ML_Transit]()

    
    func detectDataTagsFromDocument(_ text : String,completion: (([ML_Tag]) -> Void))  {
        
        let types: NSTextCheckingResult.CheckingType = [NSTextCheckingResult.CheckingType.allTypes] //.phoneNumber,.link,.address,.date
        
        do{
            var resultTags : [ML_Tag] = []
            
            let detector = try NSDataDetector(types: types.rawValue)
            
            let matches = detector.matches(in: text, options: [], range: NSMakeRange(0, text.count))
            
            for match in matches {
                
                if let phone = match.phoneNumber
                {
                    let ph = ML_Phone(phoneNumber: phone)
                    phoneBook.append(ph)
                    
                    if let tag = ph.tagObject(){
                        resultTags.append(tag)
                    }
                }
                if let address = match.addressComponents
                {
                    if(address[.name] != nil || address[.jobTitle] != nil || address[.organization] != nil || address[.street] != nil || address[.city] != nil || address[.state] != nil || address[.zip] != nil || address[.country] != nil || address[.phone] != nil) {
                        
                        var addressName = (text as NSString).substring(with: match.range).replacingOccurrences(of: ",\n", with: ", ")
                        addressName = addressName.replacingOccurrences(of: "\n", with: " ")

                        let add = ML_Address(name: address[.name], jobTitle: address[.jobTitle], organisation: address[.organization], street: address[.street], city: address[.city], state: address[.state], zip: address[.zip], country: address[.country], phone: address[.phone], desc: addressName)
                    
                        
                        addressBook.append(add)
                        
                        if let tag = add.tagObject(){
                            resultTags.append(tag)
                        }
                    }
                    
                }
                if (match.date != nil || match.timeZone != nil)
                {
                    let d = ML_Date(date: match.date, timeZone: match.timeZone, duration: match.duration)
                    dates.append(d)
                    
                    if let tag = d.tagObject(){
                        resultTags.append(tag)
                    }
                }
                if let url = match.url
                {
                    let link = ML_Link(url: url)
                    links.append(link)
                    
                    if let tag = link.tagObject(){
                        resultTags.append(tag)
                    }
                }
                if let components = match.components
                {
                    if(components[.flight] != nil || components[.airline] != nil)
                    {
                        let trans = ML_Transit(flight: components[.flight], airline: components[.airline])
                        transits.append(trans)
                        
                        if let tag = trans.tagObject(){
                            resultTags.append(tag)
                        }
                    }
                }
            }
            
            completion(resultTags)
        }
        catch {
           completion([])
        }
        
       // printInfo(.address)
        //printInfo(.flightDetails)
    }
    
    
    /*func printInfo(_ group: Groups)
    {
        var answers = [String]()
        
        switch group {
        case .address:
            for address in addressBook
            {
                
                //                answers.append("Address:")
                
                if let name = address.name
                {
                    answers.append("Name: \(name)")
                }
                if let jobTitle = address.jobTitle
                {
                    answers.append("Job: \(jobTitle)")
                }
                if let organisation = address.organisation
                {
                    answers.append("Org: \(organisation)")
                }
                if let street = address.street
                {
                    answers.append("Street: \(street)")
                }
                if let city = address.city
                {
                    answers.append("City: \(city)")
                }
                if let state = address.state
                {
                    answers.append("State: \(state)")
                }
                if let zip = address.zip
                {
                    answers.append("Zip: \(zip)")
                }
                if let phone = address.phone
                {
                    answers.append("Phone: \(phone)")
                }
                answers.append("")
            }
            break
        case .links:
            for link in links
            {
                //                    answers.append("Link:")
                if let url = link.url
                {
                    answers.append("URL: \(url)")
                }
                answers.append("")
            }
            
        case .flightDetails:
            for transit in transits
            {
                //                answers.append("Flight:")
                if let flight = transit.flight
                {
                    answers.append("Number: \(flight)")
                }
                if let airline = transit.airline
                {
                    answers.append("Airline: \(airline)")
                }
                answers.append("")
            }
        case .phoneNumber:
            for phone in phoneBook
            {
                //                answers.append("Phone:")
                if let number = phone.phoneNumber
                {
                    answers.append("Number: \(number)")
                }
                answers.append("")
            }
        case .date:
            for date in dates
            {
                //                answers.append("Date:")
                if let date = date.date
                {
                    answers.append("Date: \(date)")
                }
                if let timeZone = date.timeZone
                {
                    answers.append("Time Zone: \(timeZone)")
                }
                if let duration = date.duration
                {
                    answers.append("Duration: \(duration)")
                }
                
            }
        default:
            break
        }
        
        print(answers.joined(separator: "\n"))
    }*/
}
