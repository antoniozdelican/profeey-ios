//
//  AWSSchool.swift
//  Profeey
//
//  Created by Antonio Zdelican on 04/03/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSSchool: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _schoolId: String?
    var _schoolName: String?
    var _numberOfUsers: NSNumber?
    var _created: NSNumber?
    
    class func dynamoDBTableName() -> String {
        #if DEVELOPMENT
            return "profeey-mobilehub-294297648-Schools"
        #else
            return "prodprofeey-mobilehub-725952970-Schools"
        #endif
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_schoolId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_schoolId" : "schoolId",
            "_schoolName" : "schoolName",
            "_numberOfUsers" : "numberOfUsers",
            "_created" : "created",
        ]
    }
    
    class func ignoreAttributes() -> [String] {
        return ["created"]
    }
}
