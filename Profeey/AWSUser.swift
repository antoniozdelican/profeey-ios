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
    var _fullName: String?
    var _preferredUsername: String?
    var _profilePicUrl: String?
    var _professions: [String]?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-1226628658-Users"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject] {
        return [
            "_userId" : "userId",
            "_about" : "about",
            "_fullName" : "fullName",
            "_preferredUsername" : "preferredUsername",
            "_profilePicUrl" : "profilePicUrl",
            "_professions" : "professions",
        ]
    }
}
