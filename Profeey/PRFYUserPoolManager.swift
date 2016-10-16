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
    
    fileprivate static var sharedInstance: PRFYUserPoolManager!
    static func defaultUserPoolManager() -> PRFYUserPoolManager {
        if sharedInstance == nil {
            sharedInstance = PRFYUserPoolManager()
        }
        return sharedInstance
    }
    
//    func logInUserPool(_ username: String, password: String, completionHandler: @escaping (AWSTask<AWSCognitoIdentityUserSession>) -> Any?) {
//        print("logInUserPool:")
//        let user = AWSClientManager.defaultClientManager().userPool?.getUser()
//        user?.getSession(username, password: password, validationData: nil).continue(completionHandler)
//    }
//    
//    func signUpUserPool(_ username: String, password: String, email: String, firstName: String, lastName: String, completionHandler: @escaping (AWSTask<AWSCognitoIdentityUserPoolSignUpResponse>) -> Any?) {
//        print("signUpUserPool:")
//        var attributes: [AWSCognitoIdentityUserAttributeType] = []
//        let emailAttribute = AWSCognitoIdentityUserAttributeType()
//        emailAttribute?.name = "email"
//        emailAttribute?.value = email
//        attributes.append(emailAttribute!)
//        let firstNameAttribute = AWSCognitoIdentityUserAttributeType()
//        firstNameAttribute?.name = "given_name"
//        firstNameAttribute?.value = firstName
//        attributes.append(firstNameAttribute!)
//        let lastNameAttribute = AWSCognitoIdentityUserAttributeType()
//        lastNameAttribute?.name = "family_name"
//        lastNameAttribute?.value = lastName
//        attributes.append(lastNameAttribute!)
//        AWSClientManager.defaultClientManager().userPool?.signUp(username, password: password, userAttributes: attributes, validationData: nil).continue(completionHandler)
//    }
//    
//    func signOutUserPool(_ completionHandler: @escaping AWSContinuationBlock) {
//        print("signOutUserPool:")
//        AWSClientManager.defaultClientManager().userPool?.currentUser()?.signOut()
//        AWSTask(result: nil).continue(completionHandler)
//    }
//    
//    func getUserDetailsUserPool(_ completionHandler: @escaping (AWSTask<AWSCognitoIdentityUserGetDetailsResponse>) -> Any?) {
//        print("getUserDetailsUserPool:")
//        AWSClientManager.defaultClientManager().userPool?.currentUser()?.getDetails().continue(completionHandler)
//    }
//    
////    func updateFirstLastNameUserPool(_ firstName: String, lastName: String, completionHandler: @escaping (AWSTask<AWSCognitoIdentityUserUpdateAttributesResponse>) -> Any?) {
////        print("updateFirstLastNameUserPool:")
////        var attributes: [AWSCognitoIdentityUserAttributeType] = []
////        let firstNameAttribute = AWSCognitoIdentityUserAttributeType()
////        firstNameAttribute?.name = "given_name"
////        firstNameAttribute?.value = firstName
////        attributes.append(firstNameAttribute!)
////        let lastNameAttribute = AWSCognitoIdentityUserAttributeType()
////        lastNameAttribute?.name = "family_name"
////        lastNameAttribute?.value = lastName
////        attributes.append(lastNameAttribute!)
////        
////        AWSClientManager.defaultClientManager().userPool?.currentUser()?.update(attributes).continue(completionHandler)
////
////    }
//    
//    func updatePreferredUsernameUserPool(_ preferredUsername: String, completionHandler: @escaping (AWSTask<AWSCognitoIdentityUserUpdateAttributesResponse>) -> Any?) {
//        print("updatePreferredUsernameUserPool:")
//        var attributes: [AWSCognitoIdentityUserAttributeType] = []
//        let preferredUsernameAttribute = AWSCognitoIdentityUserAttributeType()
//        preferredUsernameAttribute?.name = "preferred_username"
//        preferredUsernameAttribute?.value = preferredUsername
//        attributes.append(preferredUsernameAttribute!)
//        
//        AWSClientManager.defaultClientManager().userPool?.currentUser()?.update(attributes).continue(completionHandler)
//    }
}
