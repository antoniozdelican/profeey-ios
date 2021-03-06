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
    var schoolId: String?
    var schoolName: String?
    var website: String?
    var numberOfFollowers: NSNumber?
    var numberOfPosts: NSNumber?
    var numberOfCategories: NSNumber?
    
    // For SignUp flow and editEmail.
    var email: String?
    var emailVerified: NSNumber?
    
    // For settings to remove editEmail and editPassword.
    var isFacebookUser: NSNumber?
    
    // Generated.
    var profilePic: UIImage?
    var fullName: String? {
        return [self.firstName, self.lastName].flatMap{$0}.joined(separator: " ")
    }
    var professionNameWhitespace: String? {
        guard let professionName = self.professionName else {
            return nil
        }
        return professionName.replacingOccurrences(of: "_", with: " ")
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
    var numberOfCategoriesInt: Int {
        guard let numberOfCategories = self.numberOfCategories else {
            return 0
        }
        return numberOfCategories.intValue
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
    // Should be used as default and then load school, about and other attributes when we open ProfileVc.
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
        let editUser = EditUser(userId: userId, firstName: firstName, lastName: lastName, preferredUsername: preferredUsername, professionName: professionName, profilePicUrl: profilePicUrl, schoolId: schoolId, schoolName: schoolName, website: website, about: about)
        editUser.profilePic = self.profilePic
        return editUser
    }
}
