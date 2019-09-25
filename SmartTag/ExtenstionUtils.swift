//
//  ExtenstionUtils.swift
//  SmartTag
//
//  Created by Nagarajan S on 26/07/18.
//  Copyright © 2018 Naga. All rights reserved.
//

import UIKit

extension NSAttributedString{
    var toData : Data? {

       return NSKeyedArchiver.archivedData(withRootObject: self)
       /*
        do {
            let documentAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [.documentType: NSAttributedString.DocumentType.html]
            return try data(from: NSRange(location: 0, length: self.length), documentAttributes: documentAttributes)
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil*/
    }
    
    func getParts() -> [AnyObject] {
        var parts = [AnyObject]()
        
        let range = NSMakeRange(0, self.length)
        self.enumerateAttributes(in: range, options: NSAttributedString.EnumerationOptions(rawValue: 0)) { (object, range, stop) in
            if object.keys.contains(NSAttributedStringKey.attachment) {
                if let attachment = object[NSAttributedStringKey.attachment] as? NSTextAttachment {
                    if let image = attachment.image {
                        parts.append(image)
                    } else if let image = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location) {
                        parts.append(image)
                    }
                }
            } else {
                let stringValue : String = self.attributedSubstring(from: range).string
                if (!stringValue.trimmingCharacters(in: .whitespaces).isEmpty) {
                    parts.append(stringValue as AnyObject)
                }
            }
        }
        return parts
    }
}

extension Data {
    var toAttributedString: NSAttributedString? {
        
        return NSKeyedUnarchiver.unarchiveObject(with: self) as? NSAttributedString
        /*
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil*/
    }
}


extension Document{
    var attributedContent : NSAttributedString? {
        return data?.toAttributedString
    }
}
