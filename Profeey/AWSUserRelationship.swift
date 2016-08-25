//
//  AWSUserRelationship.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSUserRelationship: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _followedId: String?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-UserRelationships"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_followedId"
    }
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject] {
        return [
            "_userId" : "userId",
            "_followedId" : "followedId",
        ]
    }
}