//
//  AWSProfession.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

class AWSProfession: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _professionName: String?
    var _numberOfUsers: String?
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-1226628658-Professions"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_professionName"
    }
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject] {
        return [
            "_professionName" : "professionName",
            "_numberOfUsers" : "numberOfUsers",
        ]
    }
}
