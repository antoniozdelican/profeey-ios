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
    var numberOfComments: NSNumber?
    
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
    var numberOfCommentsString: String? {
        guard let numberOfComments = self.numberOfComments else {
            return nil
        }
        let numberOfCommentsInt = numberOfComments.intValue
        guard numberOfCommentsInt > 0 else {
            return nil
        }
        guard numberOfCommentsInt > 1 else {
            return "\(numberOfCommentsInt) comment"
        }
        return "\(numberOfCommentsInt) comments"
    }
    var numberOfCommentsSmallString: String? {
        guard let numberOfComments = self.numberOfComments else {
            return "0"
        }
        let numberOfCommentsInt = numberOfComments.intValue
        return numberOfCommentsInt.numberToString()
    }
    
    var isLikedByCurrentUser: Bool = false

    override init() {
        super.init()
    }
    
    convenience init(userId: String?, postId: String?, caption: String?, categoryName: String?, creationDate: NSNumber?, imageUrl: String?, numberOfLikes: NSNumber?, numberOfComments: NSNumber?, user: User?) {
        self.init()
        self.userId = userId
        self.postId = postId
        self.caption = caption
        self.categoryName = categoryName
        self.creationDate = creationDate
        self.imageUrl = imageUrl
        self.numberOfLikes = numberOfLikes
        self.numberOfComments = numberOfComments
        
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
