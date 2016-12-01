//
//  AWSUserEndpoint.swift
//  Profeey
//
//  Created by Antonio Zdelican on 01/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

// Used to store device-specific endpoints for AWS SNS
class AWSUserEndpoint: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _endpointARN: String?
    
    convenience init(_userId: String?, _endpointARN: String?) {
        self.init()
        self._userId = _userId
        self._endpointARN = _endpointARN
    }
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-UserEndpoints"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_endpointARN"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_endpointARN" : "_endpointARN",
        ]
    }
}
