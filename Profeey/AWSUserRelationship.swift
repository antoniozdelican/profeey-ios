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
    var _creationDate: NSNumber?
    var _followingId: String?
    var _followingFirstName: String?
    var _followingLastName: String?
    var _followingPreferredUsername: String?
    var _followingProfession: String?
    var _followingProfilePicUrl: String?
    var _numberOfNewPosts: NSNumber?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-UserRelationships"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_followingId"
    }
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject] {
        return [
            "_userId" : "userId",
            "_creationDate" : "creationDate",
            "_followingId" : "followingId",
            "_followingFirstName" : "followingFirstName",
            "_followingLastName" : "followingLastName",
            "_followingPreferredUsername" : "followingPreferredUsername",
            "_followingProfession" : "followingProfession",
            "_followingProfilePicUrl" : "followingProfilePicUrl",
            "_numberOfNewPosts" : "numberOfNewPosts",
        ]
    }
}