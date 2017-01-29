//
//  AWSRecommendation.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

class AWSRecommendation: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _recommendingId: String?
    var _created: NSNumber?
    var _recommendationText: String?
    
    // Recommender data.
    var _firstName: String?
    var _lastName: String?
    var _preferredUsername: String?
    var _professionName: String?
    var _profilePicUrl: String?
    
    convenience init(_userId: String?, _recommendingId: String?, _created: NSNumber?, _recommendationText: String?, _firstName: String?, _lastName: String?, _preferredUsername: String?, _professionName: String?, _profilePicUrl: String?) {
        self.init()
        self._userId = _userId
        self._recommendingId = _recommendingId
        self._created = _created
        self._recommendationText = _recommendationText
        self._firstName = _firstName
        self._lastName = _lastName
        self._preferredUsername = _preferredUsername
        self._professionName = _professionName
        self._profilePicUrl = _profilePicUrl
    }
    
    // To remove Recommendation.
    convenience init(_userId: String?, _recommendingId: String?) {
        self.init()
        self._userId = _userId
        self._recommendingId = _recommendingId
    }
    
    class func dynamoDBTableName() -> String {
        #if DEVELOPMENT
            return "profeey-mobilehub-294297648-Recommendations"
        #else
            return "prodprofeey-mobilehub-725952970-Recommendations"
        #endif
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_recommendingId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_recommendingId" : "recommendingId",
            "_created" : "created",
            "_recommendationText" : "recommendationText",
            "_firstName" : "firstName",
            "_lastName" : "lastName",
            "_preferredUsername" : "preferredUsername",
            "_professionName" : "professionName",
            "_profilePicUrl" : "profilePicUrl",
        ]
    }
}
