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
    var numberOfUsersString: String? {
        if let numberOfUsers = self.numberOfUsers {
            let numberOfUsersInt = numberOfUsers.integerValue
            return numberOfUsersInt == 1 ? "\(numberOfUsersInt) person" : "\(numberOfUsersInt) people"
        } else {
            return nil
        }
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
