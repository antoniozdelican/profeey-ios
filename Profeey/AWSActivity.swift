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
    var _activityId: String?
    var _postUserId: String?
    var _postId: String?
    
    var _caption: String?
    var _categoryName: String?
    var _created: NSNumber?
    
    var _imageWidth: NSNumber?
    var _imageHeight: NSNumber?
    var _imageUrl: String?
    var _numberOfLikes: NSNumber?
    var _numberOfComments: NSNumber?
    
    var _firstName: String?
    var _lastName: String?
    var _preferredUsername: String?
    var _professionName: String?
    var _profilePicUrl: String?
    
    class func dynamoDBTableName() -> String {
        
        #if DEVELOPMENT
            return "profeey-mobilehub-294297648-Activities"
        #else
            return "prodprofeey-mobilehub-725952970-Activities"
        #endif
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_activityId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_activityId" : "activityId",
            "_postUserId" : "postUserId",
            "_postId" : "postId",
            "_caption" : "caption",
            "_categoryName" : "categoryName",
            "_created" : "created",
            "_imageUrl" : "imageUrl",
            "_imageWidth" : "imageWidth",
            "_imageHeight" : "imageHeight",
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
