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
    var numberOfUsers: Int?
    var numberOfPosts: Int?
    
    override init() {
        super.init()
    }
    
    convenience init(categoryName: String?, numberOfUsers: Int?, numberOfPosts: Int?) {
        self.init()
        self.categoryName = categoryName
        self.numberOfUsers = numberOfUsers
        self.numberOfPosts = numberOfPosts
    }
}