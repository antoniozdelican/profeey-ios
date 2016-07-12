//
//  AWSUserFullName.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class AWSUserFullName: AWSUser {
    
    class func ignoreAttributes() -> [String] {
        return ["about", "preferredUsername", "profilePicUrl", "professions"]
    }
}