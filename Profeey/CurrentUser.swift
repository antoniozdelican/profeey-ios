//
//  CurrentUser.swift
//  Profeey
//
//  Created by Antonio Zdelican on 16/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class CurrentUser: User {
    
    override init() {
        super.init()
    }
    
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
}
