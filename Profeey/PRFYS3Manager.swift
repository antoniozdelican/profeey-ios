//
//  PRFYS3Manager.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSMobileHubHelper

class PRFYS3Manager: NSObject, S3Manager {
    
    private static var sharedInstance: PRFYS3Manager!
    
    // Properties.
    private let PROFILE_PIC_PREFIX: String = "public/profile_pics/"
    private let IMAGE_PREFIX: String = "public/"
    
    static func defaultDynamoDBManager() -> PRFYS3Manager {
        if sharedInstance == nil {
            sharedInstance = PRFYS3Manager()
        }
        return sharedInstance
    }
    
    func uploadImageS3(imageData: NSData, isProfilePic: Bool, progressBlock: ((AWSLocalContent, NSProgress) -> Void)?, completionHandler: AWSContinuationBlock) {
        print("uploadImageS3:")
        let uniqueImageName = NSUUID().UUIDString.lowercaseString.stringByReplacingOccurrencesOfString("-", withString: "")
        let imageKey = isProfilePic ? "\(self.PROFILE_PIC_PREFIX)\(uniqueImageName).jpg" : "\(self.IMAGE_PREFIX)\(uniqueImageName).jpg"
        let localContent = AWSClientManager.defaultClientManager().userFileManager?.localContentWithData(imageData, key: imageKey)
        
        localContent?.uploadWithPinOnCompletion(
            false,
            progressBlock: progressBlock,
            completionHandler: {
                (content: AWSLocalContent?, error: NSError?) -> Void in
                if let error = error {
                    print("uploadImageS3 error:")
                    AWSTask(error: error).continueWithBlock(completionHandler)
                } else {
                    print("uploadImageS3 success!")
                    AWSTask(result: imageKey).continueWithBlock(completionHandler)
                }
        })
    }
    
    func downloadImageS3(imageKey: String, progressBlock: ((AWSContent, NSProgress) -> Void)?, completionHandler: AWSContinuationBlock) {
        print("downloadImageS3:")
        let content = AWSClientManager.defaultClientManager().userFileManager?.contentWithKey(imageKey)
        
        content?.downloadWithDownloadType(
            AWSContentDownloadType.IfNewerExists,
            pinOnCompletion: false,
            progressBlock: progressBlock,
            completionHandler: {
                (content: AWSContent?, data: NSData?, error: NSError?) in
                if let error = error {
                    print("downloadImageS3 error:")
                    AWSTask(error: error).continueWithBlock(completionHandler)
                } else {
                    print("downloadImageS3 success!")
                    AWSTask(result: data).continueWithBlock(completionHandler)
                }
        })
    }
    
    func deleteImageS3(imageKey: String, completionHandler: AWSContinuationBlock) {
        
    }
}
