//
//  AWSUser.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSUser: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _created: NSNumber?
    var _firstName: String?
    var _lastName: String?
    var _preferredUsername: String?
    var _professionName: String?
    var _profilePicUrl: String?
    
    var _about: String?
    var _email: String?
    var _emailVerified: NSNumber?
    var _schoolId: String?
    var _schoolName: String?
    var _website: String?
    
    var _numberOfFollowers: NSNumber?
    var _numberOfPosts: NSNumber?
    var _numberOfRecommendations: NSNumber?
    
    var _isFacebookUser: NSNumber?
    var _isDisabled: NSNumber?
    
    // To create User on landing.
    convenience init(_userId: String?, _created: NSNumber?, _firstName: String?, _lastName: String?, _email: String?, _emailVerified: NSNumber?, _isFacebookUser: NSNumber?) {
        self.init()
        self._userId = _userId
        self._created = _created
        self._firstName = _firstName
        self._lastName = _lastName
        self._email = _email
        self._emailVerified = _emailVerified
        self._isFacebookUser = _isFacebookUser
    }
    
    // To update preferredUsername and profilePicUrl on landing.
    convenience init(_userId: String?, _preferredUsername: String?, _profilePicUrl: String?) {
        self.init()
        self._userId = _userId
        self._preferredUsername = _preferredUsername
        self._profilePicUrl = _profilePicUrl
    }
    
    // To update professionName on landing.
    convenience init(_userId: String?, _professionName: String?) {
        self.init()
        self._userId = _userId
        self._professionName = _professionName
    }
    
    // To update email on editEmail.
    convenience init(_userId: String?, _email: String?, _emailVerified: NSNumber?) {
        self.init()
        self._userId = _userId
        self._email = _email
        self._emailVerified = _emailVerified
    }
    
    // To update user on EditVc. Use AWSUserUpdate!
    convenience init(_userId: String?, _firstName: String?, _lastName: String?, _professionName: String?, _profilePicUrl: String?, _about: String?, _schoolId: String?, _schoolName: String?, _website: String?) {
        self.init()
        self._userId = _userId
        self._firstName = _firstName
        self._lastName = _lastName
        self._professionName = _professionName
        self._profilePicUrl = _profilePicUrl
        self._about = _about
        self._schoolId = _schoolId
        self._schoolName = _schoolName
        self._website = _website
    }
    
    class func dynamoDBTableName() -> String {
        #if DEVELOPMENT
            return "profeey-mobilehub-294297648-Users"
        #else
            return "prodprofeey-mobilehub-725952970-Users"
        #endif
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_created" : "created",
            "_firstName" : "firstName",
            "_lastName" : "lastName",
            "_preferredUsername" : "preferredUsername",
            "_professionName" : "professionName",
            "_profilePicUrl" : "profilePicUrl",
            "_about" : "about",
            "_email" : "email",
            "_emailVerified" : "emailVerified",
            "_schoolId" : "schoolId",
            "_schoolName" : "schoolName",
            "_website" : "website",
            "_numberOfFollowers" : "numberOfFollowers",
            "_numberOfPosts" : "numberOfPosts",
            "_numberOfRecommendations" : "numberOfRecommendations",
            "_isFacebookUser" : "isFacebookUser",
            "_isDisabled" : "isDisabled",
        ]
    }
}
