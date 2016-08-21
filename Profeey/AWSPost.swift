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
    var _description: String?
    var _imageUrl: String?
    var _title: String?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Posts"
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
            "_description" : "description",
            "_imageUrl" : "imageUrl",
            "_title" : "title",
        ]
    }
}