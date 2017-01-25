//
//  AWSPostUpdate.swift
//  Profeey
//
//  Created by Antonio Zdelican on 06/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

// Use this for post update on EditPostVc.

class AWSPostUpdate: AWSPost {
    
    class func ignoreAttributes() -> [String] {
        return ["created", "imageUrl", "imageWidth", "imageHeight", "numberOfLikes", "numberOfComments", "firstName", "lastName","preferredUsername", "professionName", "profilePicUrl"]
    }
}
