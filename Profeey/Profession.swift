//
//  Profession.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class Profession: NSObject {
    
    // Properties.
    var professionName: String?
    var numberOfUsers: NSNumber?
    
    // Generated.
    var professionNameWhitespace: String? {
        return self.professionName?.replacingOccurrences(of: "_", with: " ")
    }
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
    
    convenience init(professionName: String?, numberOfUsers: NSNumber?) {
        self.init()
        self.professionName = professionName
        self.numberOfUsers = numberOfUsers
    }
}
