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
    // Need because Post key is combo of userId (postUserId) and postId.
    var _postUserId: String?
    var _creationDate: NSNumber?
    
    // Liker data.
    var _firstName: String?
    var _lastName: String?
    var _preferredUsername: String?
    var _professionName: String?
    var _profilePicUrl: String?
    
    
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
            "_postUserId" : "postUserId",
            "_creationDate" : "creationDate",
            "_firstName" : "firstName",
            "_lastName" : "lastName",
            "_preferredUsername" : "preferredUsername",
            "_professionName" : "professionName",
            "_profilePicUrl" : "profilePicUrl",
        ]
    }
}