//
//  AWSUserExperience.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSUserExperience: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _experienceId: String?
    var _position: String?
    var _organization: String?
    var _fromDate: NSNumber?
    var _toDate: NSNumber?
    var _experienceType: NSNumber?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-UserExperiences"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_experienceId"
    }
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject] {
        return [
            "_userId" : "userId",
            "_experienceId" : "experienceId",
            "_position" : "position",
            "_organization" : "organization",
            "_fromDate" : "fromDate",
            "_toDate" : "toDate",
            "_experienceType" : "experienceType",
        ]
    }
}