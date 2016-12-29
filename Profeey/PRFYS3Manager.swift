//
//  PRFYS3Manager.swift
//  Profeey
//
//  Created by Antonio Zdelican on 29/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSMobileHubHelper

class PRFYS3Manager: NSObject, S3Manager {
    
    fileprivate static var sharedInstance: PRFYS3Manager!
    
    static func defaultS3Manager() -> PRFYS3Manager {
        if sharedInstance == nil {
            sharedInstance = PRFYS3Manager()
        }
        return sharedInstance
    }
    
    // MARK: Download
    
    func downloadImageS3(_ imageKey: String, imageType: ImageType) {
        let content = AWSUserFileManager.defaultUserFileManager().content(withKey: imageKey)
        guard content.isImage() else {
            print("downloadImageS3 error: Content with imageKey \(imageKey) is not an image.")
            return
        }
        guard !content.isCached else {
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: DownloadImageNotificationKey), object: self, userInfo: ["imageKey": imageKey, "imageType": imageType, "imageData": content.cachedData])
            })
            return
        }
        guard content.status != AWSContentStatusType.running else {
            print("Content is downloading.")
            return
        }
        
        print("downloadImageS3:")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        content.download(
            with: AWSContentDownloadType.ifNewerExists,
            pinOnCompletion: false,
            progressBlock: {
                (content: AWSContent?, progress: Progress?) -> Void in
                DispatchQueue.main.async(execute: {
                    guard let _ = progress else {
                        return
                    }
                    // TODO
                })
        },
            completionHandler: {
                (content: AWSContent?, data: Data?, error:  Error?) in
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let error = error {
                        print("downloadImageS3 error: \(error)")
                    } else {
                        guard let imageData = data else {
                            print("downloadImageS3 error: No image data.")
                            return
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DownloadImageNotificationKey), object: self, userInfo: ["imageKey": imageKey, "imageType": imageType, "imageData": imageData])
                    }
                })
        })
    }
}
