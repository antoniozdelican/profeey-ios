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
    
    fileprivate var hasRecommendationLoaded = false
    fileprivate var isRecommending: Bool = false
    
    fileprivate var hasRelationshipLoaded = false
    fileprivate var isFollowing: Bool = false
    
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
    
    fileprivate var isLoadingUserCategories: Bool = true
    fileprivate var userCategories: [UserCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = self.user?.preferredUsername
        
        // Register custom headers.
        self.tableView.register(UINib(nibName: "ProfileTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "profileTableSectionHeader")
        
        self.configureUser()
        if self.isCurrentUser {
            self.settingsButton.image = UIImage(named: "ic_settings")
        } else {
            self.settingsButton.image = UIImage(named: "ic_mail")
        }
//        if !self.isCurrentUser {
//            self.navigationItem.rightBarButtonItem = nil
//        }
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
            childViewController.originalUser = self.user
            childViewController.editProfileTableViewControllerDelegate = self
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
        if let destinationViewController = segue.destination as? PostDetailsTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.post = self.posts[indexPath.row]
            destinationViewController.postIndexPath = indexPath
            destinationViewController.postDetailsTableViewControllerDelegate = self
        }
        if let destinationViewController = segue.destination as? UserCategoryTableViewController,
            let cell = sender as? UserCategoryTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.user = self.user
            destinationViewController.userCategory = self.userCategories[indexPath.row]
            destinationViewController.userCategoryTableViewControllerDelegate = self
        }
        if let destinationViewController = segue.destination as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? AddRecommendationTableViewController {
            childViewController.user = self.user
            childViewController.addRecommendationTableViewControllerDelegate = self
        }
        if let destinationViewController = segue.destination as? RecommendationsTableViewController {
            destinationViewController.user = self.user
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
                cell.profilePicImageView.image = self.user?.profilePic
                cell.numberOfPostsButton.setTitle(self.user?.numberOfPostsInt.numberToString(), for: UIControlState.normal)
                cell.numberOfFollowersButton.setTitle(self.user?.numberOfFollowersInt.numberToString(), for: UIControlState.normal)
                cell.numberOfRecommendationsButton.setTitle(self.user?.numberOfRecommendationsInt.numberToString(), for: UIControlState.normal)
                
                if self.isCurrentUser {
                    cell.recommendButton.isHidden = true
                    cell.setEditButton()
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
            cell.workDescriptionLabel.isHidden = workExperience.workDescription != nil ? false : true
            cell.separatorViewLeftConstraint?.constant = (indexPath.row == self.workExperiences.count - 1) ? 0.0 : 12.0
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEducation", for: indexPath) as! EducationTableViewCell
            let education = self.educations[indexPath.row]
            cell.schoolLabel.text = education.school
            cell.fieldOfStudyLabel.text = education.fieldOfStudy
            cell.timePeriodLabel.text = education.timePeriod
            cell.educationDescriptionLabel.text = education.educationDescription
            cell.educationDescriptionLabel.isHidden = education.educationDescription != nil ? false : true
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
                return 112.0
            }
            return 112.0
        case 2:
            if self.isLoadingExperiences || self.isEmptyExperiences {
                return 112.0
            }
            return 74.0
        case 3:
            return 74.0
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
            if self.isLoadingPosts || self.posts.count == 0 {
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
            // To display empty white view.
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
        if let sourceViewController = segue.source as? PostDetailsTableViewController,
            let post = sourceViewController.post,
            let postIndexPath = sourceViewController.postIndexPath {
            self.posts.remove(at: postIndexPath.row)
            if self.posts.count == 0 {
                self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
            } else {
                self.tableView.deleteRows(at: [postIndexPath], with: UITableViewRowAnimation.fade)
            }
            if let imageKey = post.imageUrl, let postId = post.postId {
                // In background
                self.removeImage(imageKey, postId: postId)
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
                    let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, about: awsUser._about, locationName: awsUser._locationName, numberOfFollowers: awsUser._numberOfFollowers, numberOfPosts: awsUser._numberOfPosts, numberOfRecommendations: awsUser._numberOfRecommendations)
                    self.user = user
                    
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.none)
                    self.navigationItem.title = self.user?.preferredUsername
                    if let profilePicUrl = awsUser._profilePicUrl {
                        self.downloadImage(profilePicUrl, imageType: .userProfilePic, indexPath: IndexPath(row: 0, section: 0))
                    }
                    if let userId = awsUser._userId {
                        if !self.isCurrentUser {
                            self.getRelationship(userId)
                            self.getRecommendation(userId)
                        }
                        self.queryUserPostsDateSorted(userId)
                        self.queryWorkExperiences(userId)
                        self.queryEducations(userId)
                        self.queryUserCategoriesNumberOfPostsSorted(userId)
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
                        UIView.performWithoutAnimation {
                            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                        }
                    }
                } else {
                    guard let awsPosts = response?.items as? [AWSPost], awsPosts.count > 0 else {
                        if self.selectedProfileSegment == ProfileSegment.posts {
                            UIView.performWithoutAnimation {
                                self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                            }
                        }
                        return
                    }
                    // Reset posts.
                    self.posts = []
                    for (index, awsPost) in awsPosts.enumerated() {
                        let post = Post(userId: awsPost._userId, postId: awsPost._postId, creationDate: awsPost._creationDate, caption: awsPost._caption, categoryName: awsPost._categoryName, imageUrl: awsPost._imageUrl, imageWidth: awsPost._imageWidth, imageHeight: awsPost._imageHeight, numberOfLikes: awsPost._numberOfLikes, numberOfComments: awsPost._numberOfComments, user: self.user)
                        self.posts.append(post)
                        if self.selectedProfileSegment == ProfileSegment.posts {
                            UIView.performWithoutAnimation {
                                self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                            }
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
                        UIView.performWithoutAnimation {
                            self.tableView.reloadSections(IndexSet([2, 3]), with: UITableViewRowAnimation.none)
                        }
                    }
                } else {
                    guard let awsWorkExperiences = response?.items as? [AWSWorkExperience], awsWorkExperiences.count > 0 else {
                        if self.selectedProfileSegment == ProfileSegment.experience {
                            UIView.performWithoutAnimation {
                                self.tableView.reloadSections(IndexSet([2, 3]), with: UITableViewRowAnimation.none)
                            }
                        }
                        return
                    }
                    self.workExperiences = []
                    for awsWorkExperience in awsWorkExperiences {
                        let workExperience = WorkExperience(userId: awsWorkExperience._userId, workExperienceId: awsWorkExperience._workExperienceId, title: awsWorkExperience._title, organization: awsWorkExperience._organization, workDescription: awsWorkExperience._workDescription, fromMonth: awsWorkExperience._fromMonth, fromYear: awsWorkExperience._fromYear, toMonth: awsWorkExperience._toMonth, toYear: awsWorkExperience._toYear)
                        self.workExperiences.append(workExperience)
                    }
                    self.sortWorkExperiencesByToDate()
                    if self.selectedProfileSegment == ProfileSegment.experience {
                        UIView.performWithoutAnimation {
                            self.tableView.reloadSections(IndexSet([2, 3]), with: UITableViewRowAnimation.none)
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
                        UIView.performWithoutAnimation {
                            self.tableView.reloadSections(IndexSet([2, 3]), with: UITableViewRowAnimation.none)
                        }
                    }
                } else {
                    guard let awsEducations = response?.items as? [AWSEducation], awsEducations.count > 0 else {
                        if self.selectedProfileSegment == ProfileSegment.experience {
                            UIView.performWithoutAnimation {
                                self.tableView.reloadSections(IndexSet([2, 3]), with: UITableViewRowAnimation.none)
                            }
                        }
                        return
                    }
                    self.educations = []
                    for awsEducation in awsEducations {
                        let education = Education(userId: awsEducation._userId, educationId: awsEducation._educationId, school: awsEducation._school, fieldOfStudy: awsEducation._fieldOfStudy, educationDescription: awsEducation._educationDescription, fromMonth: awsEducation._fromMonth, fromYear: awsEducation._fromYear, toMonth: awsEducation._toMonth, toYear: awsEducation._toYear)
                        self.educations.append(education)
                    }
                    self.sortEducationsByToDate()
                    if self.selectedProfileSegment == ProfileSegment.experience {
                        UIView.performWithoutAnimation {
                            self.tableView.reloadSections(IndexSet([2, 3]), with: UITableViewRowAnimation.none)
                        }
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
                self.isLoadingUserCategories = false
                if let error = error {
                    print("queryUserCategoriesNumberOfPostsSorted error: \(error)")
                    if self.selectedProfileSegment == ProfileSegment.skills {
                        UIView.performWithoutAnimation {
                            self.tableView.reloadSections(IndexSet([4]), with: UITableViewRowAnimation.none)
                        }
                    }
                } else {
                    guard let awsUserCategories = response?.items as? [AWSUserCategory], awsUserCategories.count > 0 else {
                        if self.selectedProfileSegment == ProfileSegment.skills {
                            UIView.performWithoutAnimation {
                                self.tableView.reloadSections(IndexSet([4]), with: UITableViewRowAnimation.none)
                            }
                        }
                        return
                    }
                    self.userCategories = []
                    for awsUserCategory in awsUserCategories {
                        let userCategory = UserCategory(userId: awsUserCategory._userId, categoryName: awsUserCategory._categoryName, numberOfPosts: awsUserCategory._numberOfPosts)
                        self.userCategories.append(userCategory)
                    }
                    if self.selectedProfileSegment == ProfileSegment.skills {
                        UIView.performWithoutAnimation {
                            self.tableView.reloadSections(IndexSet([4]), with: UITableViewRowAnimation.none)
                        }
                    }
                }
            })
        })
    }
    
    fileprivate func downloadImage(_ imageKey: String, imageType: ImageType, indexPath: IndexPath) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let content = AWSUserFileManager.UserFileManager(forKey: "USEast1BucketManager").content(withKey: imageKey)
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
    
    // In background when user deletes/changes profilePic or deletes post.
    fileprivate func removeImage(_ imageKey: String, postId: String?) {
        let content = AWSUserFileManager.UserFileManager(forKey: "USEast1BucketManager").content(withKey: imageKey)
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
                    if let postId = postId {
                        // If it's post.
                        self.removePost(postId)
                    }
                }
            })
        })
    }
    
    fileprivate func removePost(_ postId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removePostDynamoDB(postId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("removePost error: \(error)")
                }
            })
            return nil
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
    fileprivate func followUser(_ followingId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createRelationshipDynamoDB(followingId, completionHandler: {
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
        print("HERE getRecommendation")
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
    fileprivate func removeRecommendation() {
        guard let recommendingId = self.user?.userId else {
            return
        }
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

extension ProfileTableViewController: ProfileMainTableViewCellDelegate {
    
    func numberOfPostsButtonTapped() {
        if self.posts.count > 0 && self.selectedProfileSegment == ProfileSegment.posts {
            let indexPath = IndexPath(row: 0, section: 1)
            self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    func numberOfFollowersButtonTapped() {
        self.performSegue(withIdentifier: "segueToUsersVc", sender: self)
    }
    
    func numberOfRecommendationsButtonTapped() {
        self.performSegue(withIdentifier: "segueToRecommendationsVc", sender: self)
    }
    
    func followButtonTapped() {
        if self.isCurrentUser {
            self.performSegue(withIdentifier: "segueToEditProfileVc", sender: self)
        } else {
            if self.hasRelationshipLoaded {
                guard let followingId = self.user?.userId else {
                    return
                }
                if self.isFollowing {
                    let message = ["Unfollow", self.user?.preferredUsername].flatMap({ $0 }).joined(separator: " ") + "?"
                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
                    // DELETE
                    let deleteAction = UIAlertAction(title: "Unfollow", style: UIAlertActionStyle.destructive, handler: {
                        (alert: UIAlertAction) in
                        if let numberOfFollowers = self.user?.numberOfFollowers, numberOfFollowers.intValue > 0 {
                            self.user?.numberOfFollowers = NSNumber(value: numberOfFollowers.intValue - 1)
                        } else {
                            self.user?.numberOfFollowers = NSNumber(value: 0)
                        }
                        self.isFollowing = false
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
                        // In background.
                        self.unfollowUser(followingId)
                    })
                    alertController.addAction(deleteAction)
                    // CANCEL
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    if let numberOfFollowers = self.user?.numberOfFollowers {
                        self.user?.numberOfFollowers = NSNumber(value: numberOfFollowers.intValue + 1)
                    } else {
                        self.user?.numberOfFollowers = NSNumber(value: 1)
                    }
                    self.isFollowing = true
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
                    // In background.
                    self.followUser(followingId)
                }
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
            }
        }
    }
    
    func recommendButtonTapped() {
        if !self.isCurrentUser, self.hasRecommendationLoaded {
            if self.isRecommending {
                let message = ["Unrecommend", self.user?.preferredUsername].flatMap({ $0 }).joined(separator: " ") + "?"
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
                // DELETE
                let deleteAction = UIAlertAction(title: "Unrecommend", style: UIAlertActionStyle.destructive, handler: {
                    (alert: UIAlertAction) in
                    if let numberOfRecommendations = self.user?.numberOfRecommendations, numberOfRecommendations.intValue > 0 {
                        self.user?.numberOfRecommendations = NSNumber(value: numberOfRecommendations.intValue - 1)
                    } else {
                        self.user?.numberOfRecommendations = NSNumber(value: 0)
                    }
                    self.isRecommending = false
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
                    // In background.
                    self.removeRecommendation()
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

extension ProfileTableViewController: PostDetailsTableViewControllerDelegate {
    
    func updatedPost(_ post: Post, postIndexPath: IndexPath) {
        self.posts[postIndexPath.row] = post
        self.tableView.reloadRows(at: [postIndexPath], with: UITableViewRowAnimation.none)
    }
}

extension ProfileTableViewController: UserCategoryTableViewControllerDelegate {
    
    func updatedPost(_ post: Post) {
        guard let postId = post.postId, let updatedPost = self.posts.first(where: { $0.postId == postId }), let postIndex = self.posts.index(of: updatedPost) else {
            return
        }
        self.posts[postIndex] = post
        if self.selectedProfileSegment == ProfileSegment.posts {
            self.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 1)], with: UITableViewRowAnimation.none)
        }
    }
}

extension ProfileTableViewController: EditProfileTableViewControllerDelegate {
    
    func userUpdated(_ user: User?, profilePicUrlToRemove: String?) {
        self.user?.profilePic = user?.profilePic
        self.user?.profilePicUrl = user?.profilePicUrl
        self.user?.firstName = user?.firstName
        self.user?.lastName = user?.lastName
        self.user?.professionName = user?.professionName
        self.user?.about = user?.about
        self.user?.locationName = user?.locationName
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.none)
        // Remove image in background.
        if let profilePicUrlToRemove = profilePicUrlToRemove {
            self.removeImage(profilePicUrlToRemove, postId: nil)
        }
    }
}

extension ProfileTableViewController: AddRecommendationTableViewControllerDelegate {
    
    func recommendationAdded() {
        if let numberOfRecommendations = self.user?.numberOfRecommendations {
            self.user?.numberOfRecommendations = NSNumber(value: numberOfRecommendations.intValue + 1)
        } else {
            self.user?.numberOfRecommendations = NSNumber(value: 1)
        }
        self.isRecommending = true
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
    }
}
