//
//  AWSLocation.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

import Foundation
import AWSDynamoDB

class AWSLocation: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _countryName: String?
    var _cityName: String?
    var _creationDate: NSNumber?
    var _searchCountryName: String?
    var _searchCityName: String?
    var _state: String?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Locations"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_countryName"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_cityName"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_countryName" : "countryName",
            "_cityName" : "cityName",
            "_creationDate" : "creationDate",
            "_searchCountryName" : "searchCountryName",
            "_searchCityName" : "searchCityName",
            "_state" : "state",
        ]
    }
    
    class func ignoreAttributes() -> [String] {
        return ["creationDate"]
    }
}
