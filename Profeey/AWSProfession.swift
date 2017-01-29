//
//  AWSProfession.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSProfession: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _professionName: String?
    var _numberOfUsers: NSNumber?
    var _created: NSNumber?
    
    class func dynamoDBTableName() -> String {
        #if DEVELOPMENT
            return "profeey-mobilehub-294297648-Professions"
        #else
            return "prodprofeey-mobilehub-725952970-Professions"
        #endif
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_professionName"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_professionName" : "professionName",
            "_numberOfUsers" : "numberOfUsers",
            "_created" : "created",
        ]
    }
    
    class func ignoreAttributes() -> [String] {
        return ["created"]
    }
}
