//
//  AWSUserUpdate.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

// Use this for user update on EditProfileVc.

class AWSUserUpdate: AWSUser {
    
    class func ignoreAttributes() -> [String] {
        return ["creationDate", "email", "numberOfFollowers", "numberOfPosts", "preferredUsername","searchPreferredUsername", "topCategories"]
    }
}