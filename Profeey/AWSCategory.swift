//
//  AWSCategory.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSCategory: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _categoryName: String?
    var _numberOfPosts: NSNumber?
    var _created: NSNumber?
    
    class func dynamoDBTableName() -> String {
        #if DEVELOPMENT
            return "profeey-mobilehub-294297648-Categories"
        #else
            return "prodprofeey-mobilehub-725952970-Categories"
        #endif
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_categoryName"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_categoryName" : "categoryName",
            "_numberOfPosts" : "numberOfPosts",
            "_created" : "created",
        ]
    }
    
    class func ignoreAttributes() -> [String] {
        return ["created"]
    }
}
