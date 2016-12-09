//
//  PRFYCloudSearchLocationsResult.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSCore

public class PRFYCloudSearchLocationsResult : AWSModel {
    
    var found: NSNumber?
    var start: NSNumber?
    var locations: [PRFYCloudSearchLocationsResultItem]?
    
   	override public class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        
        return [
            "found" : "found",
            "start" : "start",
            "locations" : "locations",
        ]
    }
    class func locationsJSONTransformer() -> ValueTransformer {
        return  ValueTransformer.awsmtl_JSONArrayTransformer(withModelClass: PRFYCloudSearchLocationsResultItem.self);
    }
}
