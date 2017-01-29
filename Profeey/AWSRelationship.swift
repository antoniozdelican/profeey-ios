//
//  AWSRelationship.swift
//  Profeey
//
//  Created by Antonio Zdelican on 06/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSRelationship: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _followingId: String?
    var _created: NSNumber?
    
    // Follower data.
    var _firstName: String?
    var _lastName: String?
    var _preferredUsername: String?
    var _professionName: String?
    var _profilePicUrl: String?
    
    // Followging data.
    var _followingFirstName: String?
    var _followingLastName: String?
    var _followingPreferredUsername: String?
    var _followingProfessionName: String?
    var _followingProfilePicUrl: String?
    
    convenience init(_userId: String?, _followingId: String?, _created: NSNumber?, _firstName: String?, _lastName: String?, _preferredUsername: String?, _professionName: String?, _profilePicUrl: String?, _followingFirstName: String?, _followingLastName: String?, _followingPreferredUsername: String?, _followingProfessionName: String?, _followingProfilePicUrl: String?) {
        self.init()
        self._userId = _userId
        self._followingId = _followingId
        self._created = _created
        self._firstName = _firstName
        self._lastName = _lastName
        self._preferredUsername = _preferredUsername
        self._professionName = _professionName
        self._profilePicUrl = _profilePicUrl
        self._followingFirstName = _followingFirstName
        self._followingLastName = _followingLastName
        self._followingPreferredUsername = _followingPreferredUsername
        self._followingProfessionName = _followingProfessionName
        self._followingProfilePicUrl = _followingProfilePicUrl
    }
    
    // To remove Like.
    convenience init(_userId: String?, _followingId: String?) {
        self.init()
        self._userId = _userId
        self._followingId = _followingId
    }
    
    class func dynamoDBTableName() -> String {
        #if DEVELOPMENT
            return "profeey-mobilehub-294297648-Relationships"
        #else
            return "prodprofeey-mobilehub-725952970-Relationships"
        #endif
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_followingId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_created" : "created",
            "_followingId" : "followingId",
            "_firstName" : "firstName",
            "_lastName" : "lastName",
            "_preferredUsername" : "preferredUsername",
            "_professionName" : "professionName",
            "_profilePicUrl" : "profilePicUrl",
            "_followingFirstName" : "followingFirstName",
            "_followingLastName" : "followingLastName",
            "_followingPreferredUsername" : "followingPreferredUsername",
            "_followingProfessionName" : "followingProfessionName",
            "_followingProfilePicUrl" : "followingProfilePicUrl",
        ]
    }
}
