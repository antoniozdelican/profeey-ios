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
    var _creationDate: NSNumber?
    var _firstName: String?
    var _lastName: String?
    var _preferredUsername: String?
    var _professionName: String?
    var _profilePicUrl: String?
    
    var _about: String?
    var _email: String?
    var _locationName: String?
    
    var _numberOfFollowers: NSNumber?
    var _numberOfPosts: NSNumber?
    var _numberOfRecommendations: NSNumber?
    
    var _searchProfessionName: String?
    
    // To create User on landing.
    convenience init(_userId: String?, _creationDate: NSNumber?, _firstName: String?, _lastName: String?, _email: String?) {
        self.init()
        self._userId = _userId
        self._creationDate = _creationDate
        self._firstName = _firstName
        self._lastName = _lastName
        self._email = _email
    }
    
    // To update preferredUsername and profilePicUrl on landing.
    convenience init(_userId: String?, _preferredUsername: String?, _profilePicUrl: String?) {
        self.init()
        self._userId = _userId
        self._preferredUsername = _preferredUsername
        self._profilePicUrl = _profilePicUrl
    }
    
    // To update professionName and searcProfessionName on landing.
    convenience init(_userId: String?, _professionName: String?, _searchProfessionName: String?) {
        self.init()
        self._userId = _userId
        self._professionName = _professionName
        self._searchProfessionName = _searchProfessionName
    }
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Users"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_creationDate" : "creationDate",
            "_firstName" : "firstName",
            "_lastName" : "lastName",
            "_preferredUsername" : "preferredUsername",
            "_professionName" : "professionName",
            "_profilePicUrl" : "profilePicUrl",
            "_about" : "about",
            "_email" : "email",
            "_locationName" : "locationName",
            "_numberOfFollowers" : "numberOfFollowers",
            "_numberOfPosts" : "numberOfPosts",
            "_numberOfRecommendations" : "numberOfRecommendations",
            "_searchProfessionName" : "searchProfessionName",
        ]
    }
    
    // Watch for creationDate update so you don't delete it!
}
