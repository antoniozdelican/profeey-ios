//
//  S3Manager.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSMobileHubHelper

protocol S3Manager {
    
    func uploadImageS3(imageData: NSData, isProfilePic: Bool, progressBlock: ((AWSLocalContent, NSProgress) -> Void)?, completionHandler: AWSContinuationBlock)
    func downloadImageS3(imageKey: String, progressBlock: ((AWSContent, NSProgress) -> Void)?, completionHandler: AWSContinuationBlock)
    func deleteImageS3(imageKey: String, completionHandler: AWSContinuationBlock)
}