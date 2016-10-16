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
import AWSDynamoDB

typealias AWSContinuationBlock = (AWSTask<AnyObject>) -> Any?
typealias AWSDynamoDBContinuationBlock = (AWSTask<AWSDynamoDBPaginatedOutput>) -> Any?

protocol ClientManager {
    
    var credentialsProvider: AWSCognitoCredentialsProvider? { get }
    var userPool: AWSCognitoIdentityUserPool? { get }
    var userFileManager: AWSUserFileManager? { get }
    
    // MARK: UserPool
    
    func logIn(_ username: String, password: String, completionHandler: @escaping (AWSTask<AWSCognitoIdentityUserSession>) -> Any?)
    func signUp(_ username: String, password: String, email: String, firstName: String, lastName: String, completionHandler: @escaping (AWSTask<AWSCognitoIdentityUserPoolSignUpResponse>) -> Any?)
    func signOut(_ completionHandler: @escaping AWSContinuationBlock)
    
    func getUserDetails(_ completionHandler: @escaping (AWSTask<AWSCognitoIdentityUserGetDetailsResponse>) -> Any?)
    func updatePreferredUsername(_ preferredUsername: String, completionHandler: @escaping (AWSTask<AWSCognitoIdentityUserUpdateAttributesResponse>) -> Any?)
}
