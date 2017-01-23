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
    var locationId: String?
    var locationName: String?
    var website: String?
    var numberOfFollowers: NSNumber?
    var numberOfPosts: NSNumber?
    var numberOfRecommendations: NSNumber?
    
    // For SignUp flow and editEmail.
    var email: String?
    var emailVerified: NSNumber?
    
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
    
    var websiteUrl: URL? {
        guard let website = self.website else {
            return nil
        }
        var websiteUrl: URL?
        if website.hasPrefix("http") || website.hasPrefix("https") {
            websiteUrl = URL(string: website)
        } else {
            websiteUrl = URL(string: "http://\(website)")
        }
        return websiteUrl
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
    
    // MARK: Custom copying
    
    func copyUser() -> User {
        let user = User(userId: userId, firstName: firstName, lastName: lastName, preferredUsername: preferredUsername, professionName: professionName, profilePicUrl: profilePicUrl)
        user.profilePic = self.profilePic
        return user
    }
    
    func copyEditUser() -> EditUser {
        let editUser = EditUser(userId: userId, firstName: firstName, lastName: lastName, preferredUsername: preferredUsername, professionName: professionName, profilePicUrl: profilePicUrl, locationId: locationId, locationName: locationName, website: website, about: about)
        editUser.profilePic = self.profilePic
        return editUser
    }
}
