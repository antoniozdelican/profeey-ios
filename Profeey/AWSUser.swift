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
    var _about: String?
    var _email: String?
    var _creationDate: NSNumber?
    var _firstName: String?
    var _lastName: String?
    var _locationName: String?
    var _numberOfFollowers: NSNumber?
    var _numberOfPosts: NSNumber?
    var _preferredUsername: String?
    var _professionName: String?
    var _profilePicUrl: String?
    var _searchFirstName: String?
    var _searchLastName: String?
    var _searchPreferredUsername: String?
    var _searchProfessionName: String?
    var _topCategories: [String: String]?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Users"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_about" : "about",
            "_email" : "email",
            "_creationDate" : "creationDate",
            "_firstName" : "firstName",
            "_lastName" : "lastName",
            "_locationName" : "locationName",
            "_numberOfFollowers" : "numberOfFollowers",
            "_numberOfPosts" : "numberOfPosts",
            "_preferredUsername" : "preferredUsername",
            "_professionName" : "professionName",
            "_profilePicUrl" : "profilePicUrl",
            "_searchFirstName" : "searchFirstName",
            "_searchLastName" : "searchLastName",
            "_searchPreferredUsername" : "searchPreferredUsername",
            "_searchProfessionName" : "searchProfessionName",
            "_topCategories" : "topCategories",
        ]
    }
    
    // Watch for creationDate update so you don't delete it!
}
