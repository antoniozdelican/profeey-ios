//
//  Recommendation.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class Recommendation: NSObject {
    
    // Properties.
    var userId: String?
    var recommendingId: String?
    var recommendationText: String?
    var creationDate: NSNumber?
    
    // Generated.
    var user: User?
    var creationDateString: String? {
        guard let creationDate = self.creationDate else {
            return nil
        }
        let currentDate = Date()
        return currentDate.offsetFrom(Date(timeIntervalSince1970: TimeInterval(creationDate)))
    }
    
    override init() {
        super.init()
    }
    
    convenience init(userId: String?, recommendingId: String?, recommendationText: String?, creationDate: NSNumber?, user: User?) {
        self.init()
        self.userId = userId
        self.recommendingId = recommendingId
        self.recommendationText = recommendationText
        self.creationDate = creationDate
        self.user = user
    }
}
