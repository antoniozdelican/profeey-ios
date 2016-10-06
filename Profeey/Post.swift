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
    var caption: String?
    var categoryName: String?
    var creationDate: NSNumber?
    var imageUrl: String?
    var numberOfLikes: NSNumber?
    
    // Generated.
    var user: User?
    var image: UIImage?
    var creationDateString: String? {
        guard let creationDate = self.creationDate else {
            return nil
        }
        let currentDate = Date()
        return currentDate.offsetFrom(Date(timeIntervalSince1970: TimeInterval(creationDate)))
    }
    var numberOfLikesString: String? {
        guard let numberOfLikes = self.numberOfLikes else {
            return nil
        }
        let numberOfLikesInt = numberOfLikes.intValue
        guard numberOfLikesInt > 0 else {
            return nil
        }
        guard numberOfLikesInt > 1 else {
            return "\(numberOfLikesInt) like"
        }
        return "\(numberOfLikesInt) likes"
    }
    var numberOfLikesSmallString: String? {
        guard let numberOfLikes = self.numberOfLikes else {
            return "0"
        }
        let numberOfLikesInt = numberOfLikes.intValue
        return numberOfLikesInt.numberToString()
    }
    
    
    var numberOfComments: Int = 0
    
    var isLikedByCurrentUser: Bool = false

    override init() {
        super.init()
    }
    
    convenience init(userId: String?, postId: String?, caption: String?, categoryName: String?, creationDate: NSNumber?, imageUrl: String?, numberOfLikes: NSNumber?, user: User?) {
        self.init()
        self.userId = userId
        self.postId = postId
        self.caption = caption
        self.categoryName = categoryName
        self.creationDate = creationDate
        self.imageUrl = imageUrl
        self.numberOfLikes = numberOfLikes
        
        self.user = user
    }
    
    // Partial post for EditPostVc
    convenience init(userId: String?, postId: String?, caption: String?, categoryName: String?) {
        self.init()
        self.userId = userId
        self.postId = postId
        self.caption = caption
        self.categoryName = categoryName
    }
}
