//
//  Location.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class Location: NSObject {
    
    // Properties.
    var locationId: String?
    var country: String?
    var state: String?
    var city: String?
    var latitude: NSNumber?
    var longitude: NSNumber?
    var numberOfUsers: NSNumber?
    
    // Generated.
    var locationName: String? {
        if self.state != nil {
           return [self.city, self.state].flatMap({$0}).joined(separator: ", ")
        } else {
           return [self.city, self.country].flatMap({$0}).joined(separator: ", ")
        }
    }
    var numberOfUsersString: String? {
        guard let numberOfUsers = self.numberOfUsers else {
            return nil
        }
        let numberOfUsersInt = numberOfUsers.intValue
        guard numberOfUsersInt > 0 else {
            return nil
        }
        return numberOfUsersInt == 1 ? "\(numberOfUsersInt) profeey" : "\(numberOfUsersInt) profeeys"
    }
    
    override init() {
        super.init()
    }
    
    convenience init(locationId: String?, country: String?, state: String?, city: String?, latitude: NSNumber?, longitude: NSNumber?, numberOfUsers: NSNumber?) {
        self.init()
        self.locationId = locationId
        self.country = country
        self.state = state
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        self.numberOfUsers = numberOfUsers
    }
}
