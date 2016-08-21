//
//  Comment.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class Comment: NSObject {
    
    var user: User?
    var commentText: String?
    
    override init() {
        super.init()
    }
    
    convenience init(user: User?, commentText: String?) {
        self.init()
        self.user = user
        self.commentText = commentText
    }
}
