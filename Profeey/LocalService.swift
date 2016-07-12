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
        return NSUserDefaults.standardUserDefaults().valueForKey("fullName") as? String
    }
    
    class func setFullNameLocal(fullName: String?) {
        NSUserDefaults.standardUserDefaults().setValue(fullName, forKey: "fullName")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // MARK: PreferredUsername
    
    class func getPreferredUsernameLocal() -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey("preferredUsername") as? String
    }
    
    class func setPreferredUsernameLocal(preferredUsername: String?) {
        NSUserDefaults.standardUserDefaults().setValue(preferredUsername, forKey: "preferredUsername")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // MARK: Professions
    
    class func getProfessionsLocal() -> [String]? {
//        if let professions = NSUserDefaults.standardUserDefaults().valueForKey("professions") as? NSArray {
//            let professionsSet = self.getSetFromArray(professions)
//            return professionsSet
//        } else {
//            return nil
//        }
        return NSUserDefaults.standardUserDefaults().valueForKey("professions") as? [String]
    }
    
    private class func getSetFromArray(array: NSArray) -> Set<String> {
        let set = Set(array.map({ String($0) }))
        return set
    }
    
    class func setProfessionsLocal(professions: [String]?) {
        NSUserDefaults.standardUserDefaults().setValue(professions, forKey: "professions")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private class func getArrayFromSet(set: Set<String>) -> NSArray {
        let array = NSArray(array: set.map({ String($0) }))
        return array
    }
    
    // MARK: About
    
    class func getAboutLocal() -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey("about") as? String
    }
    
    class func setAboutLocal(about: String?) {
        NSUserDefaults.standardUserDefaults().setValue(about, forKey: "about")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // MARK: ProfilePic
    
    class func getProfilePicUrlLocal() -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey("profilePicUrl") as? String
    }
    
    class func setProfilePicUrlLocal(profilePicUrl: String?) {
        NSUserDefaults.standardUserDefaults().setValue(profilePicUrl, forKey: "profilePicUrl")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getProfilePicLocal() -> NSData? {
        return NSUserDefaults.standardUserDefaults().valueForKey("profilePic") as? NSData
    }
    
    class func setProfilePicLocal(data: NSData?) {
        NSUserDefaults.standardUserDefaults().setValue(data, forKey: "profilePic")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // MARK: All
    
    class func clearAllLocal() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("fullName")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("preferredUsername")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("professions")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("about")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("profilePicUrl")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("profilePic")
    }
}