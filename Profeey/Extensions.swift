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
    
    func getSimpleAlertWithTitle(_ title: String, message: String?, cancelButtonTitle cancelTitle: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        return alertController
    }
}

extension UIImage {
    
    func scale(_ width: CGFloat, height: CGFloat, scale: CGFloat) -> UIImage {
        let scaleRect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        let newSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        self.draw(in: scaleRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func aspectRatio() -> CGFloat {
        return self.size.width / self.size.height
    }
    
    func crop(_ cropX: CGFloat, cropY: CGFloat, cropWidth: CGFloat, cropHeight: CGFloat) -> UIImage {
        let cropRect = CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
        let cgiImage = self.cgImage
        if let imageRef = cgiImage?.cropping(to: cropRect) {
            return UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        } else {
            return self
        }
    }
}

extension UICollectionView {
    
    // Returns empty Array, rather than nil, when no elements in rect
    func indexPathsForElementsInRect(_ rect: CGRect) -> [IndexPath] {
        guard let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElements(in: rect) else {
            return []
        }
        var indexPaths: [IndexPath] = []
        for layoutAttributes in allLayoutAttributes {
            let indexPath = layoutAttributes.indexPath
            indexPaths.append(indexPath)
        }
        return indexPaths
    }
    
}

extension UITableView {
    func indexPathForView(view: UIView) -> IndexPath? {
        let location = view.convert(CGPoint.zero, to: self)
        return indexPathForRow(at: location)
    }
    
    func reloadVisibleRow(_ indexPath: IndexPath) {
        guard let indexPathsForVisibleRows = self.indexPathsForVisibleRows, indexPathsForVisibleRows.contains(where: { $0 == indexPath }) else {
            return
        }
        UIView.performWithoutAnimation {
            self.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        }
    }
}

extension IndexSet {
    
    func indexPathsFromIndexesWithSection(_ section: Int) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        indexPaths.reserveCapacity(self.count)
        for (idx, _) in self.enumerated() {
            indexPaths.append(IndexPath(item: idx, section: section))
        }
//        (self as NSIndexSet).enumerate{idx, stop in
//            indexPaths.append(IndexPath(item: idx, section: section))
//        }
        return indexPaths
    }
    
}

extension AWSContent {
    func isAudioVideo() -> Bool {
        let lowerCaseKey = self.key.lowercased()
        return lowerCaseKey.hasSuffix(".mov")
            || lowerCaseKey.hasSuffix(".mp4")
            || lowerCaseKey.hasSuffix(".mpv")
            || lowerCaseKey.hasSuffix(".3gp")
            || lowerCaseKey.hasSuffix(".mpeg")
            || lowerCaseKey.hasSuffix(".aac")
            || lowerCaseKey.hasSuffix(".mp3")
    }
    
    func isImage() -> Bool {
        let lowerCaseKey = self.key.lowercased()
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
    
    func numberToMonth() -> String {
        switch self {
        case 1:
            return "January"
        case 2:
            return "February"
        case 3:
            return "March"
        case 4:
            return "April"
        case 5:
            return "May"
        case 6:
            return "June"
        case 7:
            return "July"
        case 8:
            return "August"
        case 9:
            return "September"
        case 10:
            return "October"
        case 11:
            return "November"
        case 12:
            return "December"
        default:
            return "Undefined"
        }
    }
    
    func numberToYear() -> String {
        return String(self)
    }
}

extension String {
    func getLastPathComponent() -> String {
        let nsstringValue: NSString = self as NSString
        return nsstringValue.lastPathComponent
    }
    
    func trimm() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func isEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isPassword() -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: self)
    }
}

extension Date {
    func yearsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    
    func monthsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    
    func weeksFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    
    func daysFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    
    func hoursFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    
    func minutesFrom(_ date: Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    
    func secondsFrom(_ date: Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    
    // Calculate currentDate distance from creationDate for example.
    // currentDate.offsetFrom(creationDate)
    func offsetFrom(_ date: Date) -> String {
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
    
    func offsetFromShort(_ date: Date) -> String {
        // Top are weeks.
        if weeksFrom(date)   > 0 {
            return "\(weeksFrom(date))w"
        }
        if daysFrom(date)    > 0 {
            return "\(daysFrom(date))d"
        }
        if hoursFrom(date)   > 0 {
            return "\(hoursFrom(date))h"
        }
        if minutesFrom(date) > 0 {
            return "\(minutesFrom(date))m"
        }
        if secondsFrom(date) > 0 {
            return "\(secondsFrom(date))s"
        }
        return "Now"
    }
    
    // Used for CommonCrypto and AWSClousSearchManager
    struct Formatter {
        static let iso8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            return formatter
        }()
        static let amzDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
//            formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            return formatter
        }()
        static let datestamp: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyyMMdd"
            return formatter
        }()
    }
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
    var amzDate: String {
        return Formatter.amzDate.string(from: self)
    }
    var datestamp: String {
        return Formatter.datestamp.string(from: self)
    }
}

extension NSNumber {
    
    func getMonth() -> Int {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let month = (Calendar.current as NSCalendar).components([.month], from: date).month
        return month!
    }
    
    func getYear() -> Int {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let year = (Calendar.current as NSCalendar).components([.year], from: date).year
        return year!
    }
}
