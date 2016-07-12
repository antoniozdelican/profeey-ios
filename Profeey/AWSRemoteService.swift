//
//  AWSRemoteService.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSCognito
import AWSCognitoIdentityProvider
import AWSDynamoDB
import AWSMobileHubHelper

class AWSRemoteService: NSObject {
    
    private static var sharedInstance: AWSRemoteService!
    
    // Properties
    private var credentialsProvider: AWSCognitoCredentialsProvider!
    var userPool: AWSCognitoIdentityUserPool!
    
    var identityId: String! {
        get {
            // THIS MIGHT FAIL!!
            return self.credentialsProvider.identityId!
            //return AWSIdentityManager.defaultIdentityManager().identityId!
        }
    }
    
    private var usersTable: AWSUsersTable!
    private var professionsTable: AWSProfessionsTable!
    
    static func defaultRemoteService() -> AWSRemoteService {
        if sharedInstance == nil {
            sharedInstance = AWSRemoteService()
            sharedInstance.configure()
        }
        return sharedInstance
    }
    
    // MARK: Configure
    
    private func configure() {
        // Setup logging.
        AWSLogger.defaultLogger().logLevel = AWSLogLevel.Verbose
        // Service.
        let serviceConfiguration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: nil)
        // Pool.
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: AWSConstants.COGNITO_USER_POOL_CLIENT_ID, clientSecret: AWSConstants.COGNITO_USER_POOL_CLIENT_SECRET, poolId: AWSConstants.COGNITO_USER_POOL_ID)
        AWSCognitoIdentityUserPool.registerCognitoIdentityUserPoolWithConfiguration(serviceConfiguration, userPoolConfiguration: userPoolConfiguration, forKey: "UserPool")
        self.userPool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        // Credentials provider.
        self.credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSConstants.COGNITO_REGIONTYPE, identityPoolId: AWSConstants.COGNITO_IDENTITY_POOL_ID, identityProviderManager: self.userPool)

        // Default service.
        let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSConstants.COGNITO_REGIONTYPE, credentialsProvider: self.credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
        
        // THIS IS A PROBLEM I THINK!!
        // AWSIdentityManager.defaultIdentityManager()
        
        //Clear keychain on first run in case of reinstallation.
        self.clearKeychain()
        
        self.usersTable = AWSUsersTable()
        self.professionsTable = AWSProfessionsTable()
    }
    
    private func clearKeychain() {
        if NSUserDefaults.standardUserDefaults().boolForKey("hasRunBefore") == false {
            print("Delete values from keychain.")
            if let currentUser = self.userPool.currentUser() {
                currentUser.signOut()
            }
            //self.credentialsProvider.clearKeychain()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasRunBefore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func setUserDetails() {
        if let currentUser = self.userPool.currentUser() {
            print("Setting user details:")
            currentUser.getDetails().continueWithSuccessBlock({
                (task: AWSTask) in
                return nil
            })
        }
    }
    
    // MARK: Cognito
    
    func resumeSession(completionHandler: AWSContinuationBlock) {
        print("ResumeSession:")
        if let currentUser = self.userPool.currentUser() where currentUser.signedIn {
            self.credentialsProvider.getIdentityId().continueWithBlock({
                (task: AWSTask) in
                print("GetIdentityId:")
                if let error = task.error {
                    print("IdentityId error:")
                    AWSTask(error: error).continueWithBlock(completionHandler)
                }
                return self.credentialsProvider.credentials()
            }).continueWithBlock({
                (task: AWSTask) in
                print("Credentials:")
                if let error = task.error {
                    print("Credentials error:")
                    AWSTask(error: error).continueWithBlock(completionHandler)
                }
                return task
            }).continueWithBlock(completionHandler)
        }
    }
    
    func logIn(username: String, password: String, completionHandler: AWSContinuationBlock) {
        print("LogIn:")
        let user = self.userPool.getUser()
        user.getSession(username, password: password, validationData: nil, scopes: nil).continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("GetSession error:")
                AWSTask(error: error).continueWithBlock(completionHandler)
            }
            self.resumeSession(completionHandler)
            return nil
        })
    }
    
    func signUp(username: String, password: String, email: String, completionHandler: AWSContinuationBlock) {
        print("SignUp:")
        var attributes: [AWSCognitoIdentityUserAttributeType] = []
        let emailAttribute = AWSCognitoIdentityUserAttributeType()
        emailAttribute.name = "email"
        emailAttribute.value = email
        attributes.append(emailAttribute)
        
        self.userPool.signUp(username, password: password, userAttributes: attributes, validationData: nil).continueWithBlock({
            (task: AWSTask) in
            if let error = task.error {
                print("SignUp error:")
                // Return to caller with error.
                AWSTask(error: error).continueWithBlock(completionHandler)
            }
            // Proceed to log in.
            self.logIn(username, password: password, completionHandler: completionHandler)
            return nil
        })
    }
    
    func signOut() {
        print("SignOut:")
        if let currentUser = self.userPool.currentUser() {
            currentUser.signOut()
            //self.credentialsProvider.clearKeychain()
            self.userPool.clearAll()
        }
        self.setUserDetails()
    }
    
    func setFullName(fullName: String?, completionHandler: AWSContinuationBlock) {
        var attributes: [AWSCognitoIdentityUserAttributeType] = []
        let fullNameAttribute = AWSCognitoIdentityUserAttributeType()
        fullNameAttribute.name = "name"
        fullNameAttribute.value = fullName
        attributes.append(fullNameAttribute)
        if let currentUser = self.userPool.currentUser() {
            currentUser.updateAttributes(attributes).continueWithBlock({
                (task: AWSTask) in
                if let error = task.error {
                    print("Set fullName error:")
                    AWSTask(error: error).continueWithBlock(completionHandler)
                } else {
                    // Save to DynamoDB.
                    self.saveUserFullName(fullName, completionHandler: completionHandler)
                }
                return nil
            })
        }
    }
    
    func setPreferredUsername(preferredUsername: String?, completionHandler: AWSContinuationBlock) {
        var attributes: [AWSCognitoIdentityUserAttributeType] = []
        let preferredUsernameAttribute = AWSCognitoIdentityUserAttributeType()
        preferredUsernameAttribute.name = "preferred_username"
        preferredUsernameAttribute.value = preferredUsername
        attributes.append(preferredUsernameAttribute)
        if let currentUser = self.userPool.currentUser() {
            currentUser.updateAttributes(attributes).continueWithBlock({
                (task: AWSTask) in
                if let error = task.error {
                    print("Set preferredUsername error:")
                    AWSTask(error: error).continueWithBlock(completionHandler)
                } else {
                    // Save to DynamoDB.
                    self.saveUserPreferredUsername(preferredUsername, completionHandler: completionHandler)
                }
                return nil
            })
        }
    }

    
    // MARK: DynamoDB - Users
    
    // Private functions are called after Cognito tasks.
    
    private func saveUserFullName(fullName: String?, completionHandler: AWSContinuationBlock) {
        let user = AWSUserFullName()
        user._userId = self.identityId
        user._fullName = fullName
        self.usersTable.saveUserFullName(user, completionHandler: completionHandler)
    }
    
    private func saveUserPreferredUsername(preferredUsername: String?, completionHandler: AWSContinuationBlock) {
        let user = AWSUserPreferredUsername()
        user._userId = self.identityId
        user._preferredUsername = preferredUsername
        self.usersTable.saveUserPreferredUsername(user, completionHandler: completionHandler)
    }
    
    func saveUserAbout(about: String?, completionHandler: AWSContinuationBlock) {
        let user = AWSUserAbout()
        user._userId = self.identityId
        user._about = about
        self.usersTable.saveUserAbout(user, completionHandler: completionHandler)
    }
    
    func saveUserProfessions(professions: [String]?, completionHandler: AWSContinuationBlock) {
        let user = AWSUserProfessions()
        user._userId = self.identityId
        user._professions = professions
        self.usersTable.saveUserProfessions(user, completionHandler: completionHandler)
    }
    
    private func saveUserProfilePic(profilePicUrl: String?, oldProfilePicUrl: String?, imageData: NSData?, completionHandler: AWSContinuationBlock) {
        let user = AWSUserProfilePic()
        user._userId = self.identityId
        user._profilePicUrl = profilePicUrl
        self.usersTable.saveUserProfilePic(user, completionHandler: {
            (task: AWSTask) in
            if let error = task.error {
                print("ProfilePic DynamoDB error:")
                AWSTask(error: error).continueWithBlock(completionHandler)
            } else {
                print("Uploaded user profilePic on DynamoDB.")
                AWSTask(result: imageData).continueWithBlock(completionHandler)
                
                // Async remove profilePic from S3
                if let oldProfilePicUrl = oldProfilePicUrl {
                    self.deleteProfilePic(oldProfilePicUrl, completionHandler: nil)
                }
            }
            return nil
        })
    }
    
    func getUser(completionHandler: (response: AWSDynamoDBObjectModel?, error: NSError?) -> Void) {
        self.usersTable.getUser(completionHandler)
    }
    
    // MARK: DynamoDB - Professions
    
    func scanProfessions(professionsName: String, completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        self.professionsTable.scanProfessions(professionsName, completionHandler: completionHandler)
    }
    
    // MARK: S3
    
    func saveProfilePic(profilePic: UIImage, oldImageKey: String?, progressBlock: ((AWSLocalContent, NSProgress) -> Void)?, completionHandler: AWSContinuationBlock) {
        let profilePicWidth: CGFloat = 400.0
        let profilePicHeight: CGFloat = 400.0
        let prefix = "public/"
        let scaledImage = profilePic.scale(profilePicWidth, height: profilePicHeight)
        let imageData = UIImageJPEGRepresentation(scaledImage, 0.6)!
        let uniqueImageName = NSUUID().UUIDString.lowercaseString.stringByReplacingOccurrencesOfString("-", withString: "")
        // Set key (path in S3 bucket) as public/{uniqueImageName}_400x400.jpg
        let imageKey = "\(prefix)\(uniqueImageName)_\(Int(profilePicWidth))x\(Int(profilePicHeight)).jpg"
        
        let localContent: AWSLocalContent = AWSUserFileManager.defaultUserFileManager().localContentWithData(imageData, key: imageKey)
        localContent.uploadWithPinOnCompletion(
            false,
            progressBlock: progressBlock,
            completionHandler: {
                (content: AWSLocalContent?, error: NSError?) -> Void in
                if let error = error {
                    print("ProfilePic S3 error:")
                    AWSTask(error: error).continueWithBlock(completionHandler)
                } else {
                    print("Uploaded user profilePic on S3.")
                    // Save profilePic on DynamoDB
                    self.saveUserProfilePic(imageKey, oldProfilePicUrl: oldImageKey, imageData: imageData, completionHandler: completionHandler)
                }
        })
    }
    
    func downloadProfilePic(imageKey: String, progressBlock: ((AWSContent, NSProgress) -> Void)?, completionHandler: AWSContinuationBlock) {
        let content: AWSContent = AWSUserFileManager.defaultUserFileManager().contentWithKey(imageKey)
        content.downloadWithDownloadType(
            .IfNewerExists,
            pinOnCompletion: false,
            progressBlock: progressBlock,
            completionHandler: {
                (content: AWSContent?, data: NSData?, error: NSError?) -> Void in
                if let error = error {
                    print("ProfilePic S3 error:")
                    AWSTask(error: error).continueWithBlock(completionHandler)
                } else {
                    print("Downloaded user profilePic from S3.")
                    AWSTask(result: data).continueWithBlock(completionHandler)
                }
        })
        
    }
    
    func deleteProfilePic(imageKey: String, completionHandler: AWSContinuationBlock?) {
        let content = AWSUserFileManager.defaultUserFileManager().contentWithKey(imageKey)
        content.removeRemoteContentWithCompletionHandler({
            (content: AWSContent?, error: NSError?) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                if let completionHandler = completionHandler {
                    AWSTask(error: error).continueWithBlock(completionHandler)
                }
            } else {
                print("Deleted user profilePic from S3.")
                if let completionHandler = completionHandler {
                    AWSTask(result: nil).continueWithBlock(completionHandler)
                }
            }
        })
    }
}