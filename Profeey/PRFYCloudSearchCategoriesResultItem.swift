//
//  PRFYCloudSearchCategoriesResultItem.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSCore


public class PRFYCloudSearchCategoriesResultItem : AWSModel {
    
    // not using id because id in DynamoDB is categoryName
    var id: String?
    
    var categoryName: String?
    var numberOfPosts: NSNumber?
    
   	override public class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "categoryName" : "categoryName",
            "numberOfPosts" : "numberOfPosts",
        ]
    }
}
