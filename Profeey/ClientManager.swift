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
    
    // MARK: User
    
    func signOut(_ completionHandler: @escaping AWSContinuationBlock)
    
    func getUserDetails(_ completionHandler: @escaping (AWSTask<AWSCognitoIdentityUserGetDetailsResponse>) -> Any?)
    func getUser(_ userId: String, completionHandler: @escaping AWSContinuationBlock)
}
