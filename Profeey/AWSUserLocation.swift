//
//  AWSUserLocation.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class AWSUserLocation: AWSUser {
    
    class func ignoreAttributes() -> [String] {
        return ["about", "firstName", "lastName", "preferredUsername", "profession", "profilePicUrl"]
    }
}