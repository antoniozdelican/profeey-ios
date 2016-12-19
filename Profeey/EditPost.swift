//
//  EditPost.swift
//  Profeey
//
//  Created by Antonio Zdelican on 19/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class EditPost: Post {
    
    override init() {
        super.init()
    }
    
    // Partial post for EditPostVc.
    convenience init(userId: String?, postId: String?, caption: String?, categoryName: String?, imageWidth: NSNumber?, imageHeight: NSNumber?, image: UIImage?) {
        self.init()
        self.userId = userId
        self.postId = postId
        self.caption = caption
        self.categoryName = categoryName
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.image = image
    }
}
