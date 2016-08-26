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
    
    func logIn(username: String, password: String, completionHandler: AWSContinuationBlock)
    func signUp(username: String, password: String, email: String, firstName: String?, lastName: String?, completionHandler: AWSContinuationBlock)
    func signOut(completionHandler: AWSContinuationBlock)
    
    func getUserDetails(completionHandler: AWSContinuationBlock)
    func getUser(userId: String, completionHandler: AWSContinuationBlock)
    func getCurrentUser(completionHandler: AWSContinuationBlock)
    
    func updateFirstLastName(firstName: String?, lastName: String?, completionHandler: AWSContinuationBlock)
    func updatePreferredUsername(preferredUsername: String, completionHandler: AWSContinuationBlock)
    func updateUserProfession(profession: String?, completionHandler: AWSContinuationBlock)
    func updateUserLocation(location: String?, completionHandler: AWSContinuationBlock)
    func updateUserAbout(about: String?, completionHandler: AWSContinuationBlock)
    func updateProfilePic(profilePicUrl: String?, completionHandler: AWSContinuationBlock)
    
    func scanUsers(completionHandler: AWSContinuationBlock)
    
    // MARK: UserRelationships
    
    func getUserRelationship(followedId: String, completionHandler: AWSContinuationBlock)
    func saveUserRelationship(followedId: String, completionHandler: AWSContinuationBlock)
    func removeUserRelationship(followedId: String, completionHandler: AWSContinuationBlock)
    func queryUserFollowed(userId: String, completionHandler: AWSContinuationBlock)
    
    // MARK: Posts
    
    func queryUserPosts(userId: String, completionHandler: AWSContinuationBlock)
    func savePost(imageData: NSData, title: String?, description: String?, category: String?, user: User?, isProfilePic: Bool, completionHandler: AWSContinuationBlock)
    
    // MARK: S3
    func downloadImage(imageKey: String, completionHandler: AWSContinuationBlock)
    
    func deleteImageS3(imageKey: String, completionHandler: AWSContinuationBlock)
}