//
//  User.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

class User: NSObject {
    
    var about: String?
    var fullName: String?
    var preferredUsername: String?
    var profilePicUrl: String?
    var professions: [String]?
    
    var profilePicData: NSData?
    
    override init() {
        super.init()
    }
}