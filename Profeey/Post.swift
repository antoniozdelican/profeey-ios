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
    //var userId: String?
    var postId: String?
    var category: String?
    var creationDate: NSNumber?
    var postDescription: String?
    var imageUrl: String?
    var title: String?
    
    //Old
    var categories: [Category]?
    
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
    var numberOfLikes: Int = 0
    var numberOfComments: Int = 0

    override init() {
        super.init()
    }
    
    convenience init(postId: String?, title: String?, postDescription: String?, imageUrl: String?, category: String?, creationDate: NSNumber?, user: User?) {
        self.init()
        self.postId = postId
        self.title = title
        self.postDescription = postDescription
        self.imageUrl = imageUrl
        self.category = category
        self.creationDate = creationDate
        self.user = user
    }
    
    // TEST
    convenience init(user: User?, postDescription: String?, imageUrl: String?, title: String?, image: UIImage?, categories: [Category]?) {
        self.init()
        self.user = user
        self.postDescription = postDescription
        self.imageUrl = imageUrl
        self.title = title
        self.image = image
        self.categories = categories
    }
    
}