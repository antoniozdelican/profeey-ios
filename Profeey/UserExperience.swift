//
//  UserExperience.swift
//  Profeey
//
//  Created by Antonio Zdelican on 19/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class UserExperience: NSObject {
    
    // Properties.
    var userId: String?
    var position: String?
    var organization: String?
    var fromDate: NSNumber?
    var toDate: NSNumber?
    var experienceType: NSNumber?
    
    override init() {
        super.init()
    }
    
    convenience init(userId: String?, position: String?, organization: String?, fromDate: NSNumber?, toDate: NSNumber?, experienceType: NSNumber?) {
        self.init()
        self.userId = userId
        self.position = position
        self.organization = organization
        self.fromDate = fromDate
        self.toDate = toDate
        self.experienceType = experienceType
    }
}