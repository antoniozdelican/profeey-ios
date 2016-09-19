//
//  AWSUserCategory.swift
//  Profeey
//
//  Created by Antonio Zdelican on 16/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSUserCategory: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _categoryName: String?
    var _numberOfPosts: NSNumber?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-UserCategories"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_categoryName"
    }
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject] {
        return [
            "_userId" : "userId",
            "_categoryName" : "categoryName",
            "_numberOfPosts" : "numberOfPosts",
        ]
    }
}