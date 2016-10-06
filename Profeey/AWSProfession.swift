//
//  AWSProfession.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSProfession: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _professionName: String?
    var _numberOfUsers: NSNumber?
    var _searchProfessionName: String?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Professions"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_professionName"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_professionName" : "professionName",
            "_numberOfUsers" : "numberOfUsers",
            "_searchProfessionName" : "searchProfessionName",
        ]
    }
}
