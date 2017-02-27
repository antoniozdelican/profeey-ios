//
//  AWSUserNumberOfPosts.swift
//  Profeey
//
//  Created by Antonio Zdelican on 28/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation

// Use this for get user numberOfPosts when trying to recommend.

class AWSUserNumberOfPosts: AWSUser {
    
    class func ignoreAttributes() -> [String] {
        return ["created", "firstName", "lastName", "preferredUsername", "professionName", "profilePicUrl", "about", "email", "emailVerified", "locationId", "locationName", "website", "numberOfFollowers", "numberOfRecommendations", "isFacebookUser", "isDisabled"]
    }
}
