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
    var _caption: String?
    var _categoryName: String?
    var _creationDate: NSNumber?
    var _imageUrl: String?
    var _numberOfLikes: NSNumber?
    var _numberOfComments: NSNumber?
    
    var _firstName: String?
    var _lastName: String?
    var _preferredUsername: String?
    var _professionName: String?
    var _profilePicUrl: String?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Posts"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_postId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_postId" : "postId",
            "_caption" : "caption",
            "_categoryName" : "categoryName",
            "_creationDate" : "creationDate",
            "_imageUrl" : "imageUrl",
            "_numberOfLikes" : "numberOfLikes",
            "_numberOfComments" : "numberOfComments",
            "_firstName" : "firstName",
            "_lastName" : "lastName",
            "_preferredUsername" : "preferredUsername",
            "_professionName" : "professionName",
            "_profilePicUrl" : "profilePicUrl",
        ]
    }
}
