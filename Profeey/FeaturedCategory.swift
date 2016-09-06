//
//  FeaturedCategory.swift
//  Profeey
//
//  Created by Antonio Zdelican on 05/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

// Subclass of Category.
class FeaturedCategory: Category {
    
    // Properties.
    var featuredImageUrl: String?
    
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