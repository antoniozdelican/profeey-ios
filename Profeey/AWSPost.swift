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
    var _created: NSNumber?
    var _caption: String?
    var _categoryName: String?
    var _imageUrl: String?
    // Used to get fast aspect ratio.
    var _imageWidth: NSNumber?
    var _imageHeight: NSNumber?
    
    var _numberOfLikes: NSNumber?
    var _numberOfComments: NSNumber?
    
    var _firstName: String?
    var _lastName: String?
    var _preferredUsername: String?
    var _professionName: String?
    var _profilePicUrl: String?
    
    convenience init(_userId: String?, _postId: String?, _created: NSNumber?, _caption: String?, _categoryName: String?, _imageUrl: String?, _imageWidth: NSNumber?, _imageHeight: NSNumber?, _firstName: String?, _lastName: String?, _preferredUsername: String?, _professionName: String?, _profilePicUrl: String?) {
        self.init()
        self._userId = _userId
        self._postId = _postId
        self._created = _created
        self._caption = _caption
        self._categoryName = _categoryName
        self._imageUrl = _imageUrl
        self._imageWidth = _imageWidth
        self._imageHeight = _imageHeight
        
        self._firstName = _firstName
        self._lastName = _lastName
        self._preferredUsername = _preferredUsername
        self._professionName = _professionName
        self._profilePicUrl = _profilePicUrl
    }
    
    // To update Post.
    convenience init(_userId: String?, _postId: String?, _caption: String?, _categoryName: String?) {
        self.init()
        self._userId = _userId
        self._postId = _postId
        self._caption = _caption
        self._categoryName = _categoryName
    }
    
    // To remove Post.
    convenience init(_userId: String?, _postId: String?) {
        self.init()
        self._userId = _userId
        self._postId = _postId
    }
    
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
