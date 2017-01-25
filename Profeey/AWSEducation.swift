//
//  AWSEducation.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSEducation: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _educationId: String?
    var _created: NSNumber?
    var _school: String?
    var _fieldOfStudy: String?
    var _educationDescription: String?
    var _fromMonth: NSNumber?
    var _fromYear: NSNumber?
    var _toMonth: NSNumber?
    var _toYear: NSNumber?
    
    convenience init(_userId: String?, _educationId: String?, _created: NSNumber?, _school: String?, _fieldOfStudy: String?, _educationDescription: String?, _fromMonth: NSNumber?, _fromYear: NSNumber?, _toMonth: NSNumber?, _toYear: NSNumber?) {
        self.init()
        self._userId = _userId
        self._educationId = _educationId
        self._created = _created
        self._school = _school
        self._fieldOfStudy = _fieldOfStudy
        self._educationDescription = _educationDescription
        self._fromMonth = _fromMonth
        self._fromYear = _fromYear
        self._toMonth = _toMonth
        self._toYear = _toYear
    }
    
    // To remove education.
    convenience init(_userId: String?, _educationId: String?) {
        self.init()
        self._userId = _userId
        self._educationId = _educationId
    }
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Educations"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_educationId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_educationId" : "educationId",
            "_created" : "created",
            "_school" : "school",
            "_fieldOfStudy" : "fieldOfStudy",
            "_educationDescription" : "educationDescription",
            "_fromMonth" : "fromMonth",
            "_fromYear" : "fromYear",
            "_toMonth" : "toMonth",
            "_toYear" : "toYear",
        ]
    }
}
