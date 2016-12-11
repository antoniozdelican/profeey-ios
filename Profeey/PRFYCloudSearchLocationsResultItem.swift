//
//  PRFYCloudSearchLocationsResultItem.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSCore


public class PRFYCloudSearchLocationsResultItem : AWSModel {
    
    // not using id because id in DynamoDB is locationId
    var id: String?
    
    var locationId: String?
    var country: String?
    var state: String?
    var city: String?
    var latitude: NSNumber?
    var longitude: NSNumber?
    var numberOfUsers: NSNumber?
    
   	override public class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "locationId" : "locationId",
            "country" : "country",
            "state" : "state",
            "city" : "city",
            "latitude" : "latitude",
            "longitude" : "longitude",
            "numberOfUsers" : "numberOfUsers",
        ]
    }
}
