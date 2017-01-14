//
//  AWSNotificationsCounter.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSNotificationsCounter: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _numberOfNewNotifications: NSNumber?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-NotificationsCounters"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_numberOfNewNotifications" : "numberOfNewNotifications",
        ]
    }
}
