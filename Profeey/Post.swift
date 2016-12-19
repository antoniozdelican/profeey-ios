//
//  Post.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class Post: NSObject, NSCopying {
    
    // Properties.
    var userId: String?
    var postId: String?
    var creationDate: NSNumber?
    var caption: String?
    var categoryName: String?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
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
        return numberOfCommentsInt.numberToString()
    }
    var numberOfLikesSmallString: String? {
        guard let numberOfLikes = self.numberOfLikes else {
            return "0"
        }
        let numberOfLikesInt = numberOfLikes.intValue
        return numberOfLikesInt.numberToString()
    }
    
    var isLikedByCurrentUser: Bool = false
    var isExpandedCaption: Bool = false

    override init() {
        super.init()
    }
    
    convenience init(userId: String?, postId: String?, creationDate: NSNumber?, caption: String?, categoryName: String?, imageUrl: String?, imageWidth: NSNumber?, imageHeight: NSNumber?, numberOfLikes: NSNumber?, numberOfComments: NSNumber?, user: User?) {
        self.init()
        self.userId = userId
        self.postId = postId
        self.creationDate = creationDate
        self.caption = caption
        self.categoryName = categoryName
        self.imageUrl = imageUrl
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.numberOfLikes = numberOfLikes
        self.numberOfComments = numberOfComments
        self.user = user
    }
    
    // Used to copy Post object for PostDetailsVc.
    func copy(with zone: NSZone? = nil) -> Any {
        let post = Post(userId: userId, postId: postId, creationDate: creationDate, caption: caption, categoryName: categoryName, imageUrl: imageUrl, imageWidth: imageWidth, imageHeight: imageHeight, numberOfLikes: numberOfLikes, numberOfComments: numberOfComments, user: user)
        post.image = image
        return post
    }
}
