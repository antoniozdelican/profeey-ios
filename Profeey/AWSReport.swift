//
//  AWSReport.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/02/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

class AWSReport: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _reportId: String?
    var _created: NSNumber?
    
    var _reportedUserId: String?
    var _reportedPostId: String?
    var _reportType: String?
    var _reportDetailType: String?
    
    convenience init(_userId: String?, _reportId: String?, _created: NSNumber?, _reportedUserId: String?, _reportedPostId: String?, _reportType: String?, _reportDetailType: String?) {
        self.init()
        self._userId = _userId
        self._reportId = _reportId
        self._created = _created
        self._reportedUserId = _reportedUserId
        self._reportedPostId = _reportedPostId
        self._reportType = _reportType
        self._reportDetailType = _reportDetailType
    }
    
    class func dynamoDBTableName() -> String {
        #if DEVELOPMENT
            return "profeey-mobilehub-294297648-Reports"
        #else
            return "prodprofeey-mobilehub-725952970-Reports"
        #endif
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_reportId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_reportId" : "reportId",
            "_created" : "created",
            "_reportedUserId" : "reportedUserId",
            "_reportedPostId" : "reportedPostId",
            "_reportType" : "reportType",
            "_reportDetailType" : "reportDetailType",
        ]
    }
}
