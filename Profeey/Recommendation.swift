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
    var created: NSNumber?
    
    // Generated.
    var user: User?
    var createdString: String? {
        guard let created = self.created else {
            return nil
        }
        let currentDate = Date()
        return currentDate.offsetFromShort(Date(timeIntervalSince1970: TimeInterval(created)))
    }
    
    var isExpandedRecommendationText: Bool = false
    
    override init() {
        super.init()
    }
    
    convenience init(userId: String?, recommendingId: String?, recommendationText: String?, created: NSNumber?, user: User?) {
        self.init()
        self.userId = userId
        self.recommendingId = recommendingId
        self.recommendationText = recommendationText
        self.created = created
        self.user = user
    }
}
