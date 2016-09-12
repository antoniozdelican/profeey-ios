//
//  User.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class User: NSObject {
    
    // Properties.
    var userId: String?
    var about: String?
    var firstName: String?
    var lastName: String?
    var locationName: String?
    var preferredUsername: String?
    var professionName: String?
    var profilePicUrl: String?
    
    // For SignUp flow.
    var email: String?
    
    // For UserRelationship
    var numberOfNewPosts: NSNumber?
    
    // Generated.
    var profilePic: UIImage?
    var fullName: String? {
        return [self.firstName, self.lastName].flatMap{$0}.joinWithSeparator(" ")
    }
    
    //var posts: [Post]?
    
    override init() {
        super.init()
    }
    
    convenience init(userId: String?, firstName: String?, lastName: String?, preferredUsername: String?, professionName: String?, profilePicUrl: String?, locationName: String?, about: String?) {
        self.init()
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.preferredUsername = preferredUsername
        self.professionName = professionName
        self.profilePicUrl = profilePicUrl
        self.locationName = locationName
        self.about = about
    }
    
    convenience init(userId: String?, firstName: String?, lastName: String?, preferredUsername: String?, professionName: String?, profilePicUrl: String?, numberOfNewPosts: NSNumber?) {
        self.init()
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.preferredUsername = preferredUsername
        self.professionName = professionName
        self.profilePicUrl = profilePicUrl
        self.numberOfNewPosts = numberOfNewPosts
    }
    
    // Basic user got from post.
    // Should be used as default and then load location, about and other attributes when we open ProfileTableVc.
    convenience init(userId: String?, firstName: String?, lastName: String?, preferredUsername: String?, professionName: String?, profilePicUrl: String?) {
        self.init()
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.preferredUsername = preferredUsername
        self.professionName = professionName
        self.profilePicUrl = profilePicUrl
    }
}