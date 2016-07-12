//
//  ProfilePicUploader.swift
//  Profeey
//
//  Created by Antonio Zdelican on 03/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

protocol ProfilePicUploaderDelegate {
    func uploadFinished(profilePicUrl: String)
    func deleteFinished()
}

class ProfilePicUploader: NSObject {
    
    var user: User
    
    var delegate: ProfilePicUploaderDelegate!
    
    private var manager: AWSUserFileManager!
    private var prefix = "public/"
    private var maxCacheSize: Int = 1 // maxCacheSize in MB
    private var profilePicWidth: CGFloat = 400.0
    private var profilePicHeight: CGFloat = 400.0
    
    init(user: User) {
        
        self.user = user
        self.manager = AWSUserFileManager.defaultUserFileManager()
        self.manager.maxCacheSize = UInt(maxCacheSize) * 1024 * 1024
        
        manager.listAvailableContentsWithPrefix(prefix, marker: nil, completionHandler: {
            (contents: [AWSContent]?, nextMarker: String?, error: NSError?) -> Void in
            if let error = error {
                print(error)
            } else if let contents = contents {
                print(contents.count)
            }
        
        })
    }
    
    // MARK: AWS
    
    func uploadProfilePic(profilePic: UIImage) {
        let scaledImage = scaleImage(profilePic, width: profilePicWidth, height: profilePicHeight)
        let imageData = UIImageJPEGRepresentation(scaledImage, 0.6)!
        let imageKey = self.getImageKey()
        
        self.uploadImage(imageData, forKey: imageKey)
    }
    
    // MARK: 1. Prepare
    
    private func scaleImage(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        let scaleRect = CGRectMake(0.0, 0.0, width, height)
        let newSize = CGSizeMake(width, height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(scaleRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    private func getImageKey() -> String {
        let uniqueImageName = NSUUID().UUIDString.lowercaseString.stringByReplacingOccurrencesOfString("-", withString: "")
        // Set key (path in S3 bucket) as public/{uniqueImageName}_400x400.jpg
        let imageKey = "\(self.prefix)\(uniqueImageName)_\(Int(profilePicWidth))x\(Int(profilePicHeight)).jpg"
        return imageKey
    }
    
    // MARK: 2. upload to S3
    
    private func uploadImage(imageData: NSData, forKey key: String) {
        print("uploadImage:")
        let localContent: AWSLocalContent = self.manager.localContentWithData(imageData, key: key)
        localContent.uploadWithPinOnCompletion(
            false,
            progressBlock: {
                [weak self](content: AWSLocalContent?, progress: NSProgress?) -> Void in
                // TODO
                return
            },
            completionHandler: {
                [weak self](content: AWSContent?, error: NSError?) -> Void in
                guard let strongSelf = self else {
                    return
                }
                if let error = error {
                    print("S3 error: \(error.localizedDescription)")
                } else {
                    print("Uploaded user profilePic.")
                    strongSelf.updateUser(key)
                }
            })
    }
    
    // MARK: 3. update DynamoDB
    
    private func updateUser(profilePicUrl: String?) {
        print("updateUser:")
        let usersTable = AWSUsersTable()
        //self.user._userId = AWSIdentityManager.defaultIdentityManager.identityId!
        //self.user._profilePicUrl = profilePicUrl
//        usersTable.updateUserWithDeletion(user, completionHandler: {
//            (error: NSError?) -> Void in
//            if let error = error {
//                var errorMessage = error.localizedDescription
//                if (error.domain == AWSServiceErrorDomain && error.code == AWSServiceErrorType.AccessDeniedException.rawValue) {
//                    errorMessage = "Access denied. You are not allowed to update this item."
//                }
//                print("DynamoDB error: \(errorMessage)")
//                return
//            } else {
//                print("Updated user profilePicUrl.")
//                // Notifiy delegate.
//                if let profilePicUrl = profilePicUrl {
//                    self.delegate.uploadFinished(profilePicUrl)
//                }
//            }
//        })
    }
    
    // MARK: 4. delete from S3 (old profilePic)
    
    func deleteProfilePic(profilePicUrl: String?) {
        self.updateUser(nil)
//        let content: AWSContent = self.manager.contentWithKey(profilePicUrl)
//        content.removeRemoteContentWithCompletionHandler({
//            [weak self](content: AWSContent?, error: NSError?) -> Void in
//            guard let strongSelf = self else {
//                return
//            }
//            if let error = error {
//                print("DynamoDB error: \(error.localizedDescription)")
//                return
//            } else {
//                print("Deleted user profilePic.")
//                strongSelf.updateUser(nil)
//                strongSelf.refreshContents()
//            }
//        })
    }
    // TODO
}