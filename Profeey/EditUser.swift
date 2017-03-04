//
//  EditUser.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class EditUser: User {
    
    override init() {
        super.init()
    }
    
    convenience init(userId: String?, firstName: String?, lastName: String?, preferredUsername: String?, professionName: String?, profilePicUrl: String?, schoolId: String?, schoolName: String?, website: String?, about: String?) {
        self.init()
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.preferredUsername = preferredUsername
        self.professionName = professionName
        self.profilePicUrl = profilePicUrl
        self.schoolId = schoolId
        self.schoolName = schoolName
        self.website = website
        self.about = about
    }
}
