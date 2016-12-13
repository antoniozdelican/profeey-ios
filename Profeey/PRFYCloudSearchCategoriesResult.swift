//
//  PRFYCloudSearchCategoriesResult.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSCore


public class PRFYCloudSearchCategoriesResult : AWSModel {
    
    var found: NSNumber?
    var start: NSNumber?
    var categories: [PRFYCloudSearchCategoriesResultItem]?
    
   	override public class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        
        return [
            "found" : "found",
            "start" : "start",
            "categories" : "categories",
        ]
    }
    class func categoriesJSONTransformer() -> ValueTransformer {
        return  ValueTransformer.awsmtl_JSONArrayTransformer(withModelClass: PRFYCloudSearchCategoriesResultItem.self);
    }
}
