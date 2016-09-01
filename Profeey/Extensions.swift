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

extension Int {
    func numberToString() -> String {
        if self > 999 && self <= 999999 {
            let thousands = self / 1000
            let hundreds = self % 1000 / 100
            return hundreds > 0 ? "\(thousands).\(hundreds)k" : "\(thousands)k"
        }
        if self > 999999 {
            let millions = self / 100000
            let hundredThousands = self % 100000 / 10000
            return hundredThousands > 0 ? "\(millions).\(hundredThousands)m" : "\(millions)m"
        }
        return "\(self)"
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

extension NSDate {
    func yearsFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    
    func monthsFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    
    func weeksFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    
    func daysFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    
    func hoursFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    
    func minutesFrom(date: NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    
    func secondsFrom(date: NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    
    // Calculate currentDate distance from creationDate for example.
    // currentDate.offsetFrom(creationDate)
    func offsetFrom(date: NSDate) -> String {
        if yearsFrom(date)   > 0 {
            return yearsFrom(date) > 1 ? "\(yearsFrom(date)) years ago" : "\(yearsFrom(date)) year ago"
        }
        if monthsFrom(date)  > 0 {
            return monthsFrom(date) > 1 ? "\(monthsFrom(date)) months ago" : "\(monthsFrom(date)) month ago"
        }
        if weeksFrom(date)   > 0 {
            return weeksFrom(date) > 1 ? "\(weeksFrom(date)) weeks ago" : "\(weeksFrom(date)) week ago"
        }
        if daysFrom(date)    > 0 {
            return daysFrom(date) > 1 ? "\(daysFrom(date)) days ago" : "\(daysFrom(date)) day ago"
        }
        if hoursFrom(date)   > 0 {
            return hoursFrom(date) > 1 ? "\(hoursFrom(date)) hours ago" : "\(hoursFrom(date)) hour ago"
        }
        if minutesFrom(date) > 0 {
            return minutesFrom(date) > 1 ? "\(minutesFrom(date)) minutes ago" : "\(minutesFrom(date)) minute ago"
        }
        if secondsFrom(date) > 0 {
            return secondsFrom(date) > 1 ? "\(secondsFrom(date)) seconds ago" : "\(secondsFrom(date)) second ago"
        }
        return "Now"
    }
}
