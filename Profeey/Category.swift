//
//  Category.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class Category: NSObject {
    
    // Properties.
    var categoryName: String?
    var numberOfPosts: NSNumber?
    
    // Generated.
    var numberOfPostsString: String? {
        if let numberOfPosts = self.numberOfPosts {
            let numberOfPostsInt = numberOfPosts.integerValue
            return numberOfPostsInt == 1 ? "\(numberOfPostsInt) post" : "\(numberOfPostsInt) posts"
        } else {
            return nil
        }
    }
    
    override init() {
        super.init()
    }
    
    convenience init(categoryName: String?, numberOfPosts: NSNumber?) {
        self.init()
        self.categoryName = categoryName
        self.numberOfPosts = numberOfPosts
    }
}