//
//  AWSCategory.swift
//  Profeey
//
//  Created by Antonio Zdelican on 06/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSCategory: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _categoryName: String?
    var _numberOfPosts: NSNumber?
    var _searchCategoryName: String?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Categories"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_categoryName"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_categoryName" : "categoryName",
            "_numberOfPosts" : "numberOfPosts",
            "_searchCategoryName" : "searchCategoryName",
        ]
    }
}
