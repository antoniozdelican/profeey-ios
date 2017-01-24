//
//  AWSEndpointUser.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSEndpointUser: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _endpointARN: String?
    var _userId: String?
    var _created: NSNumber?
    
    convenience init(_endpointARN: String?, _userId: String?, _created: NSNumber?) {
        self.init()
        self._endpointARN = _endpointARN
        self._userId = _userId
        self._created = _created
    }
    
    // To remove on Sign Out.
    convenience init(_endpointARN: String?, _userId: String?) {
        self.init()
        self._endpointARN = _endpointARN
        self._userId = _userId
    }
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-EndpointUsers"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_endpointARN"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_endpointARN" : "endpointARN",
            "_userId" : "userId",
            "_created" : "created",
        ]
    }
}
