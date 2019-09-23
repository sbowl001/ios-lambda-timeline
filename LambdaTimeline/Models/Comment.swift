//
//  Comment.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

class Comment: FirebaseConvertible, Equatable {
    
    static private let textKey = "text"
    static private let audioURLKey = "audioURL"
    static private let author = "author"
    static private let timestampKey = "timestamp"
    
    let text: String?
    let audioURL: URL?
    let author: Author
    let timestamp: Date
    
    init(text: String?, audioURL: URL? = nil, author: Author, timestamp: Date = Date()) {
        self.text = text
        self.audioURL = audioURL
        self.author = author
        self.timestamp = timestamp
        
    }
    
    init?(dictionary: [String : Any]) {
        guard let text = dictionary[Comment.textKey] as? String?,
            let audioURL = dictionary[Comment.audioURLKey] as? URL?,
            let authorDictionary = dictionary[Comment.author] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval else { return nil }
        
        self.text = text
        self.audioURL = audioURL
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
    }
    
    var dictionaryRepresentation: [String: Any] {
 
        var dictionary: [String: Any] = [
            Comment.author: author.dictionaryRepresentation,
            Comment.timestampKey: timestamp.timeIntervalSince1970 ]
        
        if let text = text {
            dictionary[Comment.textKey] = text
        }
        
        if let audioURL = audioURL {
            dictionary[Comment.audioURLKey] = audioURL.absoluteString
        }
       
//        return [Comment.textKey: text ?? "",
//
//
//                Comment.audioURLKey: audioURL?.absoluteString,
//                    //What to do here? and what is absolute string?
//                Comment.author: author.dictionaryRepresentation,
//                Comment.timestampKey: timestamp.timeIntervalSince1970]
        
        return dictionary 
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.author == rhs.author &&
            lhs.timestamp == rhs.timestamp
    }
}
