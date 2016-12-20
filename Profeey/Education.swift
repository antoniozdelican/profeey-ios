//
//  Education.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class Education: NSObject {
    
    // Properties.
    var userId: String?
    var educationId: String?
    var school: String?
    var fieldOfStudy: String?
    var educationDescription: String?
    var fromMonth: NSNumber?
    var fromYear: NSNumber?
    var toMonth: NSNumber?
    var toYear: NSNumber?
    
    // Generated.
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
    
    var isExpandedEducationDescription: Bool = false
    
    override init() {
        super.init()
    }
    
    convenience init(userId: String?, educationId: String?, school: String?, fieldOfStudy: String?, educationDescription: String?, fromMonth: NSNumber?, fromYear: NSNumber?, toMonth: NSNumber?, toYear: NSNumber?) {
        self.init()
        self.userId = userId
        self.educationId = educationId
        self.school = school
        self.fieldOfStudy = fieldOfStudy
        self.educationDescription = educationDescription
        self.fromMonth = fromMonth
        self.fromYear = fromYear
        self.toMonth = toMonth
        self.toYear = toYear
    }
}
