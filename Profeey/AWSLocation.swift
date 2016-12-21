//
//  AWSLocation.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSLocation: AWSDynamoDBObjectModel, AWSDynamoDBModeling {

    var _locationId: String?
    var _country: String?
    var _state: String?
    var _city: String?
    var _latitude: NSNumber?
    var _longitude: NSNumber?
    var _numberOfUsers: NSNumber?
    var _created: NSNumber?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Locations"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_locationId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_locationId" : "locationId",
            "_country" : "country",
            "_state" : "state",
            "_city" : "city",
            "_latitude" : "latitude",
            "_longitude" : "longitude",
            "_numberOfUsers" : "numberOfUsers",
            "_created" : "created",
        ]
    }
    
    class func ignoreAttributes() -> [String] {
        return ["created"]
    }
}
