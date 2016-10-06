//
//  ProfileTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 16/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    var user: User?
    var isCurrentUser: Bool = false
    
    fileprivate var currentUser: User?
    fileprivate var posts: [Post] = []
    fileprivate var topCategories: [Category] = []
    fileprivate var userExperiences: [UserExperience] = []
    fileprivate var workExperiences: [UserExperience] = []
    fileprivate var educationExperiences: [UserExperience] = []
    fileprivate var isLoadingPosts: Bool = true
    fileprivate var isFollowing: Bool = false
    fileprivate var selectedSegment: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = self.user?.preferredUsername
        
        // In case we come from another Vc.
        if self.user?.userId == AWSClientManager.defaultClientManager().credentialsProvider?.identityId {
            self.isCurrentUser = true
        }
        
        // Get currentUser.
        self.getCurrentUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        if let destinationViewController = segue.destination as? PostDetailsTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.post = self.posts[(indexPath as NSIndexPath).row]
            // For likes delegate.
            destinationViewController.postIndexPath = indexPath
            destinationViewController.likeDelegate = self
        }
        if let destinationViewController = segue.destination as? ExperiencesTableViewController {
            destinationViewController.userExperiences = self.userExperiences
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            if self.selectedSegment != 0 {
                return 0
            }
            guard self.selectedSegment == 0 else {
                return 0
            }
            guard !self.isLoadingPosts else {
                return 1
            }
            guard self.posts.count > 0 else {
                return 1
            }
            return self.posts.count
        case 2:
            guard self.selectedSegment == 1 else {
                return 0
            }
            return self.topCategories.count
        case 3:
            guard self.selectedSegment == 1 else {
                return 0
            }
            return self.workExperiences.count
        case 4:
            guard self.selectedSegment == 1 else {
                return 0
            }
            return self.educationExperiences.count
        case 5:
            guard self.selectedSegment == 2 else {
                return 0
            }
            return 1
        case 6:
            guard self.selectedSegment == 2 else {
                return 0
            }
            return 1
        case 7:
            guard self.selectedSegment == 2 else {
                return 0
            }
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileMain", for: indexPath) as! ProfileMainTableViewCell
                cell.profilePicImageView.image = self.user?.profilePic
                cell.fullNameLabel.text = self.user?.fullName
                cell.professionNameLabel.text = self.user?.professionName
                cell.locationNameLabel.text = self.user?.locationName
                cell.aboutLabel.text = self.user?.about
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileButtons", for: indexPath) as! ProfileButtonsTableViewCell
                cell.numberOfPostsButton.setTitle(self.user?.numberOfPostsInt.numberToString(), for: UIControlState())
                cell.numberOfPostsButton.addTarget(self, action: #selector(ProfileTableViewController.postsButtonTapped(_:)), for: UIControlEvents.touchUpInside)
                cell.numberOfFollowersButton.setTitle(self.user?.numberOfFollowersInt.numberToString(), for: UIControlState())
                cell.numberOfFollowersButton.addTarget(self, action: #selector(ProfileTableViewController.followersButtonTapped(_:)), for: UIControlEvents.touchUpInside)
                if self.user?.numberOfFollowersInt == 0 {
                    cell.numberOfFollowersButton.isEnabled = false
                    cell.setDisabledNumberOfFollowersButton()
                } else {
                    cell.numberOfFollowersButton.isEnabled = true
                    cell.setEnabledNumberOfFollowersButton()
                }
                
                if self.isCurrentUser {
                    cell.setEditButton()
                    cell.followButton.addTarget(self, action: #selector(ProfileTableViewController.editButtonTapped(_:)), for: UIControlEvents.touchUpInside)
                } else {
                    self.isFollowing ? cell.setFollowingButton() : cell.setFollowButton()
                    cell.followButton.addTarget(self, action: #selector(ProfileTableViewController.followButtonTapped(_:)), for: UIControlEvents.touchUpInside)
                }
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileSegmentedControl", for: indexPath) as! ProfileSegmentedControlTableViewCell
                switch self.selectedSegment {
                case 0:
                    cell.setPostsButtonActive()
                case 1:
                    cell.setAboutButtonActive()
                case 2:
                    cell.setContactButtonActive()
                default:
                    break
                }
                cell.postsButton.addTarget(self, action: #selector(ProfileTableViewController.postsSegmentButtonTapped(_:)), for: UIControlEvents.touchUpInside)
                cell.aboutButton.addTarget(self, action: #selector(ProfileTableViewController.experienceSegmentButtonTapped(_:)), for: UIControlEvents.touchUpInside)
                cell.contactButton.addTarget(self, action: #selector(ProfileTableViewController.contactSegmentButtonTapped(_:)), for: UIControlEvents.touchUpInside)
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            if self.isLoadingPosts {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellLoading", for: indexPath) as! LoadingTableViewCell
                return cell
            }
            if !self.isLoadingPosts && self.posts.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! EmptyTableViewCell
                cell.emptyMessageLabel.text = "There's no posts yet"
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostSmall", for: indexPath) as! PostSmallTableViewCell
            let post = self.posts[(indexPath as NSIndexPath).row]
            cell.postImageView.image = post.image
            cell.titleLabel.text = post.caption
            cell.categoryNameLabel.text = post.categoryName
            cell.timeLabel.text = post.creationDateString
            cell.numberOfLikesLabel.text = post.numberOfLikesSmallString
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellTopCategory", for: indexPath) as! TopCategoryTableViewCell
            let topCategory = self.topCategories[(indexPath as NSIndexPath).row]
            cell.topCategoryNameLabel.text = topCategory.categoryName
            cell.numberOfPostsLabel.text = topCategory.numberOfPostsString
            return cell
        case 3:
            let workExperience = self.workExperiences[(indexPath as NSIndexPath).row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellExperience", for: indexPath) as! ExperienceTableViewCell
            cell.positionLabel.text = workExperience.position
            cell.organizationLabel.text = workExperience.organization
            cell.timePeriodLabel.text = workExperience.timePeriod
            return cell
        case 4:
            let educationExperience = self.educationExperiences[(indexPath as NSIndexPath).row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellExperience", for: indexPath) as! ExperienceTableViewCell
            cell.positionLabel.text = educationExperience.position
            cell.organizationLabel.text = educationExperience.organization
            cell.timePeriodLabel.text = educationExperience.timePeriod
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellWebsite", for: indexPath) as! WebsiteTableViewCell
            cell.websiteLabel.text = "antoniozdelican.com"
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmail", for: indexPath) as! EmailTableViewCell
            cell.emailLabel.text = "josip.zdelican@gmail.com"
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPhone", for: indexPath) as! PhoneTableViewCell
            cell.phoneLabel.text = "+385 98 929 68 25"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
            case 1:
                cell.layoutMargins = UIEdgeInsets.zero
            case 2:
                cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
            default:
                return
            }
        case 1:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.default
        case 2:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        case 3:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        default:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 2:
            guard self.selectedSegment == 1 else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! HeaderTableViewCell
            cell.headerTitle.text = "TOP SKILLS"
            cell.editButton?.isHidden = true
            cell.contentView.backgroundColor = UIColor.white
            return cell.contentView
        case 3:
            guard self.selectedSegment == 1 else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! HeaderTableViewCell
            cell.headerTitle.text = "WORK EXPERIENCE"
            cell.editButton?.addTarget(self, action: #selector(ProfileTableViewController.editExperiencesButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            cell.contentView.backgroundColor = UIColor.white
            return cell.contentView
        case 4:
            guard self.selectedSegment == 1 else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! HeaderTableViewCell
            cell.headerTitle.text = "EDUCATION"
            cell.editButton?.addTarget(self, action: #selector(ProfileTableViewController.editExperiencesButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            cell.contentView.backgroundColor = UIColor.white
            return cell.contentView
        case 5:
            guard self.selectedSegment == 2 else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! HeaderTableViewCell
            cell.headerTitle.text = "WEBSITE"
            cell.editButton?.isHidden = true
            cell.contentView.backgroundColor = UIColor.white
            return cell.contentView
        case 6:
            guard self.selectedSegment == 2 else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! HeaderTableViewCell
            cell.headerTitle.text = "EMAIL"
            cell.editButton?.isHidden = true
            cell.contentView.backgroundColor = UIColor.white
            return cell.contentView
        case 7:
            guard self.selectedSegment == 2 else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! HeaderTableViewCell
            cell.headerTitle.text = "PHONE"
            cell.editButton?.isHidden = true
            cell.contentView.backgroundColor = UIColor.white
            return cell.contentView
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2 || section == 3 || section == 4 {
            guard self.selectedSegment == 1 else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellFooter")
            cell!.contentView.backgroundColor = UIColor.white
            return cell!.contentView
        }
        if section == 5 || section == 6 || section == 7 {
            guard self.selectedSegment == 2 else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellFooter")
            cell!.contentView.backgroundColor = UIColor.white
            return cell!.contentView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is PostSmallTableViewCell {
            self.performSegue(withIdentifier: "segueToPostDetailsVc", sender: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                return 112.0
            case 1:
                return 50.0
            case 2:
                return 48.0
            default:
                return 0.0
            }
        case 1:
            if self.isLoadingPosts {
                return 120.0
            }
            if self.posts.count == 0 {
                return 120.0
            }
            return 108.0
        case 2:
            return 25.0
        case 3:
            return 75.0
        case 4:
            return 75.0
        case 5:
            return 37.0
        case 6:
            return 37.0
        case 7:
            return 37.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                return UITableViewAutomaticDimension
            case 1:
                return 50.0
            case 2:
                return 48.0
            default:
                return 0.0
            }
        case 1:
            if self.isLoadingPosts {
                return 120.0
            }
            if self.posts.count == 0 {
                return 120.0
            }
            return 108.0
        case 2:
            return UITableViewAutomaticDimension
        case 3:
            return 75.0
        case 4:
            return 75.0
        case 5:
            return 37.0
        case 6:
            return 37.0
        case 7:
            return 37.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 || section == 3 || section == 4 {
            guard self.selectedSegment == 1 else {
                return 0.0
            }
            return 40.0
        }
        if section == 5 || section == 6 || section == 7 {
            guard self.selectedSegment == 2 else {
                return 0.0
            }
            return 40.0
        }
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 || section == 3 || section == 4 {
            guard self.selectedSegment == 1 else {
                return 0.0
            }
            return 16.0
        }
        if section == 5 || section == 6 || section == 7 {
            guard self.selectedSegment == 2 else {
                return 0.0
            }
            return 16.0
        }
        return 0.0
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
            self.tableView.reloadData()
            // Remove image in background.
            if let profilePicUrlToRemove = sourceViewController.profilePicUrlToRemove {
                self.removeImage(profilePicUrlToRemove)
            }
        }
    }
    
    // MARK: Tappers
    
    func postsButtonTapped(_ sender: AnyObject) {
        let indexPath = IndexPath(row: 0, section: 1)
        self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
    }
    
    func followersButtonTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "segueToUsersVc", sender: self)
    }
    
    func editButtonTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "segueToEditProfileVc", sender: self)
    }
    
    func followButtonTapped(_ sender: AnyObject) {
        let point = sender.convert(CGPoint.zero, to: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: point) else {
            return
        }
        guard let user = self.user else {
            return
        }
        guard let followingId = user.userId else {
            return
        }
        let numberOfFollowers = (user.numberOfFollowers != nil) ? user.numberOfFollowers! : 0
        let numberOfFollowersInteger = numberOfFollowers.intValue
        if self.isFollowing {
            self.isFollowing = false
            user.numberOfFollowers = NSNumber(value: (numberOfFollowersInteger - 1) as Int)
            self.unfollowUser(followingId)
        } else {
            self.isFollowing = true
            user.numberOfFollowers = NSNumber(value: (numberOfFollowersInteger + 1) as Int)
            self.followUser(followingId)
        }
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    }
    
    func postsSegmentButtonTapped(_ sender: UIButton) {
        self.selectedSegment = 0
        self.tableView.reloadData()
    }
    
    func experienceSegmentButtonTapped(_ sender: UIButton) {
        self.selectedSegment = 1
        self.tableView.reloadData()
    }
    
    func contactSegmentButtonTapped(_ sender: UIButton) {
        self.selectedSegment = 2
        self.tableView.reloadData()
    }
    
    func editExperiencesButtonTapped(_ sender: AnyObject) {
        guard let editButton = sender as? UIButton else {
            return
        }
        self.performSegue(withIdentifier: "segueToExperiencesVc", sender: editButton)
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        guard let userId = self.user?.userId else {
            self.refreshControl?.endRefreshing()
            return
        }
        self.getUser(userId)
    }
    
    // MARK: AWS
    
    // So we can do actions!
    fileprivate func getCurrentUser() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getCurrentUserDynamoDB({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getCurrentUser error: \(error)")
                } else {
                    guard let awsUser = task.result as? AWSUser else {
                        return
                    }
                    let currentUser = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl)
                    self.currentUser = currentUser
                    
                    // In case it's an actual app user.
                    // Set by MainTabBarVc or if we come from another Vc.
                    // We duplicate call here to fetch all the data but that doesn't matter.
                    if self.isCurrentUser {
                        if let userId = currentUser.userId {
                            self.getUser(userId)
                        }
                    } else {
                        if let userId = self.user?.userId {
                            self.getUser(userId)
                            let indexPath = IndexPath(row: 1, section: 0)
                            self.getUserRelationship(userId, indexPath: indexPath)
                        }
                    }
                }
            })
            return nil
        })
    }
    
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
                    self.navigationItem.title = self.user?.preferredUsername
                    let indexSet = IndexSet(integer: 0)
                    self.tableView.reloadSections(indexSet, with: UITableViewRowAnimation.none)
                    
                    if let profilePicUrl = awsUser._profilePicUrl {
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.downloadImage(profilePicUrl, imageType: .userProfilePic, indexPath: indexPath)
                    }
                    if let userId = awsUser._userId {
                        self.queryUserCategoriesNumberOfPostsSorted(userId)
                        self.queryUserPostsDateSorted(userId)
                        self.queryUserExperiences(userId)
                    }
                }
            })
            return nil
        })
    }
    
    fileprivate func queryUserCategoriesNumberOfPostsSorted(_ userId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserCategoriesNumberOfPostsSortedDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    print("queryUserCategoriesNumberOfPostsSorted error: \(error)")
                    self.refreshControl?.endRefreshing()
                } else {
                    guard let awsUserCategories = response?.items as? [AWSUserCategory] else {
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    guard awsUserCategories.count > 0 else {
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    // Reset topCategories.
                    self.topCategories = []
                    for (_, awsUserCategory) in awsUserCategories.enumerated() {
                        let category = Category(categoryName: awsUserCategory._categoryName, numberOfPosts: awsUserCategory._numberOfPosts)
                        self.topCategories.append(category)
                    }
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            })
        })
    }
    
    fileprivate func queryUserPostsDateSorted(_ userId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserPostsDateSortedDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    print("queryUserPostsDateSorted error: \(error)")
                    self.isLoadingPosts = false
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                } else {
                    guard let awsPosts = response?.items as? [AWSPost] else {
                        self.isLoadingPosts = false
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    guard awsPosts.count > 0 else {
                        self.isLoadingPosts = false
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                        return
                    }
                    // Reset posts.
                    self.posts = []
                    for (index, awsPost) in awsPosts.enumerated() {
                        let post = Post(userId: awsPost._userId, postId: awsPost._postId, caption: awsPost._caption, categoryName: awsPost._categoryName, creationDate: awsPost._creationDate, imageUrl: awsPost._imageUrl, numberOfLikes: awsPost._numberOfLikes, user: self.user)
                        self.posts.append(post)
                        self.isLoadingPosts = false
                        self.tableView.reloadData()
                        
                        if let imageUrl = awsPost._imageUrl {
                            let indexPath = IndexPath(row: index, section: 1)
                            self.downloadImage(imageUrl, imageType: .postPic, indexPath: indexPath)
                        }
                    }
                    self.refreshControl?.endRefreshing()
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
                self.tableView.reloadData()
            case .postPic:
                self.posts[indexPath.row].image = image
                self.tableView.reloadData()
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
                                self.tableView.reloadData()
                            case .postPic:
                                self.posts[indexPath.row].image = image
                                self.tableView.reloadData()
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
    
    // Check if currentUser is following this user.
    fileprivate func getUserRelationship(_ followingId: String, indexPath: IndexPath) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getUserRelationshipDynamoDB(followingId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getUserRelationship error: \(error)")
                } else {
                    if task.result != nil {
                        self.isFollowing = true
                        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                    }
                }
            })
            return nil
        })
    }
    
    // Followings are done in background.
    fileprivate func followUser(_ followingId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserRelationshipDynamoDB(followingId, follower: self.currentUser,completionHandler: {
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
    
    fileprivate func queryUserExperiences(_ userId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUserExperiencesDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    print("queryUserExperiences error: \(error)")
                } else {
                    guard let awsUserExperiences = response?.items as? [AWSUserExperience] else {
                        return
                    }
                    guard awsUserExperiences.count > 0 else {
                        return
                    }
                    // Reset userExperiences.
                    self.userExperiences = []
                    self.workExperiences = []
                    self.educationExperiences = []
                    for awsUserExperience in awsUserExperiences {
                        let userExperience = UserExperience(userId: awsUserExperience._userId, experienceId: awsUserExperience._experienceId, position: awsUserExperience._position, organization: awsUserExperience._organization, fromDate: awsUserExperience._fromDate, toDate: awsUserExperience._toDate, experienceType: awsUserExperience._experienceType)
                        self.userExperiences.append(userExperience)
                    }
                    self.workExperiences = self.userExperiences.filter({$0.experienceType == 0})
                    self.educationExperiences = self.userExperiences.filter({$0.experienceType == 1})
                    //let workIndexSet = NSIndexSet(index: 3)
                    //let educationIndexSet = NSIndexSet(index: 4)
                    //self.tableView.reloadSections(workIndexSet, withRowAnimation: UITableViewRowAnimation.None)
                    //self.tableView.reloadSections(educationIndexSet, withRowAnimation: UITableViewRowAnimation.None)
                    self.tableView.reloadData()
                }
            })
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

extension ProfileTableViewController: LikeDelegate {
    
    func togglePostLike(_ postIndexPath: IndexPath?, numberOfLikes: NSNumber?) {
        guard let indexPath = postIndexPath else {
            return
        }
        guard let numberOfLikes = numberOfLikes else {
            return
        }
        self.posts[(indexPath as NSIndexPath).row].numberOfLikes = numberOfLikes
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
}
