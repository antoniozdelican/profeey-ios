//
//  LocalService.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class LocalService: NSObject {
    
    // MARK: FullName
    
    class func getFullNameLocal() -> String? {
        return UserDefaults.standard.value(forKey: "fullName") as? String
    }
    
    class func setFullNameLocal(_ fullName: String?) {
        UserDefaults.standard.setValue(fullName, forKey: "fullName")
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
    
    // MARK: Professions
    
    class func getProfessionsLocal() -> [String]? {
//        if let professions = NSUserDefaults.standardUserDefaults().valueForKey("professions") as? NSArray {
//            let professionsSet = self.getSetFromArray(professions)
//            return professionsSet
//        } else {
//            return nil
//        }
        return UserDefaults.standard.value(forKey: "professions") as? [String]
    }
    
    fileprivate class func getSetFromArray(_ array: NSArray) -> Set<String> {
        let set = Set(array.map({ String(describing: $0) }))
        return set
    }
    
    class func setProfessionsLocal(_ professions: [String]?) {
        UserDefaults.standard.setValue(professions, forKey: "professions")
        UserDefaults.standard.synchronize()
    }
    
    fileprivate class func getArrayFromSet(_ set: Set<String>) -> NSArray {
        let array = NSArray(array: set.map({ String($0) }))
        return array
    }
    
    // MARK: About
    
    class func getAboutLocal() -> String? {
        return UserDefaults.standard.value(forKey: "about") as? String
    }
    
    class func setAboutLocal(_ about: String?) {
        UserDefaults.standard.setValue(about, forKey: "about")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: ProfilePic
    
    class func getProfilePicUrlLocal() -> String? {
        return UserDefaults.standard.value(forKey: "profilePicUrl") as? String
    }
    
    class func setProfilePicUrlLocal(_ profilePicUrl: String?) {
        UserDefaults.standard.setValue(profilePicUrl, forKey: "profilePicUrl")
        UserDefaults.standard.synchronize()
    }
    
    class func getProfilePicLocal() -> Data? {
        return UserDefaults.standard.value(forKey: "profilePic") as? Data
    }
    
    class func setProfilePicLocal(_ data: Data?) {
        UserDefaults.standard.setValue(data, forKey: "profilePic")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: All
    
    class func clearAllLocal() {
        UserDefaults.standard.removeObject(forKey: "fullName")
        UserDefaults.standard.removeObject(forKey: "preferredUsername")
        UserDefaults.standard.removeObject(forKey: "professions")
        UserDefaults.standard.removeObject(forKey: "about")
        UserDefaults.standard.removeObject(forKey: "profilePicUrl")
        UserDefaults.standard.removeObject(forKey: "profilePic")
    }
}
