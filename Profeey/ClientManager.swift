//
//  ClientManager.swift
//  Profeey
//
//  Created by Antonio Zdelican on 20/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSCognitoIdentityProvider

protocol ClientManager {
    
    var credentialsProvider: AWSCognitoCredentialsProvider? { get }
    var userPool: AWSCognitoIdentityUserPool? { get }
    var userFileManager: AWSUserFileManager? { get }
    
    // MARK: User
    
    func signOut(completionHandler: AWSContinuationBlock)
    
    func getUserDetails(completionHandler: AWSContinuationBlock)
    func getUser(userId: String, completionHandler: AWSContinuationBlock)
}