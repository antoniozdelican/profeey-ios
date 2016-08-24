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
    var _firstName: String?
    var _lastName: String?
    var _location: String?
    var _preferredUsername: String?
    var _profession: String?
    var _profilePicUrl: String?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Users"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject] {
        return [
            "_userId" : "userId",
            "_about" : "about",
            "_firstName" : "firstName",
            "_lastName" : "lastName",
            "_location" : "location",
            "_preferredUsername" : "preferredUsername",
            "_profession" : "profession",
            "_profilePicUrl" : "profilePicUrl",
        ]
    }
}
