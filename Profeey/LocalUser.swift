//
//  LocalUser.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/03/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

class LocalUser: NSObject {
    
    // MARK: firstName
    
    class func getFirstNameLocal() -> String? {
        return UserDefaults.standard.value(forKey: "firstName") as? String
    }
    
    class func setFirstNameLocal(_ firstName: String?) {
        UserDefaults.standard.setValue(firstName, forKey: "firstName")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: lastName
    
    class func getLastNameLocal() -> String? {
        return UserDefaults.standard.value(forKey: "lastName") as? String
    }
    
    class func setLastNameLocal(_ lastName: String?) {
        UserDefaults.standard.setValue(lastName, forKey: "lastName")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: preferredUsername
    
    class func getPreferredUsernameLocal() -> String? {
        return UserDefaults.standard.value(forKey: "preferredUsername") as? String
    }
    
    class func setPreferredUsernameLocal(_ preferredUsername: String?) {
        UserDefaults.standard.setValue(preferredUsername, forKey: "preferredUsername")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: professionName
    
    class func getProfessionNameLocal() -> String? {
        return UserDefaults.standard.value(forKey: "professionName") as? String
    }
    
    class func setProfessionNameLocal(_ professionName: String?) {
        UserDefaults.standard.setValue(professionName, forKey: "professionName")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: profilePicUrl
    
    class func getProfilePicUrlLocal() -> String? {
        return UserDefaults.standard.value(forKey: "profilePicUrl") as? String
    }
    
    class func setProfilePicUrlLocal(_ profilePicUrl: String?) {
        UserDefaults.standard.setValue(profilePicUrl, forKey: "profilePicUrl")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: schoolId
    
    class func getSchoolIdLocal() -> String? {
        return UserDefaults.standard.value(forKey: "schoolId") as? String
    }
    
    class func setSchoolIdLocal(_ schoolId: String?) {
        UserDefaults.standard.setValue(schoolId, forKey: "schoolId")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: schoolName
    
    class func getSchoolNameLocal() -> String? {
        return UserDefaults.standard.value(forKey: "schoolName") as? String
    }
    
    class func setSchoolNameLocal(_ schoolName: String?) {
        UserDefaults.standard.setValue(schoolName, forKey: "schoolName")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: All
    
    class func clearAllLocal() {
        UserDefaults.standard.removeObject(forKey: "firstName")
        UserDefaults.standard.removeObject(forKey: "lastName")
        UserDefaults.standard.removeObject(forKey: "preferredUsername")
        UserDefaults.standard.removeObject(forKey: "professionName")
        UserDefaults.standard.removeObject(forKey: "profilePicUrl")
        UserDefaults.standard.removeObject(forKey: "schoolId")
        UserDefaults.standard.removeObject(forKey: "schoolName")
    }
}
