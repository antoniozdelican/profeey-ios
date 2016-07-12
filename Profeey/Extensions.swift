//
//  Extensions.swift
//  Profeey
//
//  Created by Antonio Zdelican on 03/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSMobileHubHelper

// MARK: - Extensions

extension UIViewController {
    func getSimpleAlertWithTitle(title: String, message: String?, cancelButtonTitle cancelTitle: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        return alertController
    }
}

extension UIImage {
    func scale(width: CGFloat, height: CGFloat) -> UIImage {
        let scaleRect = CGRectMake(0.0, 0.0, width, height)
        let newSize = CGSizeMake(width, height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.drawInRect(scaleRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension AWSContent {
    func isAudioVideo() -> Bool {
        let lowerCaseKey = self.key.lowercaseString
        return lowerCaseKey.hasSuffix(".mov")
            || lowerCaseKey.hasSuffix(".mp4")
            || lowerCaseKey.hasSuffix(".mpv")
            || lowerCaseKey.hasSuffix(".3gp")
            || lowerCaseKey.hasSuffix(".mpeg")
            || lowerCaseKey.hasSuffix(".aac")
            || lowerCaseKey.hasSuffix(".mp3")
    }
    
    func isImage() -> Bool {
        let lowerCaseKey = self.key.lowercaseString
        return lowerCaseKey.hasSuffix(".jpg")
            || lowerCaseKey.hasSuffix(".png")
            || lowerCaseKey.hasSuffix(".jpeg")
    }
}

extension UInt {
    func aws_stringFromByteCount() -> String {
        if self < 1024 {
            return "\(self) B"
        }
        if self < 1024 * 1024 {
            return "\(self / 1024) KB"
        }
        if self < 1024 * 1024 * 1024 {
            return "\(self / 1024 / 1024) MB"
        }
        return "\(self / 1024 / 1024 / 1024) GB"
    }
}

extension String {
    func getLastPathComponent() -> String {
        let nsstringValue: NSString = self
        return nsstringValue.lastPathComponent
    }
    
    func trimm() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}
