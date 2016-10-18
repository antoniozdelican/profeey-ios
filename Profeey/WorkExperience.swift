//
//  WorkExperience.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class WorkExperience: NSObject {
    
    // Properties.
    var userId: String?
    var workExperienceId: String?
    var title: String?
    var organization: String?
    var workDescription: String?
    var fromMonth: NSNumber?
    var fromYear: NSNumber?
    var toMonth: NSNumber?
    var toYear: NSNumber?
    
    var fromMonthInt: Int? {
        guard let fromMonth = self.fromMonth else {
            return nil
        }
        return fromMonth.intValue
    }
    
    var fromYearInt: Int? {
        guard let fromYear = self.fromYear else {
            return nil
        }
        return fromYear.intValue
    }
    
    var toMonthInt: Int? {
        guard let toMonth = self.toMonth else {
            return nil
        }
        return toMonth.intValue
    }
    
    var toYearInt: Int? {
        guard let toYear = self.toYear else {
            return nil
        }
        return toYear.intValue
    }
    
    var timePeriod: String? {
        guard let fromMonthInt = self.fromMonthInt, let fromYearInt = self.fromYearInt else {
            return nil
        }
        let fromDate = "\(fromMonthInt.numberToMonth()) \(fromYearInt)"
        guard let toMonthInt = self.toMonthInt, let toYearInt = self.toYearInt else {
            return "\(fromDate) - Present"
        }
        let toDate = "\(toMonthInt.numberToMonth()) \(toYearInt)"
        return "\(fromDate) - \(toDate)"
    }
    
    override init() {
        super.init()
    }
    
    convenience init(userId: String?, workExperienceId: String?, title: String?, organization: String?, workDescription: String?, fromMonth: NSNumber?, fromYear: NSNumber?, toMonth: NSNumber?, toYear: NSNumber?) {
        self.init()
        self.userId = userId
        self.workExperienceId = workExperienceId
        self.title = title
        self.organization = organization
        self.workDescription = workDescription
        self.fromMonth = fromMonth
        self.fromYear = fromYear
        self.toMonth = toMonth
        self.toYear = toYear
    }
}
