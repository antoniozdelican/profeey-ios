//
//  User.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class User: NSObject {
    
    // Basic properties.
    var userId: String?
    var firstName: String?
    var lastName: String?
    var preferredUsername: String?
    var professionName: String?
    var profilePicUrl: String?
    
    // Extra properties.
    var about: String?
    var locationName: String?
    var numberOfFollowers: NSNumber?
    var numberOfPosts: NSNumber?
    var numberOfRecommendations: NSNumber?
    
    var professionId: String?
    var locationId: String?
    
    // For SignUp flow.
    var email: String?
    
    // Generated.
    var profilePic: UIImage?
    var fullName: String? {
        return [self.firstName, self.lastName].flatMap{$0}.joined(separator: " ")
    }
    var numberOfPostsInt: Int {
        guard let numberOfPostsInt = self.numberOfPosts else {
            return 0
        }
        return numberOfPostsInt.intValue
    }
    var numberOfFollowersInt: Int {
        guard let numberOfFollowers = self.numberOfFollowers else {
            return 0
        }
        return numberOfFollowers.intValue
    }
    var numberOfRecommendationsInt: Int {
        guard let numberOfRecommendations = self.numberOfRecommendations else {
            return 0
        }
        return numberOfRecommendations.intValue
    }
    
    var searchFirstName: String? {
        guard let firstName = self.firstName else {
            return nil
        }
        return firstName.lowercased()
    }
    var searchLastName: String? {
        guard let lastName = self.lastName else {
            return nil
        }
        return lastName.lowercased()
    }
    var searchPreferredUsername: String? {
        guard let preferredUsername = self.preferredUsername else {
            return nil
        }
        return preferredUsername.lowercased()
    }
    
    override init() {
        super.init()
    }
    
    // Basic user got from post.
    // Should be used as default and then load location, about and other attributes when we open ProfileVc.
    convenience init(userId: String?, firstName: String?, lastName: String?, preferredUsername: String?, professionName: String?, profilePicUrl: String?) {
        self.init()
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.preferredUsername = preferredUsername
        self.professionName = professionName
        self.profilePicUrl = profilePicUrl
    }
    
    // Basic with location, no professionId nor locationId.
    convenience init(userId: String?, firstName: String?, lastName: String?, preferredUsername: String?, professionName: String?, profilePicUrl: String?, locationName: String?) {
        self.init()
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.preferredUsername = preferredUsername
        self.professionName = professionName
        self.profilePicUrl = profilePicUrl
        self.locationName = locationName
    }
    
    // Partial user for EditVc
    convenience init(userId: String?, firstName: String?, lastName: String?, professionId: String?, professionName: String?, profilePicUrl: String?, about: String?, locationId: String?, locationName: String?) {
        self.init()
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.professionName = professionName
        self.profilePicUrl = profilePicUrl
        self.about = about
        self.locationName = locationName
        self.professionId = professionId
        self.locationId = locationId
    }
    
    // Full user for ProfileVc.
    convenience init(userId: String?, firstName: String?, lastName: String?, preferredUsername: String?, professionId: String?, professionName: String?, profilePicUrl: String?, about: String?, locationId: String?, locationName: String?, numberOfFollowers: NSNumber?, numberOfPosts: NSNumber?, numberOfRecommendations: NSNumber?) {
        self.init()
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.preferredUsername = preferredUsername
        self.professionName = professionName
        self.profilePicUrl = profilePicUrl
        self.about = about
        self.locationName = locationName
        self.numberOfFollowers = numberOfFollowers
        self.numberOfPosts = numberOfPosts
        self.numberOfRecommendations = numberOfRecommendations
        self.professionId = professionId
        self.locationId = locationId
    }
}
