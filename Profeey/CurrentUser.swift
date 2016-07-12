//
//  CurrentUser.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class CurrentUser: User {
    
    override init() {
        super.init()
        self.configureFromLocal()
    }
    
    // Always initialize with local cached data.
    private func configureFromLocal() {
        self.about = LocalService.getAboutLocal()
        self.fullName = LocalService.getFullNameLocal()
        self.preferredUsername = LocalService.getPreferredUsernameLocal()
        self.professions = LocalService.getProfessionsLocal()
        self.profilePicUrl = LocalService.getProfilePicUrlLocal()
        // Set upon S3 download in controllers.
        self.profilePicData = LocalService.getProfilePicLocal()
    }
    
    // Update self and local cached data.
    func updateFromRemote(awsUser: AWSUser) {
        LocalService.setAboutLocal(awsUser._about)
        LocalService.setFullNameLocal(awsUser._fullName)
        LocalService.setPreferredUsernameLocal(awsUser._preferredUsername)
        LocalService.setProfessionsLocal(awsUser._professions)
        LocalService.setProfilePicUrlLocal(awsUser._profilePicUrl)
        self.configureFromLocal()
    }
}