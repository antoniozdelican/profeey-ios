//
//  Experience.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import Foundation

class Experience: NSObject {
    
    // Common properties.
    var userId: String?
    var fromMonth: NSNumber?
    var fromYear: NSNumber?
    var toMonth: NSNumber?
    var toYear: NSNumber?
    
    var experienceType: ExperienceType?
    
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
    
    override init() {
        super.init()
    }
    
}
