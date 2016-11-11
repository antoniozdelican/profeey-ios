//
//  UserCategory.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class UserCategory: NSObject {
    
    // Properties.
    var userId: String?
    var categoryName: String?
    var numberOfPosts: NSNumber?
    
    // Generated.
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
    
    convenience init(userId: String?, categoryName: String?, numberOfPosts: NSNumber?) {
        self.init()
        self.userId = userId
        self.categoryName = categoryName
        self.numberOfPosts = numberOfPosts
    }
}
