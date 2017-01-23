//
//  FullUser.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class FullUser: User {
    
    override init() {
        super.init()
    }
    
    convenience init(userId: String?, firstName: String?, lastName: String?, preferredUsername: String?, professionName: String?, profilePicUrl: String?, locationId: String?, locationName: String?, website: String?, about: String?, numberOfFollowers: NSNumber?, numberOfPosts: NSNumber?, numberOfRecommendations: NSNumber?, email: String?, emailVerified: NSNumber?) {
        self.init()
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.preferredUsername = preferredUsername
        self.professionName = professionName
        self.profilePicUrl = profilePicUrl
        self.locationId = locationId
        self.locationName = locationName
        self.website = website
        self.about = about
        self.numberOfFollowers = numberOfFollowers
        self.numberOfPosts = numberOfPosts
        self.numberOfRecommendations = numberOfRecommendations
        self.email = email
        self.emailVerified = emailVerified
    }
}
