//
//  AWSUserPreferredUsername.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class AWSUserPreferredUsername: AWSUser {
    
    class func ignoreAttributes() -> [String] {
        return ["about", "firstName", "lastName", "location", "profession", "profilePicUrl"]
    }
}