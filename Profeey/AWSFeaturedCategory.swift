//
//  AWSFeaturedCategory.swift
//  Profeey
//
//  Created by Antonio Zdelican on 05/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSFeaturedCategory: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _categoryName: String?
    var _creationDate: NSNumber?
    var _featuredImageUrl: String?
    var _numberOfPosts: NSNumber?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-FeaturedCategories"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_categoryName"
    }
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject] {
        return [
            "_categoryName" : "categoryName",
            "_creationDate" : "creationDate",
            "_featuredImageUrl" : "featuredImageUrl",
            "_numberOfPosts" : "numberOfPosts",
        ]
    }
}