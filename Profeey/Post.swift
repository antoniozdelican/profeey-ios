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
    var postDescription: String?
    var imageUrl: String?
    var title: String?
    
    var image: UIImage?
    var categories: [Category]?
    
    //var userId: String?
    var postId: String?
    var caption: String?
    var creationDate: NSNumber?
    var mediaUrl: String?
    
    var user: User?
    var mediaData: NSData?
    
    var numberOfLikes: Int = 0
    var numberOfComments: Int = 0

    override init() {
        super.init()
    }
    
    // TEST
    convenience init(user: User?, postId: String?, caption: String?, creationDate: NSNumber?, mediaUrl: String?, mediaData: NSData?) {
        self.init()
        self.user = user
        self.postId = postId
        self.caption = caption
        self.creationDate = creationDate
        self.mediaUrl = mediaUrl
        
        self.mediaData = mediaData
    }
    
    // TEST
    convenience init(user: User?, caption: String?, mediaData: NSData?, numberOfLikes: Int, numberOfComments: Int) {
        self.init()
        self.user = user
        self.caption = caption
        self.mediaData = mediaData
        self.numberOfLikes = numberOfLikes
        self.numberOfComments = numberOfComments
    }
    
    convenience init(postDescription: String?, imageUrl: String?, title: String?) {
        self.init()
        self.postDescription = postDescription
        self.imageUrl = imageUrl
        self.title = title
    }
    
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