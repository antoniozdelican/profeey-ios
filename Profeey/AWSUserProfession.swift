//
//  AWSUserProfession.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class AWSUserProfession: AWSUser {
    
    class func ignoreAttributes() -> [String] {
        return ["about", "firstName", "lastName", "location", "preferredUsername", "profilePicUrl", "searchFirstName", "searchLastName"]
    }
}