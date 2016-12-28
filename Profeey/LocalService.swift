//
//  LocalService.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

// Not used atm!
class LocalService: NSObject {
    
    // MARK: FirstName
    
    class func getFirstNameLocal() -> String? {
        return UserDefaults.standard.value(forKey: "firstName") as? String
    }
    
    class func setFirstNameLocal(_ firstName: String?) {
        UserDefaults.standard.setValue(firstName, forKey: "firstName")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: LastName
    
    class func getLastNameLocal() -> String? {
        return UserDefaults.standard.value(forKey: "lastName") as? String
    }
    
    class func setLastNameLocal(_ lastName: String?) {
        UserDefaults.standard.setValue(lastName, forKey: "lastName")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: PreferredUsername
    
    class func getPreferredUsernameLocal() -> String? {
        return UserDefaults.standard.value(forKey: "preferredUsername") as? String
    }
    
    class func setPreferredUsernameLocal(_ preferredUsername: String?) {
        UserDefaults.standard.setValue(preferredUsername, forKey: "preferredUsername")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: ProfessionName
    
    class func getProfessionNameLocal() -> String? {
        return UserDefaults.standard.value(forKey: "professionName") as? String
    }
    
    class func setProfessionNameLocal(_ professionName: String?) {
        UserDefaults.standard.setValue(professionName, forKey: "professionName")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: ProfilePicUrl
    
    class func getProfilePicUrlLocal() -> String? {
        return UserDefaults.standard.value(forKey: "profilePicUrl") as? String
    }
    
    class func setProfilePicUrlLocal(_ profilePicUrl: String?) {
        UserDefaults.standard.setValue(profilePicUrl, forKey: "profilePicUrl")
        UserDefaults.standard.synchronize()
    }
    
//    class func getProfilePicLocal() -> Data? {
//        return UserDefaults.standard.value(forKey: "profilePic") as? Data
//    }
//    
//    class func setProfilePicLocal(_ data: Data?) {
//        UserDefaults.standard.setValue(data, forKey: "profilePic")
//        UserDefaults.standard.synchronize()
//    }
    
    // MARK: All
    
    class func clearAllLocal() {
        UserDefaults.standard.removeObject(forKey: "firstName")
        UserDefaults.standard.removeObject(forKey: "lastName")
        UserDefaults.standard.removeObject(forKey: "preferredUsername")
        UserDefaults.standard.removeObject(forKey: "professionName")
        UserDefaults.standard.removeObject(forKey: "profilePicUrl")
    }
}
