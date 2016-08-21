//
//  User.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

class User: NSObject {
    
    // Properties.
    var firstName: String?
    var lastName: String?
    var email: String?
    var preferredUsername: String?
    var professions: [String]?
    var profilePicUrl: String?
    
    
    // TEST
    var about: String?
    var location: String?
    var website: String?
    
    var fullName: String? {
        return [self.firstName, self.lastName].flatMap{$0}.joinWithSeparator(" ")
    }
    
    var profilePicData: NSData?
    var profilePic: UIImage? {
        if let profilePicData = self.profilePicData {
            return UIImage(data: profilePicData)
        } else {
            return nil
        }
    }
    
    var posts: [Post]?
    
    override init() {
        super.init()
    }
    
    convenience init(firstName: String?, lastName: String?, preferredUsername: String?, professions: [String]?, profilePicUrl: String?) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.preferredUsername = preferredUsername
        self.professions = professions
        self.profilePicUrl = profilePicUrl
    }
    
    // TEST
    convenience init(firstName: String?, lastName: String?, preferredUsername: String?, professions: [String]?, profilePicData: NSData?) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.preferredUsername = preferredUsername
        self.professions = professions
        self.profilePicData = profilePicData
    }
    
    // TEST
    convenience init(firstName: String?, lastName: String?, preferredUsername: String?, profilePicData: NSData?, professions: [String]?) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.preferredUsername = preferredUsername
        self.profilePicData = profilePicData
        self.professions = professions
    }
    
    // TEST
    convenience init(firstName: String?, lastName: String?, preferredUsername: String?, profilePicData: NSData?, professions: [String]?, about: String?, location: String?, website: String?, posts: [Post]?) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.preferredUsername = preferredUsername
        self.profilePicData = profilePicData
        self.professions = professions
        self.about = about
        self.location = location
        self.website = website
        self.posts = posts
    }
}