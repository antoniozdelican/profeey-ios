//
//  AWSBlock.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/02/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSBlock: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _blockingId: String?
    var _created: NSNumber?
    
    convenience init(_userId: String?, _blockingId: String?, _created: NSNumber?) {
        self.init()
        self._userId = _userId
        self._blockingId = _blockingId
        self._created = _created
    }
    
    // To remove Block.
    convenience init(_userId: String?, _blockingId: String?) {
        self.init()
        self._userId = _userId
        self._blockingId = _blockingId
    }
    
    class func dynamoDBTableName() -> String {
        #if DEVELOPMENT
            return "profeey-mobilehub-294297648-Blocks"
        #else
            return "prodprofeey-mobilehub-725952970-Blocks"
        #endif
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_blockingId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_blockingId" : "blockingId",
            "_created" : "created",
        ]
    }
}
