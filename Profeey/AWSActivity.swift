//
//  AWSActivity.swift
//  Profeey
//
//  Created by Antonio Zdelican on 13/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSActivity: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _postId: String?
    var _postUserId: String?
    var _categoryName: String?
    var _creationDate: NSNumber?
    var _description: String?
    var _imageUrl: String?
    var _numberOfLikes: NSNumber?
    var _title: String?
    
    var _firstName: String?
    var _lastName: String?
    var _preferredUsername: String?
    var _professionName: String?
    var _profilePicUrl: String?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Activities"
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
            "_postUserId" : "postUserId",
            "_categoryName" : "categoryName",
            "_creationDate" : "creationDate",
            "_description" : "description",
            "_imageUrl" : "imageUrl",
            "_numberOfLikes" : "numberOfLikes",
            "_title" : "title",
            "_firstName" : "firstName",
            "_lastName" : "lastName",
            "_preferredUsername" : "preferredUsername",
            "_professionName" : "professionName",
            "_profilePicUrl" : "profilePicUrl",
        ]
    }
}