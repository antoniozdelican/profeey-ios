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
//    var contentManager: AWSContentManager? { get }
    var userFileManager: AWSUserFileManager? { get }
    var currentUser: User? { get }
    
    // MARK: UserPool
    
    func logIn(username: String, password: String, completionHandler: AWSContinuationBlock)
    func signUp(username: String, password: String, email: String, completionHandler: AWSContinuationBlock)
    func signOut(completionHandler: AWSContinuationBlock)
    func getCurrentUser(completionHandler: AWSContinuationBlock)
    func updateFirstLastName(firstName: String?, lastName: String?, completionHandler: AWSContinuationBlock)
    func updatePreferredUsername(preferredUsername: String, completionHandler: AWSContinuationBlock)
    func updateProfilePic(profilePicUrl: String?, completionHandler: AWSContinuationBlock)
    
    // MARK: DynamoDB
    func getCurrentUserDynamoDB(completionHandler: AWSContinuationBlock)
    func updateFirstLastNameDynamoDB(firstName: String?, lastName: String?, completionHandler: AWSContinuationBlock)
    func updatePreferredUsernameDynamoDB(preferredUsername: String?, completionHandler: AWSContinuationBlock)
    func updateUserProfessionsDynamoDB(professions: [String]?, completionHandler: AWSContinuationBlock)
    
    func updateProfessionsDynamoDB(professions: [String])
    
    func updateProfilePicDynamoDB(profilePicUrl: String?, completionHandler: AWSContinuationBlock)
    
    // MARK: S3
    func uploadImageS3(imageData: NSData, isProfilePic: Bool, progressBlock: ((AWSLocalContent, NSProgress) -> Void)?, completionHandler: AWSContinuationBlock)
    func deleteImageS3(imageKey: String, completionHandler: AWSContinuationBlock)
}