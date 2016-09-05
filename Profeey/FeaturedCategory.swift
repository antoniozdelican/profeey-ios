//
//  FeaturedCategory.swift
//  Profeey
//
//  Created by Antonio Zdelican on 05/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class FeaturedCategory: NSObject {
    
    // Properties.
    var categoryName: String?
    var featuredImageUrl: String?
    var numberOfPosts: NSNumber?
    
    // Generated.
    var featuredImage: UIImage?
    
    override init() {
        super.init()
    }
    
    convenience init(categoryName: String?, featuredImageUrl: String?, numberOfPosts: NSNumber?) {
        self.init()
        self.categoryName = categoryName
        self.featuredImageUrl = featuredImageUrl
        self.numberOfPosts = numberOfPosts
    }
}