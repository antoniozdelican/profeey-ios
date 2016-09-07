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
    var numberOfLikes: NSNumber?
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
    var numberOfLikesString: String? {
        if let numberOfLikes = self.numberOfLikes {
            let numberOfLikesInt = numberOfLikes.integerValue
            return numberOfLikesInt == 1 ? "\(numberOfLikesInt) like" : "\(numberOfLikesInt) likes"
        } else {
            return nil
        }
    }
    
    
    var numberOfComments: Int = 0
    
    var isLikedByCurrentUser: Bool = false

    override init() {
        super.init()
    }
    
//    convenience init(userId: String?, postId: String?, categoryName: String?, creationDate: NSNumber?, postDescription: String?, imageUrl: String?, title: String?, userFirstName: String?, userLastName: String?, userPreferredUsername: String?, userProfession: String?, userProfilePicUrl: String?) {
//        self.init()
//        self.userId = userId
//        self.postId = postId
//        self.categoryName = categoryName
//        self.creationDate = creationDate
//        self.postDescription = postDescription
//        self.imageUrl = imageUrl
//        self.title = title
//        
//        self.userFirstName = userFirstName
//        self.userLastName = userLastName
//        self.userPreferredUsername = userPreferredUsername
//        self.userProfession = userProfession
//        self.userProfilePicUrl = userProfilePicUrl
//    }
    
    // Send only basic user object!
    convenience init(userId: String?, postId: String?, categoryName: String?, creationDate: NSNumber?, postDescription: String?, imageUrl: String?, numberOfLikes: NSNumber?, title: String?, user: User?) {
        self.init()
        self.userId = userId
        self.postId = postId
        self.categoryName = categoryName
        self.creationDate = creationDate
        self.postDescription = postDescription
        self.imageUrl = imageUrl
        self.numberOfLikes = numberOfLikes
        self.title = title
        
        self.user = user
    }
}