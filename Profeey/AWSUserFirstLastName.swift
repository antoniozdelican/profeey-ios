//
//  AWSUserFullName.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

/*
 * Update firstName and lastName.
 */
class AWSUserFirstLastName: AWSUser {
    
    class func ignoreAttributes() -> [String] {
        return ["about", "location", "preferredUsername", "profession", "profilePicUrl"]
    }
}