//
//  UserExperience.swift
//  Profeey
//
//  Created by Antonio Zdelican on 19/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class UserExperience: NSObject {
    
    // Properties.
    var userId: String?
    var experienceId: String?
    var position: String?
    var organization: String?
    var fromDate: NSNumber?
    var toDate: NSNumber?
    var experienceType: NSNumber?
    
    // Generated.
    var fromMonth: Int? {
        guard let fromDate = self.fromDate else {
            return nil
        }
        return fromDate.getMonth()
    }
    var fromYear: Int? {
        guard let fromDate = self.fromDate else {
            return nil
        }
        return fromDate.getYear()
    }
    var toMonth: Int? {
        guard let toDate = self.toDate else {
            return nil
        }
        return toDate.getMonth()
    }
    var toYear: Int? {
        guard let toDate = self.toDate else {
            return nil
        }
        return toDate.getYear()
    }
    var timePeriod: String? {
        guard let fromDate = self.fromDate else {
            return nil
        }
        let fromMonth = fromDate.getMonth().numberToMonth()
        let fromYear = String(fromDate.getYear())
        let fromShortDate = "\(fromMonth) \(fromYear)"
        
        guard let toDate = self.toDate else {
            return "\(fromShortDate) - Present"
        }
        let toMonth = toDate.getMonth().numberToMonth()
        let toYear = String(toDate.getYear())
        let toShortDate = "\(toMonth) \(toYear)"
        return "\(fromShortDate) - \(toShortDate)"
    }
    
    override init() {
        super.init()
    }
    
    convenience init(userId: String?, experienceId: String?, position: String?, organization: String?, fromDate: NSNumber?, toDate: NSNumber?, experienceType: NSNumber?) {
        self.init()
        self.userId = userId
        self.experienceId = experienceId
        self.position = position
        self.organization = organization
        self.fromDate = fromDate
        self.toDate = toDate
        self.experienceType = experienceType
    }
}