//
//  Post.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

class Post: NSObject {
    
    //var userId: String?
    var postId: String?
    var caption: String?
    var categories: [String]?
    var creationDate: NSNumber?
    var mediaUrl: String?
    
    var user: User?
    var mediaData: NSData?
    
    init(user: User?, postId: String?, caption: String?, categories: [String]?, creationDate: NSNumber?, mediaUrl: String?, mediaData: NSData?) {
        super.init()
        self.user = user
        self.postId = postId
        self.caption = caption
        self.categories = categories
        self.creationDate = creationDate
        self.mediaUrl = mediaUrl
        
        self.mediaData = mediaData
    }
    
    func updateFromRemote(awsPost: AWSPost) {
        self.postId = awsPost._postId
        self.caption = awsPost._caption
        self.categories = awsPost._categories
        self.creationDate = awsPost._creationDate
        self.mediaUrl = awsPost._mediaUrl
    }
}