//
//  UserPoolManager.swift
//  Profeey
//
//  Created by Antonio Zdelican on 10/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSMobileHubHelper

protocol UserPoolManager {
    
    func logInUserPool(username: String, password: String, completionHandler: AWSContinuationBlock)
    func signUpUserPool(username: String, password: String, email: String, firstName: String, lastName: String, completionHandler: AWSContinuationBlock)
    func signOutUserPool(completionHandler: AWSContinuationBlock)
    
    func getUserDetailsUserPool(completionHandler: AWSContinuationBlock)
    func updateFirstLastNameUserPool(firstName: String, lastName: String, completionHandler: AWSContinuationBlock)
    func updatePreferredUsernameUserPool(preferredUsername: String, completionHandler: AWSContinuationBlock)
    
}