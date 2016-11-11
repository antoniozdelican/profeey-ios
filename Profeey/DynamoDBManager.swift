//
//  DynamoDBManager.swift
//  Profeey
//
//  Created by Antonio Zdelican on 03/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSDynamoDB

protocol DynamoDBManager {
    
    // MARK: Users
    
    func getCurrentUserDynamoDB(_ completionHandler: @escaping AWSContinuationBlock)
    func getUserDynamoDB(_ userId: String, completionHandler: @escaping AWSContinuationBlock)
    
    func createUserDynamoDB(_ email: String, firstName: String, lastName: String, completionHandler: @escaping AWSContinuationBlock)
    func saveUserPreferredUsernameAndProfilePicDynamoDB(_ preferredUsername: String, profilePicUrl: String?, completionHandler: @escaping AWSContinuationBlock)
    func saveUserProfessionDynamoDB(_ professionName: String, completionHandler: @escaping AWSContinuationBlock)
    
    func saveUserDynamoDB(_ user: User?, completionHandler: @escaping AWSContinuationBlock)
    
    func scanUsersDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func scanUsersByNameDynamoDB(_ searchFirstName: String, searchLastName: String, searchPreferredUsername: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func scanUsersByProfessionNameDynamoDB(_ searchProfessionName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func scanUsersByProfessionAndLocationNameDynamoDB(_ searchProfessionName: String, locationName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Relationships
    
    func getRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock)
    func createRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock)
    func removeRelationshipDynamoDB(_ followingId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryFollowersDynamoDB(_ followingId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func queryFollowingDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Likes
    
    func getLikeDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock)
    func createLikeDynamoDB(_ postId: String, postUserId: String, completionHandler: @escaping AWSContinuationBlock)
    func removeLikeDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryPostLikesDynamoDB(_ postId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Comments
    
    func createCommentDynamoDB(_ postId: String, postUserId: String, commentText: String, completionHandler: @escaping AWSContinuationBlock)
//    func updateCommentDynamoDB(_ commentId: String, postId: String, commentText: String, completionHandler: @escaping AWSContinuationBlock)
    func removeCommentDynamoDB(_ commentId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryPostCommentsDateSortedDynamoDB(_ postId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Posts
    
    func queryUserPostsDateSortedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func queryCategoryPostsDateSortedDynamoDB(_ categoryName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    func createPostDynamoDB(_ imageUrl: String?, caption: String?, categoryName: String?, completionHandler: @escaping AWSContinuationBlock)
    func updatePostDynamoDB(_ postId: String, caption: String?, categoryName: String?, completionHandler: @escaping AWSContinuationBlock)
    func removePostDynamoDB(_ postId: String, completionHandler: @escaping AWSContinuationBlock)
    
    // MARK: Categories
    
    func scanCategoriesDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
//    func scanCategoriesByCategoryNameDynamoDB(_ searchCategoryName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Professions
    
    func scanProfessionsDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
//    func scanProfessionsByProfessionNameDynamoDB(_ searchProfessionName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Locations
    
    func scanLocationsDynamoDB(_ completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
//    func scanLocationsByCountryOrCityNameDynamoDB(_ searchCountryName: String, searchCityName: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Activities
    
    func queryUserActivitiesDateSortedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: UserCategories
    
    func queryUserCategoriesNumberOfPostsSortedDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: WorkExperiences
    
    func createWorkExperienceDynamoDB(_ title: String?, organization: String?, workDescription: String?, fromMonth: NSNumber?, fromYear: NSNumber?, toMonth: NSNumber?, toYear: NSNumber?, completionHandler: @escaping AWSContinuationBlock)
    func updateWorkExperienceDynamoDB(_ workExperienceId: String, title: String?, organization: String?, workDescription: String?, fromMonth: NSNumber?, fromYear: NSNumber?, toMonth: NSNumber?, toYear: NSNumber?, completionHandler: @escaping AWSContinuationBlock)
    func removeWorkExperienceDynamoDB(_ workExperienceId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryWorkExperiencesDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
    
    // MARK: Educations
    
    func createEducationDynamoDB(_ school: String?, fieldOfStudy: String?, educationDescription: String?, fromMonth: NSNumber?, fromYear: NSNumber?, toMonth: NSNumber?, toYear: NSNumber?, completionHandler: @escaping AWSContinuationBlock)
    func updateEducationDynamoDB(_ educationId: String, school: String?, fieldOfStudy: String?, educationDescription: String?, fromMonth: NSNumber?, fromYear: NSNumber?, toMonth: NSNumber?, toYear: NSNumber?, completionHandler: @escaping AWSContinuationBlock)
    func removeEducationDynamoDB(_ educationId: String, completionHandler: @escaping AWSContinuationBlock)
    func queryEducationsDynamoDB(_ userId: String, completionHandler: ((AWSDynamoDBPaginatedOutput?, Error?) -> Void)?)
}
