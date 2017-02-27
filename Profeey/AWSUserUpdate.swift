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
        return ["created", "preferredUsername", "email", "emailVerified", "numberOfFollowers", "numberOfPosts", "numberOfRecommendations", "isFacebookUser", "isDisabled"]
    }
}
