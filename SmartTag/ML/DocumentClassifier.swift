//
//  DocumentClassifier.swift
//  
//
//  Created by sudhan-6859 on 26/07/18.
//

import Foundation
import UIKit

public struct Classification {
    
    public struct Result {
        let category: Groups
        let probability: Double
    }
    
    public let prediction: Result
    public let allResults: [Result]
    
}

extension Classification {
    
    init?(output: DocumentClassificationOutput) {
        guard let category = Groups(rawValue: output.classLabel),
            let probability = output.classProbability[output.classLabel]
            else { return nil }
        let prediction = Result(category: category, probability: probability)
        let allResults = output.classProbability.flatMap(Classification.result)
        self.init(prediction: prediction, allResults: allResults)
    }
    
    static func result(from classProbability: (key: String, value: Double)) -> Result? {
        guard let category = Groups(rawValue: classProbability.key) else { return nil }
        return Result(category: category, probability: classProbability.value)
    }
}

public final class DocumentClassifier {
    
    public init() {}
    
    private let model = DocumentClassification()
    private let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
    private lazy var tagger: NSLinguisticTagger = {
        let tagSchemes = NSLinguisticTagger.availableTagSchemes(forLanguage: "en")
        return NSLinguisticTagger(tagSchemes: tagSchemes, options: Int(self.options.rawValue))
    }()
    
    public func classify(_ text: String) -> Classification? {
        let features = extractFeatures(from: text)
        guard
            features.count > 2,
            let output = try? model.prediction(input: features) else { return nil }
        return Classification(output: output)
    }
    
    func extractFeatures(from text: String) -> [String: Double] {
        var wordCounts = [String: Double]()
        tagger.string = text
        let range = NSRange(location: 0, length: text.count)
        tagger.enumerateTags(in: range, scheme: .tokenType, options: options) { _, tokenRange, _, _ in
            let token = (text as NSString).substring(with: tokenRange).lowercased()
            guard token.count >= 3 else { return }
            guard let value = wordCounts[token] else {
                wordCounts[token] = 1.0
                return
            }
            wordCounts[token] = value + 1.0
        }
        return wordCounts
    }
    
}
