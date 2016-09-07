//
//  AWSPost.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSPost: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _postId: String?
    var _categoryName: String?
    var _creationDate: NSNumber?
    var _description: String?
    var _imageUrl: String?
    var _numberOfLikes: NSNumber?
    var _title: String?
    
    var _userFirstName: String?
    var _userLastName: String?
    var _userPreferredUsername: String?
    var _userProfession: String?
    var _userProfilePicUrl: String?
    
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
            "_categoryName" : "categoryName",
            "_creationDate" : "creationDate",
            "_description" : "description",
            "_imageUrl" : "imageUrl",
            "_numberOfLikes" : "numberOfLikes",
            "_title" : "title",
            "_userFirstName" : "userFirstName",
            "_userLastName" : "userLastName",
            "_userPreferredUsername" : "userPreferredUsername",
            "_userProfession" : "userProfession",
            "_userProfilePicUrl" : "userProfilePicUrl",
        ]
    }
}