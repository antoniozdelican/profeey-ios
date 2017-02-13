//
//  ProfileTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit
import PhotosUI
import AWSDynamoDB
import AWSMobileHubHelper

enum ProfileSegment {
    case posts
    case experience
    case skills
}

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet var loadingTableFooterView: UIView!
    
    var user: User?
    var isCurrentUser: Bool = false
    
    fileprivate var isLoadingUser = true
    fileprivate var isLoadingRecommendation = true
    fileprivate var isRecommending: Bool = false
    fileprivate var isLoadingRelationship = true
    fileprivate var isFollowing: Bool = false
    
    fileprivate var posts: [Post] = []
    fileprivate var isLoadingPosts: Bool = false
    fileprivate var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    fileprivate var hasLoadedInitialPosts: Bool = false
    
    fileprivate var isLoadingWorkExperiences: Bool = false
    fileprivate var workExperiences: [Experience] = []
    fileprivate var hasLoadedInitialWorkExperiences: Bool = false
    
    fileprivate var isLoadingEducations: Bool = false
    fileprivate var educations: [Experience] = []
    fileprivate var hasLoadedInitialEducations: Bool = false
    
    fileprivate var experiences: [Experience] {
        return self.workExperiences + self.educations
    }
    fileprivate var isLoadingExperiences: Bool {
        return self.isLoadingWorkExperiences || self.isLoadingEducations
    }
    fileprivate var hasLoadedInitialExperiences: Bool {
        return self.hasLoadedInitialWorkExperiences && self.hasLoadedInitialEducations
    }
    
    fileprivate var isLoadingUserCategories: Bool = false
    fileprivate var userCategories: [UserCategory] = []
    fileprivate var hasLoadedInitialUserCategories: Bool = false
    
    fileprivate var selectedProfileSegment: ProfileSegment = ProfileSegment.posts
    fileprivate var noNetworkConnection: Bool = false
    fileprivate var settingsButton: UIBarButtonItem?
    fileprivate var isSettingsButtonSet: Bool = false
    
    fileprivate var discoverPeopleBarButtonItem: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = self.user?.preferredUsername
        
        // Register custom header.
        self.tableView.register(UINib(nibName: "ProfileSegmentedControlSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "profileSegmentedControlSectionHeader")
        
        // Initialize settings button.
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.hidesWhenStopped = true
        self.settingsButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = self.settingsButton
        activityIndicator.startAnimating()
        
        // Configure user and start querying.
        self.configureUser()
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUserNotification(_:)), name: NSNotification.Name(UpdateUserNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateEmailNotification(_:)), name: NSNotification.Name(UpdateEmailNotificationKey), object: nil)
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
        // In case it comes from MainTabBarVc we need to initialize user.
        if self.isCurrentUser {
            if PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB == nil {
                self.user = CurrentUser(userId: identityId)
            } else {
                self.user = PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB
            }
            // Set discover people button only here and not when comming from other Vcs on own profile.
            self.discoverPeopleBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_discover_people"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.discoverPeopleBarButtonTapped(_:)))
            self.navigationItem.leftBarButtonItem = self.discoverPeopleBarButtonItem
        }
        // Comes from other Vc-s.
        guard let userId = user?.userId else {
            print("No userId!")
            return
        }
        // Check if it's current again.
        self.isCurrentUser = (userId == identityId)
        
        // Query user.
        self.isLoadingUser = true
        self.getUser(userId)
        // Query other.
        switch self.selectedProfileSegment {
        case .posts:
            self.isLoadingPosts = true
            self.tableView.tableFooterView = self.loadingTableFooterView
            self.queryPostsDateSorted(userId, startFromBeginning: true)
        case .experience:
            self.isLoadingWorkExperiences = true
            self.isLoadingEducations = true
            self.tableView.tableFooterView = self.loadingTableFooterView
            self.queryWorkExperiences(userId)
            self.queryEducations(userId)
            break
        case .skills:
            self.isLoadingUserCategories = true
            self.tableView.tableFooterView = self.loadingTableFooterView
            self.queryUserCategoriesNumberOfPostsSorted(userId)
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? EditProfileTableViewController {
            childViewController.user = self.user?.copyEditUser()
        }
        if let destinationViewController = segue.destination as? SettingsTableViewController {
            destinationViewController.user = self.user?.copyEditUser()
            destinationViewController.currentEmail = self.user?.email
            destinationViewController.currentEmailVerified = self.user?.emailVerified
            destinationViewController.isFacebookUser = self.user?.isFacebookUser
        }
        if let destinationViewController = segue.destination as? FollowersFollowingViewController {
            destinationViewController.userId = self.user?.userId
        }
        if let destinationViewController = segue.destination as? ExperiencesTableViewController {
            if let workExperiences = self.workExperiences as? [WorkExperience] {
                destinationViewController.workExperiences = workExperiences.map( { $0.copyWorkExperience() })
            }
            if let educations = self.educations as? [Education] {
                destinationViewController.educations = educations.map( { $0.copyEducation() })
            }
            destinationViewController.experiencesTableViewControllerDelegate = self
        }
        if let destinationViewController = segue.destination as? PostDetailsViewController,
            let cell = sender as? PostSmallTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            // For bug.
            if self.posts[indexPath.row].user is CurrentUser {
                self.posts[indexPath.row].user = self.user
            }
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
        if let destinationViewController = segue.destination as? MessagesViewController {
            destinationViewController.participant = self.user?.copyUser()
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        if self.noNetworkConnection {
            return 1
        }
        switch self.selectedProfileSegment {
        case .posts:
            if !self.isLoadingPosts && self.posts.count == 0 {
                return 1
            }
            return self.posts.count
        case .experience:
            if self.isLoadingExperiences {
                return 0
            }
            if self.experiences.count == 0 {
                return 1
            }
            var experiencesCount = self.experiences.count
            if self.workExperiences.count > 0 {
                experiencesCount += 1
            }
            if self.educations.count > 0 {
                experiencesCount += 1
            }
            return experiencesCount
        case .skills:
            if !self.isLoadingUserCategories && self.userCategories.count == 0 {
                return 1
            }
            return self.userCategories.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileMain", for: indexPath) as! ProfileMainTableViewCell
                cell.profilePicImageView.image = self.user?.profilePicUrl != nil ? self.user?.profilePic : UIImage(named: "ic_no_profile_pic_profile")
                cell.numberOfPostsButton.setTitle(self.user?.numberOfPostsInt.numberToString(), for: UIControlState.normal)
                cell.numberOfFollowersButton.setTitle(self.user?.numberOfFollowersInt.numberToString(), for: UIControlState.normal)
                cell.numberOfRecommendationsButton.setTitle(self.user?.numberOfRecommendationsInt.numberToString(), for: UIControlState.normal)
                if self.isCurrentUser {
                    cell.recommendButton.isHidden = true
                    cell.recommendButtonWidthConstraint.constant = 0.0
                    if !self.isLoadingUser {
                        cell.setEditButton()
                    }
                } else {
                    cell.recommendButton.isHidden = false
                    if !self.isLoadingRecommendation {
                        self.isRecommending ? cell.setRecommendingButton() : cell.setRecommendButton()
                    }
                    if !self.isLoadingRelationship  {
                        self.isFollowing ? cell.setFollowingButton() : cell.setFollowButton()
                    }
                }
                cell.profileMainTableViewCellDelegate = self
                return cell
            default:
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
            }
        }
        if self.noNetworkConnection {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoNetwork", for: indexPath) as! NoNetworkTableViewCell
            return cell
        }
        switch self.selectedProfileSegment {
        case .posts:
            if self.posts.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileEmpty", for: indexPath) as! ProfileEmptyTableViewCell
                cell.emptyMessageLabel.text = "No posts yet."
                cell.addButton.isHidden = self.isCurrentUser ? false : true
                cell.addButtonType = AddButtonType.post
                cell.setAddPostButton()
                cell.profileEmptyTableViewCellDelegate = self
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostSmall", for: indexPath) as! PostSmallTableViewCell
            let post = self.posts[indexPath.row]
            cell.postImageView.image = post.image
            cell.titleLabel.text = post.caption
            cell.categoryNameLabel.text = post.categoryName
            cell.createdLabel.text = post.createdString
            cell.numberOfLikesLabel.text = post.numberOfLikesSmallString
            return cell
        case .experience:
            if self.experiences.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileEmpty", for: indexPath) as! ProfileEmptyTableViewCell
                cell.emptyMessageLabel.text = "No experiences yet."
                cell.addButton.isHidden = self.isCurrentUser ? false : true
                cell.addButtonType = AddButtonType.experience
                cell.setAddExperienceButton()
                cell.profileEmptyTableViewCellDelegate = self
                return cell
            }
            if self.workExperiences.count > 0 && indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellExperiencesHeader", for: indexPath) as! ExperiencesHeaderTableViewCell
                cell.titleLabel?.text = "WORK EXPERIENCE"
                if self.isCurrentUser {
                    cell.editButton?.isHidden = false
                    cell.experiencesHeaderTableViewCellDelegate = self
                } else {
                    cell.editButton?.isHidden = true
                    cell.experiencesHeaderTableViewCellDelegate = nil
                }
                return cell
            }
            if self.educations.count > 0 {
                if (self.workExperiences.count > 0 && indexPath.row == self.workExperiences.count + 1) || (self.workExperiences.count == 0 && indexPath.row == 0) {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cellExperiencesHeader", for: indexPath) as! ExperiencesHeaderTableViewCell
                    cell.titleLabel?.text = "EDUCATION"
                    if self.isCurrentUser {
                        cell.editButton?.isHidden = false
                        cell.experiencesHeaderTableViewCellDelegate = self
                    } else {
                        cell.editButton?.isHidden = true
                        cell.experiencesHeaderTableViewCellDelegate = nil
                    }
                    return cell
                }
            }
            // Calculating where are the headers and where experiences.
            var index: Int
            if self.workExperiences.count > 0 {
                if indexPath.row <= self.workExperiences.count {
                    index = indexPath.row - 1
                } else {
                    index = indexPath.row - 2
                }
            } else {
                index = indexPath.row - 1
            }
            // Configure experiences cells.
            let experience = self.experiences[index]
            if let experienceType = experience.experienceType, experienceType == .workExperience, let workExperience = experience as? WorkExperience {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellWorkExperience", for: indexPath) as! WorkExperienceTableViewCell
                cell.titleLabel.text = workExperience.title
                cell.organizationLabel.text = workExperience.organization
                cell.timePeriodLabel.text = workExperience.timePeriod
                cell.workDescriptionLabel.text = workExperience.workDescription
                workExperience.isExpandedWorkDescription ? cell.untruncate() : cell.truncate()
                cell.workExperienceTableViewCellDelegate = self
//                cell.separatorViewLeftConstraint?.constant = (indexPath.row == self.workExperiences.count) ? 0.0 : 12.0
                cell.separatorView.backgroundColor = (indexPath.row == self.workExperiences.count) ? UIColor.clear : Colors.greyLighter
                return cell
            } else if let experienceType = experience.experienceType, experienceType == .education, let education = experience as? Education {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellEducation", for: indexPath) as! EducationTableViewCell
                cell.schoolLabel.text = education.school
                cell.fieldOfStudyLabel.text = education.fieldOfStudy
                cell.timePeriodLabel.text = education.timePeriod
                cell.educationDescriptionLabel.text = education.educationDescription
                education.isExpandedEducationDescription ? cell.untruncate() : cell.truncate()
                cell.educationTableViewCellDelegate = self
                let lastIndex = (self.workExperiences.count > 0) ? self.experiences.count + 1 : self.experiences.count
//                cell.separatorViewLeftConstraint?.constant = (indexPath.row == lastIndex) ? 0.0 : 12.0
                cell.separatorView.backgroundColor = (indexPath.row == lastIndex) ? UIColor.clear : Colors.greyLighter
                return cell
            } else {
                return UITableViewCell()
            }
        case .skills:
            if self.userCategories.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileEmpty", for: indexPath) as! ProfileEmptyTableViewCell
                cell.emptyMessageLabel.text = "No posts with skills yet."
                cell.addButton.isHidden = self.isCurrentUser ? false : true
                cell.addButtonType = AddButtonType.post
                cell.setAddPostButton()
                cell.profileEmptyTableViewCellDelegate = self
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellUserCategory", for: indexPath) as! UserCategoryTableViewCell
            let userCategory = self.userCategories[indexPath.row]
            cell.categoryNameLabel.text = userCategory.categoryName
            cell.numberOfPostsLabel.text = userCategory.numberOfPostsString
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is PostSmallTableViewCell {
            self.performSegue(withIdentifier: "segueToPostDetailsVc", sender: cell)
        }
        if cell is UserCategoryTableViewCell {
            self.performSegue(withIdentifier: "segueToUserCategoryVc", sender: cell)
        }
        if cell is NoNetworkTableViewCell {
            guard let userId = self.user?.userId else {
                return
            }
            // Reset variables.
            self.hasLoadedInitialPosts = false
            self.hasLoadedInitialWorkExperiences = false
            self.hasLoadedInitialEducations = false
            self.hasLoadedInitialUserCategories = false
            // Query user.
            self.isLoadingUser = true
            self.getUser(userId)
            // Query other.
            switch self.selectedProfileSegment {
            case .posts:
                self.isLoadingPosts = true
                self.tableView.tableFooterView = self.loadingTableFooterView
                self.queryPostsDateSorted(userId, startFromBeginning: true)
            case .experience:
                self.isLoadingWorkExperiences = true
                self.isLoadingEducations = true
                self.tableView.tableFooterView = self.loadingTableFooterView
                self.queryWorkExperiences(userId)
                self.queryEducations(userId)
                break
            case .skills:
                self.isLoadingUserCategories = true
                self.tableView.tableFooterView = self.loadingTableFooterView
                self.queryUserCategoriesNumberOfPostsSorted(userId)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        // Query next posts.
        guard self.selectedProfileSegment == .posts else {
            return
        }
        guard indexPath.section == 1 && indexPath.row == self.posts.count - 1 && !self.isLoadingPosts && self.lastEvaluatedKey != nil else {
            return
        }
        guard let userId = self.user?.userId else {
            return
        }
        guard !self.noNetworkConnection else {
            return
        }
        self.isLoadingPosts = true
        self.tableView.tableFooterView = self.loadingTableFooterView
        self.queryPostsDateSorted(userId, startFromBeginning: false)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                return 92.0
            default:
                return 108.0
            }
        }
        if self.noNetworkConnection {
            return 112.0
        }
        switch self.selectedProfileSegment {
        case .posts:
            if self.posts.count == 0 {
                return 112.0
            }
            return 112.0
        case .experience:
            if self.experiences.count == 0 {
                return 112.0
            }
            if (indexPath.row == 0) || (self.workExperiences.count > 0 && indexPath.row == self.workExperiences.count + 1) {
                return 40.0
            }
            return 105.0
        case .skills:
            if self.userCategories.count == 0 {
                return 112.0
            }
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                return 92.0
            default:
                return UITableViewAutomaticDimension
            }
        }
        if self.noNetworkConnection {
            return 112.0
        }
        switch self.selectedProfileSegment {
        case .posts:
            if self.posts.count == 0 {
                return 112.0
            }
            return 112.0
        case .experience:
            if self.experiences.count == 0 {
                return 112.0
            }
            if (indexPath.row == 0) || (self.workExperiences.count > 0 && indexPath.row == self.workExperiences.count + 1) {
                return 40.0
            }
            return UITableViewAutomaticDimension
        case .skills:
            if self.userCategories.count == 0 {
                return 112.0
            }
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "profileSegmentedControlSectionHeader") as? ProfileSegmentedControlSectionHeader
            header?.profileSegmentedControlSectionHeaderDelegate = self
            return header
        }
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 44.0
        }
        return 0.0
    }
    
    // MARK: Tappers
    
    func settingsButtonTapped(_ sender: AnyObject) {
        if self.isCurrentUser {
            self.performSegue(withIdentifier: "segueToSettingsVc", sender: self)
        } else {
            self.performSegue(withIdentifier: "segueToMessagesVc", sender: self)
        }
    }
    
    func discoverPeopleBarButtonTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "segueToDiscoverPeopleVc", sender: self)
    }
    
    // MARK: IBActions
    
    @IBAction func unwindToProfileTableViewController(_ segue: UIStoryboardSegue) {
        // From PostDetailsVc on Post delete.
    }
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        guard let userId = self.user?.userId else {
            self.refreshControl?.endRefreshing()
            return
        }
        guard !self.isLoadingUser else {
            self.refreshControl?.endRefreshing()
            return
        }
        // Query user.
        self.isLoadingUser = true
        self.getUser(userId)
        
        // Query other.
        switch self.selectedProfileSegment {
        case .posts:
            guard !self.isLoadingPosts else {
                self.refreshControl?.endRefreshing()
                return
            }
            self.isLoadingPosts = true
            self.queryPostsDateSorted(userId, startFromBeginning: true)
        case .experience:
            guard !self.isLoadingExperiences else {
                self.refreshControl?.endRefreshing()
                return
            }
            self.isLoadingWorkExperiences = true
            self.isLoadingEducations = true
            self.queryWorkExperiences(userId)
            self.queryEducations(userId)
        case .skills:
            guard !self.isLoadingUserCategories else {
                self.refreshControl?.endRefreshing()
                return
            }
            self.isLoadingUserCategories = true
            self.queryUserCategoriesNumberOfPostsSorted(userId)
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
                    self.refreshControl?.endRefreshing()
                    if !self.isSettingsButtonSet {
                        self.navigationItem.rightBarButtonItem = nil
                    }
                    // Handle error and show banner.
                    if (task.error as! NSError).code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                    }
                    // Reload tableView.
                    self.tableView.reloadData()
                    return
                }
                guard let awsUser = task.result as? AWSUser else {
                    print("Not an awsUser. This should not happen.")
                    return
                }
                let user = FullUser(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationId: awsUser._locationId, locationName: awsUser._locationName, website: awsUser._website, about: awsUser._about, numberOfFollowers: awsUser._numberOfFollowers, numberOfPosts: awsUser._numberOfPosts, numberOfRecommendations: awsUser._numberOfRecommendations, email: awsUser._email, emailVerified: awsUser._emailVerified, isFacebookUser: awsUser._isFacebookUser)
                self.user = user
                
                // Reset flags and animations that were initiated.
                self.isLoadingUser = false
                self.navigationItem.title = self.user?.preferredUsername
                self.refreshControl?.endRefreshing()
                
                // Set/reinit settings button. This happens only once.
                if !self.isSettingsButtonSet {
                    self.isSettingsButtonSet = true
                    self.settingsButton = UIBarButtonItem(image: nil, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.settingsButtonTapped(_:)))
                    self.settingsButton?.image = self.isCurrentUser ? UIImage(named: "ic_settings") : UIImage(named: "ic_mail")
                    self.navigationItem.rightBarButtonItem = self.settingsButton
                }
                
                // Reload cells with downloaded user.
                if self.isCurrentUser {
                    (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.setEditButton()
                }
                let profileInfoTableViewCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ProfileInfoTableViewCell
                profileInfoTableViewCell?.fullNameLabel.text = self.user?.fullName
                profileInfoTableViewCell?.professionNameLabel.text = self.user?.professionName
                profileInfoTableViewCell?.locationNameLabel.text = self.user?.locationName
                profileInfoTableViewCell?.locationStackView.isHidden = self.user?.locationName != nil ? false : true
                profileInfoTableViewCell?.aboutLabel.text = self.user?.about
                profileInfoTableViewCell?.websiteButton.setTitle(self.user?.website, for: UIControlState.normal)
                profileInfoTableViewCell?.websiteButton.isHidden = self.user?.website != nil ? false : true
                self.tableView.reloadData()
                
                
                // Load profilePic.
                if let profilePicUrl = awsUser._profilePicUrl {
                    PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                }
                
                // Load relationship and recommendation.
                if let userId = awsUser._userId, !self.isCurrentUser {
                    self.getRelationship(userId)
                    self.getRecommendation(userId)
                }
            })
            return nil
        })
    }
    
    fileprivate func queryPostsDateSorted(_ userId: String, startFromBeginning: Bool) {
        if startFromBeginning {
            self.lastEvaluatedKey = nil
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryPostsDateSortedDynamoDB(userId, lastEvaluatedKey: self.lastEvaluatedKey, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryPostsDateSorted error: \(error)")
                    self.isLoadingPosts = false
                    self.hasLoadedInitialPosts = true
                    if (error as! NSError).code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                    }
                    if self.selectedProfileSegment == ProfileSegment.posts {
                        self.tableView.tableFooterView = UIView()
                        self.tableView.reloadData()
                    }
                    return
                }
                if startFromBeginning {
                    self.posts = []
                }
                var numberOfNewPosts = 0
                if let awsPosts = response?.items as? [AWSPost] {
                    for awsPost in awsPosts {
                        let post = Post(userId: awsPost._userId, postId: awsPost._postId, created: awsPost._created, caption: awsPost._caption, categoryName: awsPost._categoryName, imageUrl: awsPost._imageUrl, imageWidth: awsPost._imageWidth, imageHeight: awsPost._imageHeight, numberOfLikes: awsPost._numberOfLikes, numberOfComments: awsPost._numberOfComments, user: self.user)
                        self.posts.append(post)
                        numberOfNewPosts += 1
                        // TODO: Immediately getLike.
                    }
                }
                // Reset flags and animations that were initiated.
                self.isLoadingPosts = false
                self.hasLoadedInitialPosts = true
                self.noNetworkConnection = false
                self.lastEvaluatedKey = response?.lastEvaluatedKey
                
                // Reload tableView with downloaded posts.
                if self.selectedProfileSegment == ProfileSegment.posts {
                    self.tableView.tableFooterView = UIView()
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
                    print("queryWorkExperiences error: \(error)")
                    self.isLoadingWorkExperiences = false
                    self.hasLoadedInitialWorkExperiences = true
                    if (error as! NSError).code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                    }
                    if self.selectedProfileSegment == ProfileSegment.experience && !self.isLoadingExperiences {
                        self.tableView.tableFooterView = UIView()
                        self.tableView.reloadData()
                    }
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
                self.hasLoadedInitialWorkExperiences = true
                self.noNetworkConnection = false
                
                // Reload tableView with downloaded experiences.
                if self.selectedProfileSegment == ProfileSegment.experience && !self.isLoadingExperiences {
                    self.tableView.tableFooterView = UIView()
                    self.tableView.reloadData()
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
                    print("queryEducations error: \(error)")
                    self.isLoadingEducations = false
                    self.hasLoadedInitialEducations = true
                    if (error as! NSError).code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                    }
                    if self.selectedProfileSegment == ProfileSegment.experience && !self.isLoadingExperiences {
                        self.tableView.tableFooterView = UIView()
                        self.tableView.reloadData()
                    }
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
                self.hasLoadedInitialEducations = true
                self.noNetworkConnection = false
                
                // Reload tableView with downloaded experiences.
                if self.selectedProfileSegment == ProfileSegment.experience && !self.isLoadingExperiences {
                    self.tableView.tableFooterView = UIView()
                    self.tableView.reloadData()
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
                    print("queryUserCategoriesNumberOfPostsSorted error: \(error)")
                    self.isLoadingUserCategories = false
                    self.hasLoadedInitialUserCategories = true
                    if (error as! NSError).code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                    }
                    if self.selectedProfileSegment == ProfileSegment.skills {
                        self.tableView.tableFooterView = UIView()
                        self.tableView.reloadData()
                    }
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
                self.hasLoadedInitialUserCategories = true
                self.noNetworkConnection = false
                
                // Reload tableView with downloaded userCategories.
                if self.selectedProfileSegment == ProfileSegment.skills {
                    self.tableView.tableFooterView = UIView()
                    self.tableView.reloadData()
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
                    // Update data source and cell.
                    self.isLoadingRelationship = false
                    if task.result != nil {
                        self.isFollowing = true
                        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.setFollowingButton()
                    } else {
                        self.isFollowing = false
                        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.setFollowButton()
                    }
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
                    // Update data source and cell.
                    self.isLoadingRecommendation = false
                    if task.result != nil {
                        self.isRecommending = true
                        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.setRecommendingButton()
                    } else {
                        self.isRecommending = false
                        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.setRecommendButton()
                    }
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
            if !self.isLoadingRelationship, let followingId = self.user?.userId {
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
        if !self.isCurrentUser, !self.isLoadingRecommendation {
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

extension ProfileTableViewController {
    
    // MARK: NotificationCenterActions
    
    func updateUserNotification(_ notification: NSNotification) {
        guard let editUser = notification.userInfo?["user"] as? EditUser else {
            return
        }
        guard self.user?.userId == editUser.userId else {
            return
        }
        // Update data source.
        self.user?.firstName = editUser.firstName
        self.user?.lastName = editUser.lastName
        self.user?.professionName = editUser.professionName
        self.user?.profilePicUrl = editUser.profilePicUrl
        self.user?.locationId = editUser.locationId
        self.user?.locationName = editUser.locationName
        self.user?.about = editUser.about
        self.user?.website = editUser.website
        self.user?.profilePic = editUser.profilePic
        // Update cells.
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.profilePicImageView.image = self.user?.profilePic
        let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ProfileInfoTableViewCell
        cell?.fullNameLabel.text = self.user?.fullName
        cell?.professionNameLabel.text = self.user?.professionName
        cell?.locationNameLabel.text = self.user?.locationName
        cell?.locationStackView.isHidden = self.user?.locationName != nil ? false : true
        cell?.aboutLabel.text = self.user?.about
        cell?.websiteButton.setTitle(self.user?.website, for: UIControlState.normal)
        cell?.websiteButton.isHidden = self.user?.website != nil ? false : true
        self.tableView.reloadData()
        // Remove old profilePic in background.
        if let profilePicUrlToRemove = notification.userInfo?["profilePicUrlToRemove"] as? String {
            PRFYS3Manager.defaultS3Manager().removeImageS3(profilePicUrlToRemove)
        }
    }
    
    func updateEmailNotification(_ notification: NSNotification) {
        guard let email = notification.userInfo?["email"] as? String, let emailVerified = notification.userInfo?["emailVerified"] as? NSNumber else {
            return
        }
        guard self.user?.userId == AWSIdentityManager.defaultIdentityManager().identityId else {
            return
        }
        self.user?.email = email
        self.user?.emailVerified = emailVerified
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
                self.tableView.reloadData()
            } else {
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: UITableViewRowAnimation.none)
            }
        }
        // Update numberOfPosts and cell.
        if let numberOfPosts = self.user?.numberOfPosts {
            self.user?.numberOfPosts = NSNumber(value: numberOfPosts.intValue + 1)
        } else {
            self.user?.numberOfPosts = NSNumber(value: 1)
        }
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.numberOfPostsButton.setTitle(self.user?.numberOfPostsInt.numberToString(), for: UIControlState.normal)
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
        // Update data source and cells.
        let post = self.posts[postIndex]
        let oldCategoryName = post.categoryName
        post.caption = notification.userInfo?["caption"] as? String
        post.categoryName = notification.userInfo?["categoryName"] as? String
        if self.selectedProfileSegment == ProfileSegment.posts {
            (self.tableView.cellForRow(at: IndexPath(row: postIndex, section: 1)) as? PostSmallTableViewCell)?.titleLabel.text = post.caption
            (self.tableView.cellForRow(at: IndexPath(row: postIndex, section: 1)) as? PostSmallTableViewCell)?.categoryNameLabel.text = post.categoryName
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
                self.tableView.reloadData()
            } else {
                self.tableView.deleteRows(at: [IndexPath(row: postIndex, section: 1)], with: UITableViewRowAnimation.none)
            }
        }
        // Update numberOfPosts and cell.
        if let numberOfPosts = self.user?.numberOfPosts {
            self.user?.numberOfPosts = NSNumber(value: numberOfPosts.intValue - 1)
        } else {
            self.user?.numberOfPosts = NSNumber(value: 0)
        }
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.numberOfPostsButton.setTitle(self.user?.numberOfPostsInt.numberToString(), for: UIControlState.normal)
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
        // Update data source and cell.
        let post = self.posts[postIndex]
        post.numberOfLikes = NSNumber(value: post.numberOfLikesInt + 1)
        post.isLikedByCurrentUser = true
        (self.tableView.cellForRow(at: IndexPath(row: postIndex, section: 1)) as? PostSmallTableViewCell)?.numberOfLikesLabel.text = post.numberOfLikesSmallString
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
        (self.tableView.cellForRow(at: IndexPath(row: postIndex, section: 1)) as? PostSmallTableViewCell)?.numberOfLikesLabel.text = post.numberOfLikesSmallString
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
    }
    
    func followUserNotification(_ notification: NSNotification) {
        guard let followingId = notification.userInfo?["followingId"] as? String else {
            return
        }
        guard self.user?.userId == followingId else {
            return
        }
        guard !self.isLoadingRelationship, !self.isFollowing else {
            return
        }
        // Update data source and cell.
        self.isFollowing = true
        if let numberOfFollowers = self.user?.numberOfFollowers {
            self.user?.numberOfFollowers = NSNumber(value: numberOfFollowers.intValue + 1)
        } else {
            self.user?.numberOfFollowers = NSNumber(value: 1)
        }
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell
        cell?.numberOfFollowersButton.setTitle(self.user?.numberOfFollowersInt.numberToString(), for: UIControlState.normal)
        cell?.setFollowingButton()
    }
    
    func unfollowUserNotification(_ notification: NSNotification) {
        guard let followingId = notification.userInfo?["followingId"] as? String else {
            return
        }
        guard self.user?.userId == followingId else {
            return
        }
        guard !self.isLoadingRelationship, self.isFollowing else {
            return
        }
        // Update data source and cell.
        self.isFollowing = false
        if let numberOfFollowers = self.user?.numberOfFollowers, numberOfFollowers.intValue > 0 {
            self.user?.numberOfFollowers = NSNumber(value: numberOfFollowers.intValue - 1)
        } else {
            self.user?.numberOfFollowers = NSNumber(value: 0)
        }
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell
        cell?.numberOfFollowersButton.setTitle(self.user?.numberOfFollowersInt.numberToString(), for: UIControlState.normal)
        cell?.setFollowButton()
    }
    
    func recommendUserNotification(_ notification: NSNotification) {
        guard let recommendingId = notification.userInfo?["recommendingId"] as? String else {
            return
        }
        guard self.user?.userId == recommendingId, !self.isLoadingRecommendation, !self.isRecommending else {
            return
        }
        // Update data source and cell.
        self.isRecommending = true
        if let numberOfRecommendations = self.user?.numberOfRecommendations {
            self.user?.numberOfRecommendations = NSNumber(value: numberOfRecommendations.intValue + 1)
        } else {
            self.user?.numberOfRecommendations = NSNumber(value: 1)
        }
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell
        cell?.numberOfRecommendationsButton.setTitle(self.user?.numberOfRecommendationsInt.numberToString(), for: UIControlState.normal)
        cell?.setRecommendingButton()
    }
    
    func unrecommendUserNotification(_ notification: NSNotification) {
        guard let recommendingId = notification.userInfo?["recommendingId"] as? String else {
            return
        }
        guard self.user?.userId == recommendingId, !self.isLoadingRecommendation, self.isRecommending else {
            return
        }
        // Update data source and cell.
        self.isRecommending = false
        if let numberOfRecommendations = self.user?.numberOfRecommendations, numberOfRecommendations.intValue > 0 {
            self.user?.numberOfRecommendations = NSNumber(value: numberOfRecommendations.intValue - 1)
        } else {
            self.user?.numberOfRecommendations = NSNumber(value: 0)
        }
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell
        cell?.numberOfRecommendationsButton.setTitle(self.user?.numberOfRecommendationsInt.numberToString(), for: UIControlState.normal)
        cell?.setRecommendButton()
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
            (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.profilePicImageView.image = self.user?.profilePic
        case .postPic:
            guard let postIndex = self.posts.index(where: { $0.imageUrl == imageKey }) else {
                return
            }
            self.posts[postIndex].image = UIImage(data: imageData)
            (self.tableView.cellForRow(at: IndexPath(row: postIndex, section: 1)) as? PostSmallTableViewCell)?.postImageView.image = self.posts[postIndex].image
        }
    }
}

extension ProfileTableViewController: ProfileInfoTableViewCellDelegate {
    
    func websiteButtonTapped() {
        if let websiteUrl = self.user?.websiteUrl {
            UIApplication.shared.openURL(websiteUrl)
        }
    }
}

extension ProfileTableViewController: ProfileSegmentedControlSectionHeaderDelegate {
    
    func segmentChanged(_ profileSegment: ProfileSegment) {
        guard let userId = self.user?.userId else {
            return
        }
        self.selectedProfileSegment = profileSegment
        // In case initial data haven't been loaded yet. This happens only once per segment or with no network.
        switch self.selectedProfileSegment {
        case .posts:
            if !self.hasLoadedInitialPosts {
                self.isLoadingPosts = true
                self.tableView.reloadData()
                self.tableView.tableFooterView = self.loadingTableFooterView
                self.queryPostsDateSorted(userId, startFromBeginning: true)
            } else {
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
        case .experience:
            if !self.hasLoadedInitialExperiences {
                self.isLoadingWorkExperiences = true
                self.isLoadingEducations = true
                self.tableView.reloadData()
                self.tableView.tableFooterView = self.loadingTableFooterView
                self.queryWorkExperiences(userId)
                self.queryEducations(userId)
            } else {
                self.tableView.reloadData()
            }
        case .skills:
            if !self.hasLoadedInitialUserCategories {
                self.isLoadingUserCategories = true
                self.tableView.reloadData()
                self.tableView.tableFooterView = self.loadingTableFooterView
                self.queryUserCategoriesNumberOfPostsSorted(userId)
            } else {
                self.tableView.reloadData()
            }
        }
    }
}

extension ProfileTableViewController: WorkExperienceTableViewCellDelegate {
    
    func workDescriptionLabelTapped(_ cell: WorkExperienceTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        let index = indexPath.row - 1
        guard let workExperience = self.experiences[index] as? WorkExperience else {
            return
        }
        if !workExperience.isExpandedWorkDescription {
            workExperience.isExpandedWorkDescription = true
            cell.untruncate()
            UIView.performWithoutAnimation {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
}

extension ProfileTableViewController: EducationTableViewCellDelegate {
    
    func educationDescriptionLabelTapped(_ cell: EducationTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        let index = (self.workExperiences.count > 0) ? indexPath.row - 2 : indexPath.row - 1
        guard let education = self.experiences[index] as? Education else {
            return
        }
        if !education.isExpandedEducationDescription {
            education.isExpandedEducationDescription = true
            cell.untruncate()
            UIView.performWithoutAnimation {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
}

extension ProfileTableViewController: ExperiencesHeaderTableViewCellDelegate {
    
    func editButtonTapped() {
        self.performSegue(withIdentifier: "segueToExperiencesVc", sender: self)
    }
}

extension ProfileTableViewController: ExperiencesTableViewControllerDelegate {
    
    func workExperiencesUpdated(_ workExperiences: [WorkExperience]) {
        self.workExperiences = workExperiences
        self.sortWorkExperiencesByToDate()
        if self.selectedProfileSegment == ProfileSegment.experience {
            self.tableView.reloadData()
        }
    }
    
    func educationsUpdated(_ educations: [Education]) {
        self.educations = educations
        self.sortEducationsByToDate()
        if self.selectedProfileSegment == ProfileSegment.experience {
            self.tableView.reloadData()
        }
    }
}

extension ProfileTableViewController: ProfileEmptyTableViewCellDelegate {
    
    func addButtonTapped(_ addButtonType: AddButtonType) {
        switch addButtonType {
        case .post:
            // Check Photos access for the first time. This can happen on MainTabBarVc, UsernameVc, ProfileVc and EditVc.
            if PHPhotoLibrary.authorizationStatus() == .notDetermined {
                PHPhotoLibrary.requestAuthorization({
                    (status: PHAuthorizationStatus) in
                    self.performSegue(withIdentifier: "segueToCaptureVc", sender: self)
                })
            } else {
                self.performSegue(withIdentifier: "segueToCaptureVc", sender: self)
            }
        case .experience:
            self.performSegue(withIdentifier: "segueToExperiencesVc", sender: self)
        }
    }
}
