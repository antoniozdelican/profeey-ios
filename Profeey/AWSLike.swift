//
//  AWSLike.swift
//  Profeey
//
//  Created by Antonio Zdelican on 27/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

class AWSLike: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _postId: String?
    var _creationDate: NSNumber?
    
    var _likerFirstName: String?
    var _likerLastName: String?
    var _likerPreferredUsername: String?
    var _likerProfession: String?
    var _likerProfilePicUrl: String?
    
    
    class func dynamoDBTableName() -> String {
        
        return "profeey-mobilehub-294297648-Likes"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_postId"
    }
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject] {
        return [
            "_userId" : "userId",
            "_postId" : "postId",
            "_creationDate" : "creationDate",
            "_likerFirstName" : "likerFirstName",
            "_likerLastName" : "likerLastName",
            "_likerPreferredUsername" : "likerPreferredUsername",
            "_likerProfession" : "likerProfession",
            "_likerProfilePicUrl" : "likerProfilePicUrl",
        ]
    }
}