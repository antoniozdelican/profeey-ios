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
    var countryName: String?
    var cityName: String?
    var stateName: String?
    var searchCountryName: String?
    var searchCityName: String?
    
    // Generated.
    var fullLocationName: String? {
        return [self.cityName, self.stateName, self.countryName].flatMap({$0}).joined(separator: ", ")
    }
    
    override init() {
        super.init()
    }
    
    convenience init(countryName: String?, cityName: String?, stateName: String?, searchCountryName: String?, searchCityName: String?) {
        self.init()
        self.countryName = countryName
        self.cityName = cityName
        self.stateName = stateName
        self.searchCountryName = searchCountryName
        self.searchCityName = searchCityName
    }
}
