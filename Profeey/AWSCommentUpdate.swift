//
//  AWSCommentUpdate.swift
//  Profeey
//
//  Created by Antonio Zdelican on 02/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class AWSCommentUpdate: AWSComment {
    
    class func ignoreAttributes() -> [String] {
        return ["postId", "postUserId", "created", "firstName", "lastName","preferredUsername", "professionName", "profilePicUrl"]
    }
}
