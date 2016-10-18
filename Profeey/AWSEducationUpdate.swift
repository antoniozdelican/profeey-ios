//
//  AWSEducationUpdate.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class AWSEducationUpdate: AWSEducation {
    
    class func ignoreAttributes() -> [String] {
        return ["creationDate"]
    }
}
