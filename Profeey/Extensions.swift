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
    
    func scale(width: CGFloat, height: CGFloat, scale: CGFloat) -> UIImage {
        let scaleRect = CGRectMake(0.0, 0.0, width, height)
        let newSize = CGSizeMake(width, height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        self.drawInRect(scaleRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func aspectRatio() -> CGFloat {
        return self.size.width / self.size.height
    }
    
    func crop(cropX: CGFloat, cropY: CGFloat, cropWidth: CGFloat, cropHeight: CGFloat) -> UIImage {
        let cropRect = CGRectMake(cropX, cropY, cropWidth, cropHeight)
        let cgiImage = self.CGImage
        if let imageRef = CGImageCreateWithImageInRect(cgiImage, cropRect) {
            return UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        } else {
            return self
        }
    }
}

extension UICollectionView {
    
    // Returns empty Array, rather than nil, when no elements in rect
    func indexPathsForElementsInRect(rect: CGRect) -> [NSIndexPath] {
        guard let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElementsInRect(rect) else {
            return []
        }
        var indexPaths: [NSIndexPath] = []
        for layoutAttributes in allLayoutAttributes {
            let indexPath = layoutAttributes.indexPath
            indexPaths.append(indexPath)
        }
        return indexPaths
    }
    
}

extension NSIndexSet {
    
    func indexPathsFromIndexesWithSection(section: Int) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        indexPaths.reserveCapacity(self.count)
        self.enumerateIndexesUsingBlock{idx, stop in
            indexPaths.append(NSIndexPath(forItem: idx, inSection: section))
        }
        return indexPaths
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
    
    func isEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }
    
    func isPassword() -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluateWithObject(self)
    }
}
