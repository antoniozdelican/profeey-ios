//
//  Post.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class Post: NSObject {
    
    // Properties.
    var userId: String?
    var postId: String?
    var categoryName: String?
    var creationDate: NSNumber?
    var postDescription: String?
    var imageUrl: String?
    var title: String?
    
    // Generated.
    var user: User?
    var image: UIImage?
    var creationDateString: String? {
        if let creationDate = self.creationDate {
            let currentDate = NSDate()
            return currentDate.offsetFrom(NSDate(timeIntervalSince1970: NSTimeInterval(creationDate)))
        } else {
            return nil
        }
    }
    
    // TEST
    var numberOfLikes: Int = 0
    var numberOfComments: Int = 0

    override init() {
        super.init()
    }
    
    convenience init(userId: String?, postId: String?, categoryName: String?, creationDate: NSNumber?, postDescription: String?, imageUrl: String?, title: String?, user: User?) {
        self.init()
        self.userId = userId
        self.postId = postId
        self.categoryName = categoryName
        self.creationDate = creationDate
        self.postDescription = postDescription
        self.imageUrl = imageUrl
        self.title = title
        self.user = user
    }
}