//
//  School.swift
//  Profeey
//
//  Created by Antonio Zdelican on 04/03/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation

class School: NSObject {
    
    // Properties.
    var schoolId: String?
    var schoolName: String?
    var numberOfUsers: NSNumber?
    
    // Generated.
    var numberOfUsersInt: Int {
        guard let numberOfUsers = self.numberOfUsers else {
            return 0
        }
        return numberOfUsers.intValue
    }
    var numberOfUsersString: String? {
        guard let numberOfUsers = self.numberOfUsers else {
            return nil
        }
        let numberOfUsersInt = numberOfUsers.intValue
        guard numberOfUsersInt > 0 else {
            return nil
        }
        return numberOfUsersInt == 1 ? "\(numberOfUsersInt) profeey" : "\(numberOfUsersInt) profeeys"
    }
    
    override init() {
        super.init()
    }
    
    convenience init(schoolId: String?, schoolName: String?, numberOfUsers: NSNumber?) {
        self.init()
        self.schoolId = schoolId
        self.schoolName = schoolName
        self.numberOfUsers = numberOfUsers
    }
}
