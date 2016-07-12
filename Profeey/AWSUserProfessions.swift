//
//  AWSUserProfessions.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class AWSUserProfessions: AWSUser {
    
    class func ignoreAttributes() -> [String] {
        return ["about", "fullName", "preferredUsername", "profilePicUrl"]
    }
}