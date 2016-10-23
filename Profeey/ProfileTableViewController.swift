//
//  ProfileTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

enum ProfileSegment {
    case posts
    case experience
    case contact
}

class ProfileTableViewController: UITableViewController {
    
    var user: User?
    var isCurrentUser: Bool = false
    fileprivate var hasUserRelationshipLoaded = false
    fileprivate var isFollowing: Bool = false
    fileprivate var indexPathMain = IndexPath(row: 0, section: 0)
    fileprivate var indexPathInfo = IndexPath(row: 1, section: 0)
    fileprivate var selectedProfileSegment: ProfileSegment = ProfileSegment.posts
    
    fileprivate var isLoadingPosts: Bool = true
    fileprivate var posts: [Post] = []
    
    fileprivate var isLoadingWorkExperiences: Bool = true
    fileprivate var workExperiences: [WorkExperience] = []
    fileprivate var isLoadingEducations: Bool = true
    fileprivate var educations: [Education] = []
    
    fileprivate var isLoadingExperiences: Bool {
        return self.isLoadingWorkExperiences || self.isLoadingEducations
    }
    fileprivate var isEmptyExperiences: Bool {
        return (self.workExperiences.count == 0 && self.educations.count == 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = self.user?.preferredUsername
        
        // Register custom headers.
        self.tableView.register(UINib(nibName: "ProfileTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "profileTableSectionHeader")
        
        self.configureUser()
        self.isLoadingEducations = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureUser() {
        guard let currentUserId = AWSClientManager.defaultClientManager().credentialsProvider?.identityId else {
            print("No currentUserId!")
            return
        }
        if self.isCurrentUser {
            // Comes from MainTabBarVc.
            self.user = PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB
            self.getUser(currentUserId)
        } else {
            // Comes from other Vc-s.
            guard let userId = user?.userId else {
                print("No userId!")
                return
            }
            self.isCurrentUser = (userId == currentUserId)
            self.getUser(userId)
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? EditProfileTableViewController {
            childViewController.user = self.user
        }
        if let destinationViewController = segue.destination as? UsersTableViewController {
            destinationViewController.usersType = UsersType.followers
            destinationViewController.userId = self.user?.userId
        }
        if let destinationViewController = segue.destination as? ExperiencesTableViewController {
            destinationViewController.workExperiences = self.workExperiences
            destinationViewController.educations = self.educations
            destinationViewController.experiencesTableViewControllerDelegate = self
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            guard self.selectedProfileSegment == ProfileSegment.posts else {
                return 0
            }
            if self.isLoadingPosts || self.posts.count == 0 {
                return 1
            }
            return self.posts.count
        case 2:
            // Empty and loading experience.
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return 0
            }
            if self.isLoadingExperiences || self.isEmptyExperiences {
                return 1
            }
            return 0
        case 3:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return 0
            }
            if self.isLoadingExperiences {
                return 0
            }
            return self.workExperiences.count
        case 4:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return 0
            }
            if self.isLoadingExperiences {
                return 0
            }
            return self.educations.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileMain", for: indexPath) as! ProfileMainTableViewCell
                cell.profilePicImageView.image = self.user?.profilePic
                cell.numberOfPostsButton.setTitle(self.user?.numberOfPostsInt.numberToString(), for: UIControlState.normal)
                cell.numberOfFollowersButton.setTitle(self.user?.numberOfFollowersInt.numberToString(), for: UIControlState.normal)
                if self.hasUserRelationshipLoaded {
                    if self.isCurrentUser {
                        cell.setEditButton()
                    } else {
                        if self.isFollowing {
                            cell.setFollowingButton()
                        } else {
                            cell.setFollowButton()
                        }
                    }
                }
                cell.profileMainTableViewCellDelegate = self
                cell.recommendButton.isHidden = true
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileInfo", for: indexPath) as! ProfileInfoTableViewCell
                cell.fullNameLabel.text = self.user?.fullName
                cell.professionNameLabel.text = self.user?.professionName
                cell.locationNameLabel.text = self.user?.locationName
                cell.aboutLabel.text = self.user?.about
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileSegmentedControl", for: indexPath) as! ProfileSegmentedControlTableViewCell
                cell.profileSegmentedControlTableViewCellDelegate = self
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            if self.isLoadingPosts {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellLoading", for: indexPath) as! LoadingTableViewCell
                cell.activityIndicator?.startAnimating()
                return cell
            }
            if self.posts.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! EmptyTableViewCell
                cell.emptyMessageLabel.text = "No posts yet"
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostSmall", for: indexPath) as! PostSmallTableViewCell
            let post = self.posts[indexPath.row]
            cell.postImageView.image = post.image
            cell.titleLabel.text = post.caption
            cell.categoryNameLabel.text = post.categoryName
            cell.timeLabel.text = post.creationDateString
            cell.numberOfLikesLabel.text = post.numberOfLikesSmallString
            return cell
        case 2:
            if self.isLoadingExperiences {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellLoading", for: indexPath) as! LoadingTableViewCell
                cell.activityIndicator?.startAnimating()
                return cell
            }
            if self.isEmptyExperiences {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! EmptyTableViewCell
                cell.emptyMessageLabel.text = "No experiences yet"
                cell.addButton?.isHidden = self.isCurrentUser ? false : true
                cell.emptyTableViewCellDelegate = self
                return cell
            }
            return UITableViewCell()
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellWorkExperience", for: indexPath) as! WorkExperienceTableViewCell
            let workExperience = self.workExperiences[indexPath.row]
            cell.titleLabel.text = workExperience.title
            cell.organizationLabel.text = workExperience.organization
            cell.timePeriodLabel.text = workExperience.timePeriod
            cell.workDescriptionLabel.text = workExperience.workDescription
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEducation", for: indexPath) as! EducationTableViewCell
            let education = self.educations[indexPath.row]
            cell.schoolLabel.text = education.school
            cell.fieldOfStudyLabel.text = education.fieldOfStudy
            cell.timePeriodLabel.text = education.timePeriod
            cell.educationDescriptionLabel.text = education.educationDescription
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return 92.0
            case 1:
                return 112.0
            case 2:
                return 46.0
            default:
                return 0.0
            }
        case 1:
            if self.isLoadingPosts || self.posts.count == 0 {
                return 120.0
            }
            return 112.0
        case 2:
            if self.isLoadingExperiences || self.isEmptyExperiences {
                return 112.0
            }
            return 0.0
        case 3:
            return 74.0
        case 4:
            return 74.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return 92.0
            case 1:
                return UITableViewAutomaticDimension
            case 2:
                return 46.0
            default:
                return 0.0
            }
        case 1:
            if self.isLoadingPosts || self.posts.count == 0 {
                return 112.0
            }
            return 112.0
        case 2:
            if self.isLoadingExperiences || self.isEmptyExperiences {
                return 112.0
            }
            return 0.0
        case 3:
            return UITableViewAutomaticDimension
        case 4:
            return UITableViewAutomaticDimension
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            guard self.selectedProfileSegment == ProfileSegment.posts else {
                return nil
            }
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "profileTableSectionHeader") as? ProfileTableSectionHeader
            header?.titleLabel?.text = nil
            header?.editButton?.isHidden = true
            return header
        case 2:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return nil
            }
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "profileTableSectionHeader") as? ProfileTableSectionHeader
            header?.titleLabel?.text = nil
            header?.editButton?.isHidden = true
            return header
        case 3:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return nil
            }
            if self.isLoadingExperiences || self.workExperiences.count == 0 {
                return nil
            }
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "profileTableSectionHeader") as? ProfileTableSectionHeader
            header?.titleLabel?.text = "WORK EXPERIENCE"
            header?.editButton?.isHidden = self.isCurrentUser ? false : true
            header?.profileTableSectionHeaderDelegate = self
            return header
        case 4:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return nil
            }
            if self.isLoadingExperiences || self.educations.count == 0 {
                return nil
            }
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "profileTableSectionHeader") as? ProfileTableSectionHeader
            header?.titleLabel?.text = "EDUCATION"
            header?.editButton?.isHidden = self.isCurrentUser ? false : true
            header?.profileTableSectionHeaderDelegate = self
            return header
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            guard self.selectedProfileSegment == ProfileSegment.posts else {
                return CGFloat.leastNormalMagnitude
            }
            return 6.0
        case 2:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return CGFloat.leastNormalMagnitude
            }
            return 6.0
        case 3:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return CGFloat.leastNormalMagnitude
            }
            if self.isLoadingExperiences || self.workExperiences.count == 0 {
                return CGFloat.leastNormalMagnitude
            }
            return 36.0
        case 4:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return CGFloat.leastNormalMagnitude
            }
            if self.isLoadingExperiences || self.educations.count == 0 {
                return CGFloat.leastNormalMagnitude
            }
            return 36.0
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 3:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return CGFloat.leastNormalMagnitude
            }
            if self.isLoadingExperiences || self.workExperiences.count == 0 {
                return CGFloat.leastNormalMagnitude
            }
            return 16.0
        case 4:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return CGFloat.leastNormalMagnitude
            }
            if self.isLoadingExperiences || self.educations.count == 0 {
                return CGFloat.leastNormalMagnitude
            }
            return 16.0
        default:
            return CGFloat.leastNormalMagnitude
        }

    }
    
    // MARK: IBActions
    
    @IBAction func settingsButtonTapped(_ sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let signOutAction = UIAlertAction(title: "Sign out", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction) in
            self.signOut()
        })
        alertController.addAction(signOutAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToProfileTableViewController(_ segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? EditProfileTableViewController {
            self.user?.profilePic = sourceViewController.profilePic
            self.user?.profilePicUrl = sourceViewController.profilePicUrl
            self.user?.firstName = sourceViewController.firstName
            self.user?.lastName = sourceViewController.lastName
            self.user?.professionName = sourceViewController.professionName
            self.user?.about = sourceViewController.about
            self.user?.locationName = sourceViewController.locationName
            self.tableView.reloadRows(at: [self.indexPathMain, self.indexPathInfo], with: UITableViewRowAnimation.none)
            // Remove image in background.
            if let profilePicUrlToRemove = sourceViewController.profilePicUrlToRemove {
                self.removeImage(profilePicUrlToRemove)
            }
        }
    }
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        guard let userId = self.user?.userId else {
            self.refreshControl?.endRefreshing()
            return
        }
        self.getUser(userId)
    }
    
    // MARK: AWS
    
    fileprivate func getUser(_ userId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getUserDynamoDB(userId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getUser error: \(error)")
                    self.refreshControl?.endRefreshing()
                } else {
                    guard let awsUser = task.result as? AWSUser else {
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, about: awsUser._about, locationName: awsUser._locationName, numberOfFollowers: awsUser._numberOfFollowers, numberOfPosts: awsUser._numberOfPosts, topCategories: awsUser._topCategories)
                    self.user = user
                    if let userId = awsUser._userId {
                        if self.isCurrentUser {
                            self.hasUserRelationshipLoaded = true
                        } else {
                            self.getUserRelationship(userId, indexPath: self.indexPathMain)
                        }
                    }
                    self.tableView.reloadRows(at: [self.indexPathMain, self.indexPathInfo], with: UITableViewRowAnimation.none)
                    self.navigationItem.title = self.user?.preferredUsername
                    if let profilePicUrl = awsUser._profilePicUrl {
                        self.downloadImage(profilePicUrl, imageType: .userProfilePic, indexPath: self.indexPathMain)
                    }
                    if let userId = awsUser._userId {
                        self.queryUserPostsDateSorted(userId)
                        self.queryWorkExperiences(userId)
                        self.queryEducations(userId)
                    }
                    // For now
                    self.refreshControl?.endRefreshing()
                    
                }
            })
            return nil
        })
    }
    
    fileprivate func queryUserPostsDateSorted(_ userId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserPostsDateSortedDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingPosts = false
                if let error = error {
                    print("queryUserPostsDateSorted error: \(error)")
                    if self.selectedProfileSegment == ProfileSegment.posts {
                        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                    }
                } else {
                    guard let awsPosts = response?.items as? [AWSPost], awsPosts.count > 0 else {
                        if self.selectedProfileSegment == ProfileSegment.posts {
                            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                        }
                        return
                    }
                    // Reset posts.
                    self.posts = []
                    for (index, awsPost) in awsPosts.enumerated() {
                        let post = Post(userId: awsPost._userId, postId: awsPost._postId, caption: awsPost._caption, categoryName: awsPost._categoryName, creationDate: awsPost._creationDate, imageUrl: awsPost._imageUrl, numberOfLikes: awsPost._numberOfLikes, user: self.user)
                        self.posts.append(post)
                        if self.selectedProfileSegment == ProfileSegment.posts {
                            UIView.setAnimationsEnabled(false)
                            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                            UIView.setAnimationsEnabled(true)
                        }
                        
                        if let imageUrl = awsPost._imageUrl {
                            self.downloadImage(imageUrl, imageType: .postPic, indexPath: IndexPath(row: index, section: 1))
                        }
                    }
                }
            })
        })
    }
    
    fileprivate func queryWorkExperiences(_ userId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryWorkExperiencesDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingWorkExperiences = false
                if let error = error {
                    print("queryWorkExperiences error: \(error)")
                    if self.selectedProfileSegment == ProfileSegment.experience {
                        self.tableView.reloadSections(IndexSet([2, 3, 4]), with: UITableViewRowAnimation.none)
                    }
                } else {
                    guard let awsWorkExperiences = response?.items as? [AWSWorkExperience], awsWorkExperiences.count > 0 else {
                        if self.selectedProfileSegment == ProfileSegment.experience {
                            self.tableView.reloadSections(IndexSet([2, 3, 4]), with: UITableViewRowAnimation.none)
                        }
                        return
                    }
                    self.workExperiences = []
                    for awsWorkExperience in awsWorkExperiences {
                        let workExperience = WorkExperience(userId: awsWorkExperience._userId, workExperienceId: awsWorkExperience._workExperienceId, title: awsWorkExperience._title, organization: awsWorkExperience._organization, workDescription: awsWorkExperience._workDescription, fromMonth: awsWorkExperience._fromMonth, fromYear: awsWorkExperience._fromYear, toMonth: awsWorkExperience._toMonth, toYear: awsWorkExperience._toYear)
                        self.workExperiences.append(workExperience)
                        if self.selectedProfileSegment == ProfileSegment.experience {
                            UIView.setAnimationsEnabled(false)
                            self.tableView.reloadSections(IndexSet([2, 3, 4]), with: UITableViewRowAnimation.none)
                            UIView.setAnimationsEnabled(true)
                        }
                    }
                }
            })
        })
    }
    
    fileprivate func queryEducations(_ userId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryEducationsDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingEducations = false
                if let error = error {
                    print("queryEducations error: \(error)")
                    if self.selectedProfileSegment == ProfileSegment.experience {
                        self.tableView.reloadSections(IndexSet([2, 3, 4]), with: UITableViewRowAnimation.none)
                    }
                } else {
                    guard let awsEducations = response?.items as? [AWSEducation], awsEducations.count > 0 else {
                        if self.selectedProfileSegment == ProfileSegment.experience {
                            self.tableView.reloadSections(IndexSet([2, 3, 4]), with: UITableViewRowAnimation.none)
                        }
                        return
                    }
                    self.educations = []
                    for awsEducation in awsEducations {
                        let education = Education(userId: awsEducation._userId, educationId: awsEducation._educationId, school: awsEducation._school, fieldOfStudy: awsEducation._fieldOfStudy, educationDescription: awsEducation._educationDescription, fromMonth: awsEducation._fromMonth, fromYear: awsEducation._fromYear, toMonth: awsEducation._toMonth, toYear: awsEducation._toYear)
                        self.educations.append(education)
                        if self.selectedProfileSegment == ProfileSegment.experience {
                            UIView.setAnimationsEnabled(false)
                            self.tableView.reloadSections(IndexSet([2, 3, 4]), with: UITableViewRowAnimation.none)
                            UIView.setAnimationsEnabled(true)
                        }
                    }
                }
            })
        })
    }
    
    fileprivate func downloadImage(_ imageKey: String, imageType: ImageType, indexPath: IndexPath) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let content = AWSUserFileManager.custom(key: "USEast1BucketManager").content(withKey: imageKey)
        // TODO check if content.isImage()
        if content.isCached {
            print("Content cached:")
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            let image = UIImage(data: content.cachedData)
            switch imageType {
            case .userProfilePic:
                self.user?.profilePic = image
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            case .postPic:
                self.posts[indexPath.row].image = image
                if self.selectedProfileSegment == ProfileSegment.posts {
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                }
            default:
                return
            }
        } else {
            print("Download content:")
            content.download(
                with: AWSContentDownloadType.ifNewerExists,
                pinOnCompletion: false,
                progressBlock: {
                    (content: AWSContent?, progress: Progress?) -> Void in
                    // TODO
                },
                completionHandler: {
                    (content: AWSContent?, data: Data?, error: Error?) in
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if let error = error {
                            print("downloadImage error: \(error)")
                        } else {
                            guard let imageData = data else {
                                return
                            }
                            let image = UIImage(data: imageData)
                            switch imageType {
                            case .userProfilePic:
                                self.user?.profilePic = image
                                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                            case .postPic:
                                self.posts[indexPath.row].image = image
                                if self.selectedProfileSegment == ProfileSegment.posts {
                                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                                }
                            default:
                                return
                            }
                        }
                    })
            })
        }
    }
    
    // In background when user deletes/changes profilePic.
    fileprivate func removeImage(_ imageKey: String) {
        let content = AWSUserFileManager.custom(key: "USEast1BucketManager").content(withKey: imageKey)
        print("removeImageS3:")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        content.removeRemoteContent(completionHandler: {
            (content: AWSContent?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    print("removeImageS3 error: \(error)")
                } else {
                    print("removeImageS3 success")
                    content?.removeLocal()
                }
            })
        })
    }
    
    fileprivate func getUserRelationship(_ followingId: String, indexPath: IndexPath) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getUserRelationshipDynamoDB(followingId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getUserRelationship error: \(error)")
                } else {
                    self.isFollowing = (task.result != nil)
                    self.hasUserRelationshipLoaded = true
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                }
            })
            return nil
        })
    }
    
    // Followings are done in background.
    fileprivate func followUser(_ followingId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserRelationshipDynamoDB(followingId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("followUser error: \(error)")
                }
            })
            return nil
        })
    }
    
    fileprivate func unfollowUser(_ followingId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removeUserRelationshipDynamoDB(followingId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("unfollowUser error: \(error)")
                }
            })
            return nil
        })
    }
    
    fileprivate func signOut() {
        AWSClientManager.defaultClientManager().signOut({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                if let error = task.error {
                    print("signOut error: \(error)")
                } else {
                    self.redirectToOnboarding()
                }
            })
            return nil
        })
    }
    
    // MARK: Helpers
    
    fileprivate func redirectToOnboarding() {
        guard let window = UIApplication.shared.keyWindow,
            let initialViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
}

extension ProfileTableViewController: ProfileMainTableViewCellDelegate {
    
    func numberOfPostsButtonTapped() {
        if self.posts.count > 0 {
            let indexPath = IndexPath(row: 0, section: 1)
            self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    func numberOfFollowersButtonTapped() {
        self.performSegue(withIdentifier: "segueToUsersVc", sender: self)
    }
    
    func numberOfRecommendationsButtonTapped() {
        // TODO
    }
    
    func followButtonTapped() {
        if self.hasUserRelationshipLoaded {
            if self.isCurrentUser {
                self.performSegue(withIdentifier: "segueToEditProfileVc", sender: self)
            } else {
                guard let user = self.user, let followingId = user.userId else {
                    return
                }
                let numberOfFollowers = (user.numberOfFollowers != nil) ? user.numberOfFollowers! : 0
                let numberOfFollowersInteger = numberOfFollowers.intValue
                if self.isFollowing {
                    self.isFollowing = false
                    self.user?.numberOfFollowers = NSNumber(value: (numberOfFollowersInteger - 1) as Int)
                    self.unfollowUser(followingId)
                } else {
                    self.isFollowing = true
                    user.numberOfFollowers = NSNumber(value: (numberOfFollowersInteger + 1) as Int)
                    self.followUser(followingId)
                }
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
            }
        }
    }
}

extension ProfileTableViewController: ProfileSegmentedControlTableViewCellDelegate {
    
    func segmentChanged(profileSegment: ProfileSegment) {
        self.selectedProfileSegment = profileSegment
        self.tableView.reloadData()
    }
}

extension ProfileTableViewController: ProfileTableSectionHeaderDelegate {
    
    func editButtonTapped() {
        self.performSegue(withIdentifier: "segueToExperiencesVc", sender: self)
    }
}

extension ProfileTableViewController: EmptyTableViewCellDelegate {
    
    func addButtonTapped() {
        self.performSegue(withIdentifier: "segueToExperiencesVc", sender: self)
    }
}

extension ProfileTableViewController: ExperiencesTableViewControllerDelegate {
    
    func workExperiencesUpdated(_ workExperiences: [WorkExperience]) {
        self.workExperiences = workExperiences
        if self.selectedProfileSegment == ProfileSegment.experience {
            self.tableView.reloadSections(IndexSet([2, 3, 4]), with: UITableViewRowAnimation.none)
        }
    }
    
    func educationsUpdated(_ educations: [Education]) {
        self.educations = educations
        if self.selectedProfileSegment == ProfileSegment.experience {
            self.tableView.reloadSections(IndexSet([2, 3, 4]), with: UITableViewRowAnimation.none)
        }
    }
}
