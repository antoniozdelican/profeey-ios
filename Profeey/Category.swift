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
    var categoryNameWhitespace: String? {
        return self.categoryName?.replacingOccurrences(of: "_", with: " ")
    }
    var numberOfPostsInt: Int {
        guard let numberOfPosts = self.numberOfPosts else {
            return 0
        }
        return numberOfPosts.intValue
    }
    var numberOfPostsString: String? {
        guard let numberOfPosts = self.numberOfPosts else {
            return nil
        }
        let numberOfPostsInt = numberOfPosts.intValue
        guard numberOfPostsInt > 0 else {
            return nil
        }
        return numberOfPostsInt == 1 ? "\(numberOfPostsInt) post" : "\(numberOfPostsInt) posts"
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
