//
//  PRFYUserPoolManager.swift
//  Profeey
//
//  Created by Antonio Zdelican on 10/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSCognitoIdentityProvider

class PRFYUserPoolManager: NSObject, UserPoolManager {
    
    private static var sharedInstance: PRFYUserPoolManager!
    
    static func defaultUserPoolManager() -> PRFYUserPoolManager {
        if sharedInstance == nil {
            sharedInstance = PRFYUserPoolManager()
        }
        return sharedInstance
    }
    
    func logInUserPool(username: String, password: String, completionHandler: AWSContinuationBlock) {
        print("logInUserPool:")
        let user = AWSClientManager.defaultClientManager().userPool?.getUser()
        user?.getSession(username, password: password, validationData: nil).continueWithBlock(completionHandler)
        
//        user?.getSession(username, password: password, validationData: nil).continueWithBlock({
//            (task: AWSTask) in
//            if let error = task.error {
//                print("logInUserPool error:")
//                return AWSTask(error: error).continueWithBlock(completionHandler)
//            } else {
//                print("logInUserPool success!")
//                return task.continueWithBlock(completionHandler)
//            }
//        })
    }
    
    func signUpUserPool(username: String, password: String, email: String, firstName: String, lastName: String, completionHandler: AWSContinuationBlock) {
        print("signUpUserPool:")
        var attributes: [AWSCognitoIdentityUserAttributeType] = []
        let emailAttribute = AWSCognitoIdentityUserAttributeType()
        emailAttribute.name = "email"
        emailAttribute.value = email
        attributes.append(emailAttribute)
        let firstNameAttribute = AWSCognitoIdentityUserAttributeType()
        firstNameAttribute.name = "given_name"
        firstNameAttribute.value = firstName
        attributes.append(firstNameAttribute)
        let lastNameAttribute = AWSCognitoIdentityUserAttributeType()
        lastNameAttribute.name = "family_name"
        lastNameAttribute.value = lastName
        attributes.append(lastNameAttribute)
        
        AWSClientManager.defaultClientManager().userPool?.signUp(username, password: password, userAttributes: attributes, validationData: nil).continueWithBlock(completionHandler)
        
//        AWSClientManager.defaultClientManager().userPool?.signUp(username, password: password, userAttributes: attributes, validationData: nil).continueWithBlock({
//            (task: AWSTask) in
//            if let error = task.error {
//                print("signUpUserPool error:")
//                return AWSTask(error: error).continueWithBlock(completionHandler)
//            } else {
//                print("signUpUserPool success!")
//                // Proceed to logIn.
//                self.logInUserPool(username, password: password, completionHandler: completionHandler)
//                return nil
//            }
//        })
    }
    
    func signOutUserPool(completionHandler: AWSContinuationBlock) {
        print("signOutUserPool:")
        AWSClientManager.defaultClientManager().userPool?.currentUser()?.signOut()
        AWSTask(result: nil).continueWithBlock(completionHandler)
    }
    
    func getUserDetailsUserPool(completionHandler: AWSContinuationBlock) {
        print("getUserDetailsUserPool:")
        AWSClientManager.defaultClientManager().userPool?.currentUser()?.getDetails().continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("getUserDetailsUserPool error: \(error.localizedDescription)")
                return AWSTask(error: error).continueWithBlock(completionHandler)
            } else if let result = task.result as? AWSCognitoIdentityUserGetDetailsResponse {
                print("getUserDetailsUserPool success: \(result)")
                return AWSTask(result: result).continueWithBlock(completionHandler)
            } else {
                print("This should not happen with getUserDetailsUserPool.")
                return AWSTask(result: nil).continueWithBlock(completionHandler)
            }
        })
    }
    
    func updateFirstLastNameUserPool(firstName: String, lastName: String, completionHandler: AWSContinuationBlock) {
        print("updateFirstLastNameUserPool:")
        var attributes: [AWSCognitoIdentityUserAttributeType] = []
        let firstNameAttribute = AWSCognitoIdentityUserAttributeType()
        firstNameAttribute.name = "given_name"
        firstNameAttribute.value = firstName
        attributes.append(firstNameAttribute)
        let lastNameAttribute = AWSCognitoIdentityUserAttributeType()
        lastNameAttribute.name = "family_name"
        lastNameAttribute.value = lastName
        attributes.append(lastNameAttribute)
        
        AWSClientManager.defaultClientManager().userPool?.currentUser()?.updateAttributes(attributes).continueWithBlock(completionHandler)
        
//        AWSClientManager.defaultClientManager().userPool?.currentUser()?.updateAttributes(attributes).continueWithBlock({
//            (task: AWSTask) in
//            if let error = task.error {
//                print("updateFirstLastNameUserPool error:")
//                return AWSTask(error: error).continueWithBlock(completionHandler)
//            } else {
//                print("updateFirstLastNameUserPool success!")
//                return task.continueWithBlock(completionHandler)
//            }
//        })
    }
    
    func updatePreferredUsernameUserPool(preferredUsername: String, completionHandler: AWSContinuationBlock) {
        print("updatePreferredUsernameUserPool:")
        var attributes: [AWSCognitoIdentityUserAttributeType] = []
        let preferredUsernameAttribute = AWSCognitoIdentityUserAttributeType()
        preferredUsernameAttribute.name = "preferred_username"
        preferredUsernameAttribute.value = preferredUsername
        attributes.append(preferredUsernameAttribute)
        
        AWSClientManager.defaultClientManager().userPool?.currentUser()?.updateAttributes(attributes).continueWithBlock(completionHandler)
        
//        AWSClientManager.defaultClientManager().userPool?.currentUser()?.updateAttributes(attributes).continueWithBlock({
//            (task: AWSTask) in
//            if let error = task.error {
//                print("updatePreferredUsernameUserPool error:")
//                return AWSTask(error: error).continueWithBlock(completionHandler)
//            } else {
//                print("updatePreferredUsernameUserPool success!")
//                return task.continueWithBlock(completionHandler)
//            }
//        })
    }
}
