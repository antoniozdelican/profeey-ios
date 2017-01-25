//
//  AWSWorkExperience.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSWorkExperience: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _workExperienceId: String?
    var _created: NSNumber?
    var _title: String?
    var _organization: String?
    var _workDescription: String?
    var _fromMonth: NSNumber?
    var _fromYear: NSNumber?
    var _toMonth: NSNumber?
    var _toYear: NSNumber?
    
    convenience init(_userId: String?, _workExperienceId: String?, _created: NSNumber?, _title: String?, _organization: String?, _workDescription: String?, _fromMonth: NSNumber?, _fromYear: NSNumber?, _toMonth: NSNumber?, _toYear: NSNumber?) {
        self.init()
        self._userId = _userId
        self._workExperienceId = _workExperienceId
        self._created = _created
        self._title = _title
        self._organization = _organization
        self._workDescription = _workDescription
        self._fromMonth = _fromMonth
        self._fromYear = _fromYear
        self._toMonth = _toMonth
        self._toYear = _toYear
    }
    
    // To remove WorkExperience.
    convenience init(_userId: String?, _workExperienceId: String?) {
        self.init()
        self._userId = _userId
        self._workExperienceId = _workExperienceId
    }
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-WorkExperiences"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_workExperienceId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_workExperienceId" : "workExperienceId",
            "_created" : "created",
            "_title" : "title",
            "_organization" : "organization",
            "_workDescription" : "workDescription",
            "_fromMonth" : "fromMonth",
            "_fromYear" : "fromYear",
            "_toMonth" : "toMonth",
            "_toYear" : "toYear",
        ]
    }
}
