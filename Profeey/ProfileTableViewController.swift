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
    case skills
}

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    var user: User?
    var isCurrentUser: Bool = false
    
    fileprivate var isLoadingUser = false
    
    fileprivate var hasRecommendationLoaded = false
    fileprivate var isRecommending: Bool = false
    
    fileprivate var hasRelationshipLoaded = false
    fileprivate var isFollowing: Bool = false
    
    fileprivate var selectedProfileSegment: ProfileSegment = ProfileSegment.posts
    
    fileprivate var posts: [Post] = []
    fileprivate var isLoadingInitialPosts: Bool = false
    fileprivate var isLoadingNextPosts: Bool = false
    fileprivate var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    //fileprivate var isRefreshingPosts: Bool = false
    
    fileprivate var isLoadingWorkExperiences: Bool = false
    fileprivate var workExperiences: [WorkExperience] = []
    fileprivate var isLoadingEducations: Bool = false
    fileprivate var educations: [Education] = []
    fileprivate var isLoadingExperiences: Bool {
        return self.isLoadingWorkExperiences || self.isLoadingEducations
    }
    fileprivate var isEmptyExperiences: Bool {
        return (self.workExperiences.count == 0 && self.educations.count == 0)
    }
    
    fileprivate var isLoadingUserCategories: Bool = false
    fileprivate var userCategories: [UserCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = self.user?.preferredUsername
        
        // Register custom headers.
        self.tableView.register(UINib(nibName: "ProfileTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "profileTableSectionHeader")
        
        self.configureUser()
        self.settingsButton.image = self.isCurrentUser ? UIImage(named: "ic_settings") : UIImage(named: "ic_mail")
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUserNotification(_:)), name: NSNotification.Name(UpdateUserNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.createPostNotification(_:)), name: NSNotification.Name(CreatePostNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePostNotification(_:)), name: NSNotification.Name(UpdatePostNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deletePostNotification(_:)), name: NSNotification.Name(DeletePostNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.createLikeNotification(_:)), name: NSNotification.Name(CreateLikeNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteLikeNotification(_:)), name: NSNotification.Name(DeleteLikeNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.createCommentNotification(_:)), name: NSNotification.Name(CreateCommentNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteCommentNotification(_:)), name: NSNotification.Name(DeleteCommentNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.followUserNotification(_:)), name: NSNotification.Name(FollowUserNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.unfollowUserNotification(_:)), name: NSNotification.Name(UnfollowUserNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.recommendUserNotification(_:)), name: NSNotification.Name(RecommendUserNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.unrecommendUserNotification(_:)), name: NSNotification.Name(UnrecommendUserNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureUser() {
        guard let identityId = AWSIdentityManager.defaultIdentityManager().identityId else {
            print("No currentUserId!")
            return
        }
        if self.isCurrentUser {
            // Comes from MainTabBarVc.
            if PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB == nil {
                self.user = CurrentUser(userId: identityId)
            } else {
                self.user = PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB
            }
            self.isLoadingUser = true
            self.isLoadingInitialPosts = true
            self.isLoadingWorkExperiences = true
            self.isLoadingEducations = true
            self.isLoadingUserCategories = true
            self.getUser(identityId)
        } else {
            // Comes from other Vc-s.
            guard let userId = user?.userId else {
                print("No userId!")
                return
            }
            self.isCurrentUser = (userId == identityId)
            self.isLoadingUser = true
            self.isLoadingInitialPosts = true
            self.isLoadingWorkExperiences = true
            self.isLoadingEducations = true
            self.isLoadingUserCategories = true
            self.getUser(userId)
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? EditProfileTableViewController {
            childViewController.user = self.user?.copyEditUser()
        }
        if let destinationViewController = segue.destination as? FollowersFollowingViewController {
            destinationViewController.userId = self.user?.userId
        }
        if let destinationViewController = segue.destination as? ExperiencesTableViewController {
            destinationViewController.workExperiences = self.workExperiences.map( { $0.copyWorkExperience() })
            destinationViewController.educations = self.educations.map( { $0.copyEducation() })
            destinationViewController.experiencesTableViewControllerDelegate = self
        }
        if let destinationViewController = segue.destination as? PostDetailsTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.post = self.posts[indexPath.row].copyPost()
        }
        if let destinationViewController = segue.destination as? UserCategoryTableViewController,
            let cell = sender as? UserCategoryTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.user = self.user?.copyUser()
            destinationViewController.userCategory = self.userCategories[indexPath.row]
        }
        if let destinationViewController = segue.destination as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? AddRecommendationTableViewController {
            childViewController.user = self.user?.copyUser()
        }
        if let destinationViewController = segue.destination as? RecommendationsTableViewController {
            destinationViewController.userId = self.user?.userId
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
            if self.isLoadingInitialPosts || self.posts.count == 0 {
                return 1
            }
            return self.posts.count
        case 2:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return 0
            }
            if self.isLoadingExperiences || self.isEmptyExperiences {
                return 1
            }
            return self.workExperiences.count
        case 3:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return 0
            }
            return self.educations.count
        case 4:
            guard self.selectedProfileSegment == ProfileSegment.skills else {
                return 0
            }
            if self.isLoadingUserCategories || self.userCategories.count == 0 {
                return 1
            }
            return self.userCategories.count
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
                cell.profilePicImageView.image = self.user?.profilePicUrl != nil ? self.user?.profilePic : UIImage(named: "ic_no_profile_pic_profile")
                cell.numberOfPostsButton.setTitle(self.user?.numberOfPostsInt.numberToString(), for: UIControlState.normal)
                cell.numberOfFollowersButton.setTitle(self.user?.numberOfFollowersInt.numberToString(), for: UIControlState.normal)
                cell.numberOfRecommendationsButton.setTitle(self.user?.numberOfRecommendationsInt.numberToString(), for: UIControlState.normal)
                if self.isCurrentUser {
                    cell.recommendButton.isHidden = true
                    if !self.isLoadingUser {
                       cell.setEditButton()
                    }
                } else {
                    cell.recommendButton.isHidden = false
                    if self.hasRecommendationLoaded {
                        self.isRecommending ? cell.setRecommendingButton() : cell.setRecommendButton()
                    }
                    if self.hasRelationshipLoaded {
                        self.isFollowing ? cell.setFollowingButton() : cell.setFollowButton()
                    }
                }
                cell.profileMainTableViewCellDelegate = self
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileInfo", for: indexPath) as! ProfileInfoTableViewCell
                cell.fullNameLabel.text = self.user?.fullName
                cell.professionNameLabel.text = self.user?.professionName
                cell.locationNameLabel.text = self.user?.locationName
                cell.locationStackView.isHidden = self.user?.locationName != nil ? false : true
                cell.aboutLabel.text = self.user?.about
                
                cell.websiteButton.setTitle(self.user?.website, for: UIControlState.normal)
                cell.websiteButton.isHidden = self.user?.website != nil ? false : true
                cell.profileInfoTableViewCellDelegate = self
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileSegmentedControl", for: indexPath) as! ProfileSegmentedControlTableViewCell
                cell.profileSegmentedControlTableViewCellDelegate = self
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            if self.isLoadingInitialPosts {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellLoading", for: indexPath) as! LoadingTableViewCell
                cell.activityIndicator?.startAnimating()
                return cell
            }
            if self.posts.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileEmpty", for: indexPath) as! ProfileEmptyTableViewCell
                cell.emptyMessageLabel.text = "No posts yet."
                UIView.performWithoutAnimation {
                    cell.addButton.setTitle("Add Post", for: UIControlState.normal)
                    cell.addButton.layoutIfNeeded()
                }
                cell.addButton.isHidden = self.isCurrentUser ? false : true
                cell.addButtonType = AddButtonType.post
                cell.profileEmptyTableViewCellDelegate = self
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileEmpty", for: indexPath) as! ProfileEmptyTableViewCell
                cell.emptyMessageLabel.text = "No experiences yet."
                UIView.performWithoutAnimation {
                    cell.addButton.setTitle("Add Experience", for: UIControlState.normal)
                    cell.addButton.layoutIfNeeded()
                }
                cell.addButton.isHidden = self.isCurrentUser ? false : true
                cell.addButtonType = AddButtonType.experience
                cell.profileEmptyTableViewCellDelegate = self
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellWorkExperience", for: indexPath) as! WorkExperienceTableViewCell
            let workExperience = self.workExperiences[indexPath.row]
            cell.titleLabel.text = workExperience.title
            cell.organizationLabel.text = workExperience.organization
            cell.timePeriodLabel.text = workExperience.timePeriod
            cell.workDescriptionLabel.text = workExperience.workDescription
            workExperience.isExpandedWorkDescription ? cell.untruncate() : cell.truncate()
            cell.workExperienceTableViewCellDelegate = self
            cell.separatorViewLeftConstraint?.constant = (indexPath.row == self.workExperiences.count - 1) ? 0.0 : 12.0
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEducation", for: indexPath) as! EducationTableViewCell
            let education = self.educations[indexPath.row]
            cell.schoolLabel.text = education.school
            cell.fieldOfStudyLabel.text = education.fieldOfStudy
            cell.timePeriodLabel.text = education.timePeriod
            cell.educationDescriptionLabel.text = education.educationDescription
            education.isExpandedEducationDescription ? cell.untruncate() : cell.truncate()
            cell.educationTableViewCellDelegate = self
            cell.separatorViewLeftConstraint?.constant = (indexPath.row == self.educations.count - 1) ? 0.0 : 12.0
            return cell
        case 4:
            if self.isLoadingUserCategories {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellLoading", for: indexPath) as! LoadingTableViewCell
                cell.activityIndicator?.startAnimating()
                return cell
            }
            if self.userCategories.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileEmpty", for: indexPath) as! ProfileEmptyTableViewCell
                cell.emptyMessageLabel.text = "No posts with skills yet."
                UIView.performWithoutAnimation {
                    cell.addButton.setTitle("Add Post", for: UIControlState.normal)
                    cell.addButton.layoutIfNeeded()
                }
                cell.addButton.isHidden = self.isCurrentUser ? false : true
                cell.addButtonType = AddButtonType.post
                cell.profileEmptyTableViewCellDelegate = self
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellUserCategory", for: indexPath) as! UserCategoryTableViewCell
            let userCategory = self.userCategories[indexPath.row]
            cell.categoryNameLabel.text = userCategory.categoryName
            cell.numberOfPostsLabel.text = userCategory.numberOfPostsString
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is PostSmallTableViewCell {
            self.performSegue(withIdentifier: "segueToPostDetailsVc", sender: indexPath)
        }
        if cell is UserCategoryTableViewCell {
            self.performSegue(withIdentifier: "segueToUserCategoryVc", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        // Load next posts.
        guard !self.isLoadingInitialPosts else {
            return
        }
        guard indexPath.section == 1 else {
            return
        }
        guard indexPath.row == self.posts.count - 1 && !self.isLoadingNextPosts && self.lastEvaluatedKey != nil else {
            return
        }
        guard let userId = self.user?.userId else {
            return
        }
        self.isLoadingNextPosts = true
        self.queryUserPostsDateSorted(userId, startFromBeginning: false)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return 92.0
            case 1:
                return 107.0
            case 2:
                return 46.0
            default:
                return 0.0
            }
        case 1:
            if self.isLoadingInitialPosts || self.posts.count == 0 {
                return 112.0
            }
            return 112.0
        case 2:
            if self.isLoadingExperiences || self.isEmptyExperiences {
                return 112.0
            }
            return 105.0
        case 3:
            return 105.0
        case 4:
            return 42.0
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
            if self.isLoadingInitialPosts || self.posts.count == 0 {
                return 112.0
            }
            return 112.0
        case 2:
            if self.isLoadingExperiences || self.isEmptyExperiences {
                return 112.0
            }
            return UITableViewAutomaticDimension
        case 3:
            return UITableViewAutomaticDimension
        case 4:
            if self.isLoadingUserCategories || self.userCategories.count == 0 {
                return 112.0
            }
            return 50.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 2:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return UIView()
            }
            if self.isLoadingExperiences || self.workExperiences.count == 0 {
                return UIView()
            }
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "profileTableSectionHeader") as? ProfileTableSectionHeader
            header?.titleLabel?.text = "WORK EXPERIENCE"
            header?.editButton?.isHidden = self.isCurrentUser ? false : true
            header?.profileTableSectionHeaderDelegate = self
            return header
        case 3:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return UIView()
            }
            if self.isLoadingExperiences || self.educations.count == 0 {
                return UIView()
            }
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "profileTableSectionHeader") as? ProfileTableSectionHeader
            header?.titleLabel?.text = "EDUCATION"
            header?.editButton?.isHidden = self.isCurrentUser ? false : true
            header?.profileTableSectionHeaderDelegate = self
            return header
        default:
            return UIView()
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.0
        case 1:
            guard self.selectedProfileSegment == ProfileSegment.posts else {
                return 0.0
            }
            return 6.0
        case 2:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return 0.0
            }
            if self.isLoadingExperiences || self.isEmptyExperiences {
                return 6.0
            }
            if self.workExperiences.count == 0 {
                return 0.0
            }
            return 48.0
        case 3:
            guard self.selectedProfileSegment == ProfileSegment.experience else {
                return 0.0
            }
            if self.isLoadingExperiences {
                return 0.0
            }
            if self.educations.count == 0 {
                return 0.0
            }
            return 48.0
        case 4:
            guard self.selectedProfileSegment == ProfileSegment.skills else {
                return 0.0
            }
            if self.isLoadingUserCategories || self.userCategories.count == 0 {
                return 6.0
            }
            return 0.0
        default:
            return 0.0
        }
    }
    
    // MARK: IBActions
    
    @IBAction func settingsButtonTapped(_ sender: AnyObject) {
        if self.isCurrentUser {
            self.performSegue(withIdentifier: "segueToSettingsVc", sender: self)
        } else {
            // TODO
        }
    }
    
    @IBAction func unwindToProfileTableViewController(_ segue: UIStoryboardSegue) {
        // From PostDetailsVc on Post delete.
    }
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        guard !self.isLoadingUser else {
            self.refreshControl?.endRefreshing()
            return
        }
        guard let userId = self.user?.userId else {
            self.refreshControl?.endRefreshing()
            return
        }
        self.isLoadingUser = true
        self.getUser(userId)
    }
    
    // MARK: Helpers
    
    fileprivate func sortWorkExperiencesByToDate() {
        let currentWorkExperiences = self.workExperiences.filter( { $0.toMonthInt == nil && $0.toYearInt == nil } )
        let otherWorkExperiences = self.workExperiences.filter( { $0.toMonthInt != nil && $0.toYearInt != nil } )
        let sortedOtherWorkExperiences = otherWorkExperiences.sorted(by: {
            (workExperience1, workExperience2) in
            return workExperience1.toYearInt! == workExperience2.toYearInt! ? (workExperience1.toMonthInt! > workExperience2.toMonthInt!) : (workExperience1.toYearInt! > workExperience2.toYearInt!)
        })
        self.workExperiences = currentWorkExperiences + sortedOtherWorkExperiences
    }
    
    fileprivate func sortEducationsByToDate() {
        let currentEducations = self.educations.filter( { $0.toMonthInt == nil && $0.toYearInt == nil } )
        let otherEducations = self.educations.filter( { $0.toMonthInt != nil && $0.toYearInt != nil } )
        let sortedOtherEducations = otherEducations.sorted(by: {
            (education1, education2) in
            return education1.toYearInt! == education2.toYearInt! ? (education1.toMonthInt! > education2.toMonthInt!) : (education1.toYearInt! > education2.toYearInt!)
        })
        self.educations = currentEducations + sortedOtherEducations
    }
    
    fileprivate func sortUserCategories() {
        self.userCategories = self.userCategories.sorted(by: {
            (userCategory1, userCategory2) in
            return userCategory1.numberOfPostsInt > userCategory2.numberOfPostsInt
        })
        if self.selectedProfileSegment == ProfileSegment.skills {
            UIView.performWithoutAnimation {
                self.tableView.reloadSections(IndexSet([4]), with: UITableViewRowAnimation.none)
            }
        }
    }

    
    // MARK: AWS
    
    fileprivate func getUser(_ userId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getUserDynamoDB(userId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    print("getUser error: \(task.error!)")
                    // Reset flags and animations that were initiated.
                    self.isLoadingUser = false
                    self.isLoadingInitialPosts = false
                    self.isLoadingNextPosts = false
                    self.isLoadingWorkExperiences = false
                    self.isLoadingEducations = false
                    self.isLoadingUserCategories = false
                    self.refreshControl?.endRefreshing()
                    // Reload tableView.
                    self.tableView.reloadData()
                    // Handle error and show banner.
                    let nsError = task.error as! NSError
                    if nsError.code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        // TODO No internet connection tableBackgroundView.
                    }
                    return
                }
                guard let awsUser = task.result as? AWSUser else {
                    print("Not an awsUser. This should not happen.")
                    return
                }
                let user = FullUser(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationId: awsUser._locationId, locationName: awsUser._locationName, website: awsUser._website, about: awsUser._about, numberOfFollowers: awsUser._numberOfFollowers, numberOfPosts: awsUser._numberOfPosts, numberOfRecommendations: awsUser._numberOfRecommendations)
                self.user = user
                
                // Reset flags and animations that were initiated.
                self.isLoadingUser = false
                self.navigationItem.title = self.user?.preferredUsername
                self.refreshControl?.endRefreshing()
                
                // Reload tableView with downloaded user.
                UIView.performWithoutAnimation {
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.none)
                }
                
                // Load profilePic.
                if let profilePicUrl = awsUser._profilePicUrl {
                    PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                }
                
                // Load other data.
                if let userId = awsUser._userId {
                    if !self.isCurrentUser {
                        self.getRelationship(userId)
                        self.getRecommendation(userId)
                    }
                    self.queryUserPostsDateSorted(userId, startFromBeginning: true)
                    self.queryWorkExperiences(userId)
                    self.queryEducations(userId)
                    self.queryUserCategoriesNumberOfPostsSorted(userId)
                }
            })
            return nil
        })
    }
    
    fileprivate func queryUserPostsDateSorted(_ userId: String, startFromBeginning: Bool) {
        if startFromBeginning {
            self.lastEvaluatedKey = nil
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserPostsDateSortedDynamoDB(userId, lastEvaluatedKey: self.lastEvaluatedKey, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryUserPostsDateSorted error: \(error)")
                    self.isLoadingInitialPosts = false
                    self.isLoadingNextPosts = true // for bug
                    self.tableView.reloadData()
                    let nsError = error as! NSError
                    if nsError.code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        // TODO No internet connection tableBackgroundView.
                    }
                    return
                }
                if startFromBeginning {
                    self.posts = []
                }
                var numberOfNewPosts = 0
                if let awsPosts = response?.items as? [AWSPost] {
                    for awsPost in awsPosts {
                        let post = Post(userId: awsPost._userId, postId: awsPost._postId, creationDate: awsPost._creationDate, caption: awsPost._caption, categoryName: awsPost._categoryName, imageUrl: awsPost._imageUrl, imageWidth: awsPost._imageWidth, imageHeight: awsPost._imageHeight, numberOfLikes: awsPost._numberOfLikes, numberOfComments: awsPost._numberOfComments, user: self.user)
                        self.posts.append(post)
                        numberOfNewPosts += 1
                        // Immediately getLike.
                        // TODO
                    }
                }
                // Reset flags and animations that were initiated.
                self.isLoadingInitialPosts = false
                self.isLoadingNextPosts = false
                self.lastEvaluatedKey = response?.lastEvaluatedKey
                
                // Reload tableView with downloaded posts.
                if self.selectedProfileSegment == ProfileSegment.posts {
                    if startFromBeginning || numberOfNewPosts > 0 {
                        self.tableView.reloadData()
                    }
                }
                
                // Load posts images.
                if let awsPosts = response?.items as? [AWSPost] {
                    for awsPost in awsPosts {
                        if let imageUrl = awsPost._imageUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(imageUrl, imageType: .postPic)
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
                guard error == nil else {
                    print("queryWorkExperiences error: \(error!)")
                    self.isLoadingWorkExperiences = false
                    self.tableView.reloadData()
                    return
                }
                self.workExperiences = []
                if let awsWorkExperiences = response?.items as? [AWSWorkExperience] {
                    for awsWorkExperience in awsWorkExperiences {
                        let workExperience = WorkExperience(userId: awsWorkExperience._userId, workExperienceId: awsWorkExperience._workExperienceId, title: awsWorkExperience._title, organization: awsWorkExperience._organization, workDescription: awsWorkExperience._workDescription, fromMonth: awsWorkExperience._fromMonth, fromYear: awsWorkExperience._fromYear, toMonth: awsWorkExperience._toMonth, toYear: awsWorkExperience._toYear)
                        self.workExperiences.append(workExperience)
                    }
                    self.sortWorkExperiencesByToDate()
                }
                
                // Reset flags and animations that were initiated.
                self.isLoadingWorkExperiences = false
                
                // Reload tableView with downloaded workExperiences.
                if self.selectedProfileSegment == ProfileSegment.experience {
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet([2, 3]), with: UITableViewRowAnimation.none)
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
                guard error == nil else {
                    print("queryEducations error: \(error!)")
                    self.isLoadingEducations = false
                    self.tableView.reloadData()
                    return
                }
                self.educations = []
                if let awsEducations = response?.items as? [AWSEducation] {
                    for awsEducation in awsEducations {
                        let education = Education(userId: awsEducation._userId, educationId: awsEducation._educationId, school: awsEducation._school, fieldOfStudy: awsEducation._fieldOfStudy, educationDescription: awsEducation._educationDescription, fromMonth: awsEducation._fromMonth, fromYear: awsEducation._fromYear, toMonth: awsEducation._toMonth, toYear: awsEducation._toYear)
                        self.educations.append(education)
                    }
                    self.sortEducationsByToDate()
                }
                
                // Reset flags and animations that were initiated.
                self.isLoadingEducations = false
                
                // Reload tableView with downloaded educations.
                if self.selectedProfileSegment == ProfileSegment.experience {
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet([2, 3]), with: UITableViewRowAnimation.none)
                    }
                }
            })
        })
    }
    
    fileprivate func queryUserCategoriesNumberOfPostsSorted(_ userId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserCategoriesNumberOfPostsSortedDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryUserCategoriesNumberOfPostsSorted error: \(error!)")
                    self.isLoadingUserCategories = false
                    self.tableView.reloadData()
                    return
                }
                self.userCategories = []
                if let awsUserCategories = response?.items as? [AWSUserCategory] {
                    for awsUserCategory in awsUserCategories {
                        let userCategory = UserCategory(userId: awsUserCategory._userId, categoryName: awsUserCategory._categoryName, numberOfPosts: awsUserCategory._numberOfPosts)
                        self.userCategories.append(userCategory)
                    }
                    self.sortUserCategories()
                }
                
                // Reset flags and animations that were initiated.
                self.isLoadingUserCategories = false
                
                // Reload tableView with downloaded userCategories.
                if self.selectedProfileSegment == ProfileSegment.skills {
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet([4]), with: UITableViewRowAnimation.none)
                    }
                }
            })
        })
    }
    
    fileprivate func getRelationship(_ followingId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getRelationshipDynamoDB(followingId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getRelationship error: \(error)")
                } else {
                    self.isFollowing = (task.result != nil)
                    self.hasRelationshipLoaded = true
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
                }
            })
            return nil
        })
    }
    
    // In background.
    fileprivate func followUser(_ followingId: String, followingFirstName: String?, followingLastName: String?, followingPreferredUsername: String?, followingProfessionName: String?, followingProfilePicUrl: String?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createRelationshipDynamoDB(followingId, followingFirstName: followingFirstName, followingLastName: followingLastName, followingPreferredUsername: followingPreferredUsername, followingProfessionName: followingProfessionName, followingProfilePicUrl: followingProfilePicUrl, completionHandler: {
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
    
    // In background.
    fileprivate func unfollowUser(_ followingId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removeRelationshipDynamoDB(followingId, completionHandler: {
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
    
    fileprivate func getRecommendation(_ recommendingId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getRecommendationDynamoDB(recommendingId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getRecommendation error: \(error)")
                } else {
                    self.isRecommending = (task.result != nil)
                    self.hasRecommendationLoaded = true
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
                }
            })
            return nil
        })
    }
    
    // In background.
    fileprivate func removeRecommendation(_ recommendingId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removeRecommendationDynamoDB(recommendingId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("removeRecommendation error: \(error)")
                }
            })
            return nil
        })
    }
}

extension ProfileTableViewController {
    
    // MARK: NotificationCenterActions
    
    func updateUserNotification(_ notification: NSNotification) {
        guard let editUser = notification.userInfo?["user"] as? EditUser else {
            return
        }
        guard self.user?.userId == editUser.userId else {
            return
        }
        self.user?.firstName = editUser.firstName
        self.user?.lastName = editUser.lastName
        self.user?.professionName = editUser.professionName
        self.user?.profilePicUrl = editUser.profilePicUrl
        self.user?.locationId = editUser.locationId
        self.user?.locationName = editUser.locationName
        self.user?.about = editUser.about
        self.user?.website = editUser.website
        self.user?.profilePic = editUser.profilePic
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.none)
        // Remove old profilePic in background.
        if let profilePicUrlToRemove = notification.userInfo?["profilePicUrlToRemove"] as? String {
            PRFYS3Manager.defaultS3Manager().removeImageS3(profilePicUrlToRemove)
        }
    }
    
    func createPostNotification(_ notification: NSNotification) {
        guard let post = notification.userInfo?["post"] as? Post else {
            return
        }
        guard self.user?.userId == post.userId else {
            return
        }
        self.posts.insert(post, at: 0)
        if self.selectedProfileSegment == ProfileSegment.posts {
            if self.posts.count == 1 {
                // To remove Add Posts button.
                self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
            } else {
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: UITableViewRowAnimation.none)
            }
        }
        // Update numberOfPosts.
        if let numberOfPosts = self.user?.numberOfPosts {
            self.user?.numberOfPosts = NSNumber(value: numberOfPosts.intValue + 1)
        } else {
            self.user?.numberOfPosts = NSNumber(value: 1)
        }
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
        // Update UserCategory.
        if let categoryName = post.categoryName {
            if let userCategoyIndex = self.userCategories.index(where: { $0.categoryName == categoryName }) {
                self.userCategories[userCategoyIndex].numberOfPosts = NSNumber(value: self.userCategories[userCategoyIndex].numberOfPostsInt + 1)
            } else {
                self.userCategories.append(UserCategory(userId: self.user?.userId, categoryName: categoryName, numberOfPosts: NSNumber(value: 1)))
            }
            self.sortUserCategories()
        }
    }
    
    func updatePostNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        let post = self.posts[postIndex]
        let oldCategoryName = post.categoryName
        post.caption = notification.userInfo?["caption"] as? String
        post.categoryName = notification.userInfo?["categoryName"] as? String
        if self.selectedProfileSegment == ProfileSegment.posts {
            self.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 1)], with: UITableViewRowAnimation.none)
        }
        // Update UserCategories.
        if let categoryName = post.categoryName {
            if let userCategoyIndex = self.userCategories.index(where: { $0.categoryName == categoryName }) {
                self.userCategories[userCategoyIndex].numberOfPosts = NSNumber(value: self.userCategories[userCategoyIndex].numberOfPostsInt + 1)
            } else {
                self.userCategories.append(UserCategory(userId: self.user?.userId, categoryName: categoryName, numberOfPosts: NSNumber(value: 1)))
            }
            self.sortUserCategories()
        }
        if let categoryName = oldCategoryName {
            if let userCategoyIndex = self.userCategories.index(where: { $0.categoryName == categoryName }) {
                self.userCategories[userCategoyIndex].numberOfPosts = NSNumber(value: self.userCategories[userCategoyIndex].numberOfPostsInt - 1)
                if self.userCategories[userCategoyIndex].numberOfPostsInt == 0 {
                    self.userCategories.remove(at: userCategoyIndex)
                }
            }
            self.sortUserCategories()
        }
    }
    
    func deletePostNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        let oldCategoryName = self.posts[postIndex].categoryName
        self.posts.remove(at: postIndex)
        if self.selectedProfileSegment == ProfileSegment.posts {
            if self.posts.count == 0 {
                self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
            } else {
                self.tableView.deleteRows(at: [IndexPath(row: postIndex, section: 1)], with: UITableViewRowAnimation.none)
            }
        }
        // Update numberOfPosts
        if let numberOfPosts = self.user?.numberOfPosts {
            self.user?.numberOfPosts = NSNumber(value: numberOfPosts.intValue - 1)
        } else {
            self.user?.numberOfPosts = NSNumber(value: 0)
        }
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
        // Update UserCategory.
        if let categoryName = oldCategoryName {
            if let userCategoyIndex = self.userCategories.index(where: { $0.categoryName == categoryName }) {
                self.userCategories[userCategoyIndex].numberOfPosts = NSNumber(value: self.userCategories[userCategoyIndex].numberOfPostsInt - 1)
                if self.userCategories[userCategoyIndex].numberOfPostsInt == 0 {
                    self.userCategories.remove(at: userCategoyIndex)
                }
            }
            self.sortUserCategories()
        }
    }
    
    func createLikeNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        let post = self.posts[postIndex]
        post.numberOfLikes = NSNumber(value: post.numberOfLikesInt + 1)
        post.isLikedByCurrentUser = true
        self.tableView.reloadVisibleRow(IndexPath(row: postIndex, section: 1))
    }
    
    func deleteLikeNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        let post = self.posts[postIndex]
        post.numberOfLikes = NSNumber(value: post.numberOfLikesInt - 1)
        post.isLikedByCurrentUser = false
        self.tableView.reloadVisibleRow(IndexPath(row: postIndex, section: 1))
    }
    
    func createCommentNotification(_ notification: NSNotification) {
        guard let comment = notification.userInfo?["comment"] as? Comment else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == comment.postId }) else {
            return
        }
        let post = self.posts[postIndex]
        post.numberOfComments = NSNumber(value: post.numberOfCommentsInt + 1)
        self.tableView.reloadVisibleRow(IndexPath(row: postIndex, section: 1))
    }
    
    func deleteCommentNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String  else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        let post = self.posts[postIndex]
        post.numberOfComments = NSNumber(value: post.numberOfCommentsInt - 1)
        self.tableView.reloadVisibleRow(IndexPath(row: postIndex, section: 1))
    }
    
    func followUserNotification(_ notification: NSNotification) {
        guard let followingId = notification.userInfo?["followingId"] as? String else {
            return
        }
        guard self.user?.userId == followingId else {
            return
        }
        guard self.hasRelationshipLoaded, !self.isFollowing else {
            return
        }
        self.isFollowing = true
        if let numberOfFollowers = self.user?.numberOfFollowers {
            self.user?.numberOfFollowers = NSNumber(value: numberOfFollowers.intValue + 1)
        } else {
            self.user?.numberOfFollowers = NSNumber(value: 1)
        }
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
    }
    
    func unfollowUserNotification(_ notification: NSNotification) {
        guard let followingId = notification.userInfo?["followingId"] as? String else {
            return
        }
        guard self.user?.userId == followingId else {
            return
        }
        guard self.hasRelationshipLoaded, self.isFollowing else {
            return
        }
        self.isFollowing = false
        if let numberOfFollowers = self.user?.numberOfFollowers, numberOfFollowers.intValue > 0 {
            self.user?.numberOfFollowers = NSNumber(value: numberOfFollowers.intValue - 1)
        } else {
            self.user?.numberOfFollowers = NSNumber(value: 0)
        }
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
    }
    
    func recommendUserNotification(_ notification: NSNotification) {
        guard let recommendingId = notification.userInfo?["recommendingId"] as? String else {
            return
        }
        guard self.user?.userId == recommendingId, self.hasRecommendationLoaded, !self.isRecommending else {
            return
        }
        self.isRecommending = true
        if let numberOfRecommendations = self.user?.numberOfRecommendations {
            self.user?.numberOfRecommendations = NSNumber(value: numberOfRecommendations.intValue + 1)
        } else {
            self.user?.numberOfRecommendations = NSNumber(value: 1)
        }
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
    }
    
    func unrecommendUserNotification(_ notification: NSNotification) {
        guard let recommendingId = notification.userInfo?["recommendingId"] as? String else {
            return
        }
        guard self.user?.userId == recommendingId, self.hasRecommendationLoaded, self.isRecommending else {
            return
        }
        self.isRecommending = false
        if let numberOfRecommendations = self.user?.numberOfRecommendations, numberOfRecommendations.intValue > 0 {
            self.user?.numberOfRecommendations = NSNumber(value: numberOfRecommendations.intValue - 1)
        } else {
            self.user?.numberOfRecommendations = NSNumber(value: 0)
        }
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
    }
    
    func downloadImageNotification(_ notification: NSNotification) {
        guard let imageKey = notification.userInfo?["imageKey"] as? String, let imageType = notification.userInfo?["imageType"] as? ImageType, let imageData = notification.userInfo?["imageData"] as? Data else {
            return
        }
        switch imageType {
        case .userProfilePic:
            guard self.user?.profilePicUrl == imageKey else {
                return
            }
            self.user?.profilePic = UIImage(data: imageData)
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
            }
        case .postPic:
            guard let postIndex = self.posts.index(where: { $0.imageUrl == imageKey }) else {
                return
            }
            self.posts[postIndex].image = UIImage(data: imageData)
            // Reload if visible.
            self.tableView.reloadVisibleRow(IndexPath(row: postIndex, section: 1))
        }
    }
    
    // MARK: Public
    
    func profileTabBarButtonTapped() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
    }
}

extension ProfileTableViewController: ProfileMainTableViewCellDelegate {
    
    func numberOfPostsButtonTapped() {
        if self.posts.count > 0 && self.selectedProfileSegment == ProfileSegment.posts {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    func numberOfFollowersButtonTapped() {
        self.performSegue(withIdentifier: "segueToFollowersFollowingVc", sender: self)
    }
    
    func numberOfRecommendationsButtonTapped() {
        self.performSegue(withIdentifier: "segueToRecommendationsVc", sender: self)
    }
    
    func followButtonTapped() {
        if self.isCurrentUser, !self.isLoadingUser {
            self.performSegue(withIdentifier: "segueToEditProfileVc", sender: self)
        } else {
            if self.hasRelationshipLoaded, let followingId = self.user?.userId {
                if self.isFollowing {
                    let message = ["Unfollow", self.user?.preferredUsername].flatMap({ $0 }).joined(separator: " ") + "?"
                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
                    // DELETE
                    let deleteAction = UIAlertAction(title: "Unfollow", style: UIAlertActionStyle.destructive, handler: {
                        (alert: UIAlertAction) in
                        // DynamoDB and Notify observers (self also).
                        self.unfollowUser(followingId)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UnfollowUserNotificationKey), object: self, userInfo: ["followingId": followingId])
                    })
                    alertController.addAction(deleteAction)
                    // CANCEL
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let followingUser = self.user
                    self.followUser(followingId, followingFirstName: followingUser?.firstName, followingLastName: followingUser?.lastName, followingPreferredUsername: followingUser?.preferredUsername, followingProfessionName: followingUser?.professionName, followingProfilePicUrl: followingUser?.profilePicUrl)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: FollowUserNotificationKey), object: self, userInfo: ["followingId": followingId])
                }
            }
        }
    }
    
    func recommendButtonTapped() {
        if !self.isCurrentUser, self.hasRecommendationLoaded {
            if self.isRecommending, let recommendingId = self.user?.userId {
                let message = ["Unrecommend", self.user?.preferredUsername].flatMap({ $0 }).joined(separator: " ") + "?"
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
                // DELETE
                let deleteAction = UIAlertAction(title: "Unrecommend", style: UIAlertActionStyle.destructive, handler: {
                    (alert: UIAlertAction) in
                    // DynamoDB and Notify observers (self also).
                    self.removeRecommendation(recommendingId)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: UnrecommendUserNotificationKey), object: self, userInfo: ["recommendingId": recommendingId])
                })
                alertController.addAction(deleteAction)
                // CANCEL
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "segueToAddRecommendationVc", sender: self)
            }
        }
    }
}

extension ProfileTableViewController: ProfileInfoTableViewCellDelegate {
    
    func websiteButtonTapped() {
        // TODO
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

extension ProfileTableViewController: ProfileEmptyTableViewCellDelegate {
    
    func addButtonTapped(_ addButtonType: AddButtonType) {
        switch addButtonType {
        case .post:
            self.performSegue(withIdentifier: "segueToCaptureVc", sender: self)
        case .experience:
            self.performSegue(withIdentifier: "segueToExperiencesVc", sender: self)
        }
    }
}

extension ProfileTableViewController: ExperiencesTableViewControllerDelegate {
    
    func workExperiencesUpdated(_ workExperiences: [WorkExperience]) {
        self.workExperiences = workExperiences
        self.sortWorkExperiencesByToDate()
        if self.selectedProfileSegment == ProfileSegment.experience {
            UIView.performWithoutAnimation {
                self.tableView.reloadSections(IndexSet([2, 3]), with: UITableViewRowAnimation.none)
            }
        }
    }
    
    func educationsUpdated(_ educations: [Education]) {
        self.educations = educations
        self.sortEducationsByToDate()
        if self.selectedProfileSegment == ProfileSegment.experience {
            UIView.performWithoutAnimation {
                self.tableView.reloadSections(IndexSet([2, 3]), with: UITableViewRowAnimation.none)
            }
        }
    }
}

extension ProfileTableViewController: WorkExperienceTableViewCellDelegate {
    
    func workDescriptionLabelTapped(_ cell: WorkExperienceTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        if !self.workExperiences[indexPath.row].isExpandedWorkDescription {
            self.workExperiences[indexPath.row].isExpandedWorkDescription = true
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }
        }
    }
}

extension ProfileTableViewController: EducationTableViewCellDelegate {
    
    func educationDescriptionLabelTapped(_ cell: EducationTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        if !self.educations[indexPath.row].isExpandedEducationDescription {
            self.educations[indexPath.row].isExpandedEducationDescription = true
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }
        }
    }
}
