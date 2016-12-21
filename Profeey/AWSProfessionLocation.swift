//
//  AWSProfessionLocation.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSProfessionLocation: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _professionName: String?
    var _locationId: String?
    var _locationName: String?
    var _numberOfUsers: NSNumber?
    var _created: NSNumber?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-ProfessionLocations"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_professionName"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_locationId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_professionName" : "professionName",
            "_locationId" : "locationId",
            "_locationName" : "locationName",
            "_numberOfUsers" : "numberOfUsers",
            "_created" : "created",
        ]
    }
    
    class func ignoreAttributes() -> [String] {
        return ["created"]
    }
}
