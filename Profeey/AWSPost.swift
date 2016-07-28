//
//  AWSPost.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

class AWSPost: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _postId: String?
    var _caption: String?
    var _categories: [String]?
    var _creationDate: NSNumber?
    var _mediaUrl: String?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-1226628658-Posts"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_postId"
    }
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject] {
        return [
            "_userId" : "userId",
            "_postId" : "postId",
            "_caption" : "caption",
            "_categories" : "categories",
            "_creationDate" : "creationDate",
            "_mediaUrl" : "mediaUrl",
        ]
    }
}