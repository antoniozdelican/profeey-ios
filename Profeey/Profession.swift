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
    var searchProfessionName: String?
    
    // Generated.
    var numberOfUsersString: String? {
        if let numberOfUsers = self.numberOfUsers {
            let numberOfUsersInt = numberOfUsers.intValue
            return numberOfUsersInt == 1 ? "\(numberOfUsersInt) profeey" : "\(numberOfUsersInt) profeeys"
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
    
    convenience init(professionName: String?, searchProfessionName: String?, numberOfUsers: NSNumber?) {
        self.init()
        self.professionName = professionName
        self.numberOfUsers = numberOfUsers
        self.searchProfessionName = searchProfessionName
    }
}
