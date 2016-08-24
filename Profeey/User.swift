//
//  User.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

class User: NSObject {
    
    // Properties.
    var userId: String?
    var about: String?
    var firstName: String?
    var lastName: String?
    var location: String?
    var preferredUsername: String?
    var profession: String?
    var profilePicUrl: String?
    
    // For SignUp flow.
    var email: String?
    
    // Generated.
    var fullName: String? {
        return [self.firstName, self.lastName].flatMap{$0}.joinWithSeparator(" ")
    }
    var profilePic: UIImage?
    
    var posts: [Post]?
    
    override init() {
        super.init()
    }
    
    convenience init(firstName: String?, lastName: String?, preferredUsername: String?, profession: String?, profilePicUrl: String?, location: String?, about: String?) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.preferredUsername = preferredUsername
        self.profession = profession
        self.profilePicUrl = profilePicUrl
        self.location = location
        self.about = about
    }
    
    convenience init(firstName: String?, lastName: String?, preferredUsername: String?, profession: String?, profilePic: UIImage?) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.preferredUsername = preferredUsername
        self.profession = profession
        self.profilePic = profilePic
    }
}