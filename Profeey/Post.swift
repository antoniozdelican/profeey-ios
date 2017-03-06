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
    var created: NSNumber?
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
    var createdString: String? {
        guard let created = self.created else {
            return nil
        }
        let currentDate = Date()
        return currentDate.offsetFrom(Date(timeIntervalSince1970: TimeInterval(created)))
    }
    var categoryNameWhitespace: String? {
        return self.categoryName?.replacingOccurrences(of: "_", with: " ")
    }
    //Likes
    var numberOfLikesInt: Int {
        guard let numberOfLikes = self.numberOfLikes else {
            return 0
        }
        return numberOfLikes.intValue
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
    var numberOfLikesSmallString: String? {
        guard let numberOfLikes = self.numberOfLikes else {
            return "0"
        }
        let numberOfLikesInt = numberOfLikes.intValue
        return numberOfLikesInt.numberToString()
    }
    // Comments.
    var numberOfCommentsInt: Int {
        guard let numberOfComments = self.numberOfComments else {
            return 0
        }
        return numberOfComments.intValue
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
    // Other.
    var isLikedByCurrentUser: Bool = false
    var isExpandedCaption: Bool = false
    var isReportedByCurrentUser: Bool = false

    override init() {
        super.init()
    }
    
    convenience init(userId: String?, postId: String?, created: NSNumber?, caption: String?, categoryName: String?, imageUrl: String?, imageWidth: NSNumber?, imageHeight: NSNumber?, numberOfLikes: NSNumber?, numberOfComments: NSNumber?, user: User?) {
        self.init()
        self.userId = userId
        self.postId = postId
        self.created = created
        self.caption = caption
        self.categoryName = categoryName
        self.imageUrl = imageUrl
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.numberOfLikes = numberOfLikes
        self.numberOfComments = numberOfComments
        self.user = user
    }
    
    // MARK: Custom copying
    
    func copyPost() -> Post {
        let post = Post(userId: userId, postId: postId, created: created, caption: caption, categoryName: categoryName, imageUrl: imageUrl, imageWidth: imageWidth, imageHeight: imageHeight, numberOfLikes: numberOfLikes, numberOfComments: numberOfComments, user: user)
        post.image = image
        return post
    }
    
    func copyEditPost() -> EditPost {
        let editPost = EditPost(userId: userId, postId: postId, caption: caption, categoryName: categoryName, imageWidth: imageWidth, imageHeight: imageHeight, image: image)
        return editPost
    }
}
