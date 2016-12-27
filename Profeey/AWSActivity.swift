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
    var _creationDate: NSNumber?
    
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
    
    // Generated.
    // TODO: refactor
    
    // activityId is stored in form of {postUserId}+activity+{postId}
//    var _postUserId: String? {
//        guard let _activityId = self._activityId else {
//            return nil
//        }
//        return _activityId.components(separatedBy: "+activity+").first
//    }
//    var _postId: String? {
//        guard let _activityId = self._activityId else {
//            return nil
//        }
//        return _activityId.components(separatedBy: "+activity+").last
//    }
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Activities"
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
            "_creationDate" : "creationDate",
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
