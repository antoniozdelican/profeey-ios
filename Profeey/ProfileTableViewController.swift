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
    case skills
}

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet var loadingTableFooterView: UIView!
    
    var user: User?
    var isCurrentUser: Bool = false
    
    fileprivate var isLoadingUser = true
    fileprivate var isLoadingRelationship = true
    fileprivate var isFollowing: Bool = false
    fileprivate var isLoadingBlock = true
    fileprivate var isBlocking: Bool = false
    fileprivate var isLoadingAmIBlocked = true
    fileprivate var amIBlocked: Bool = false
    
    fileprivate var posts: [Post] = []
    fileprivate var isLoadingPosts: Bool = false
    fileprivate var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    fileprivate var hasLoadedInitialPosts: Bool = false
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createReportNotification(_:)), name: NSNotification.Name(CreateReportNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.blockUserNotification(_:)), name: NSNotification.Name(BlockUserNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.unblockUserNotification(_:)), name: NSNotification.Name(UnblockUserNotificationKey), object: nil)
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
        
        // First check if not blocked.
        if !self.isCurrentUser {
            self.getAmIBlocked(userId)
        } else {
            self.queryUserData(userId)
        }
    }
    
    fileprivate func queryUserData(_ userId: String) {
        // Query user.
        self.isLoadingUser = true
        self.getUser(userId)
        // Query other.
        switch self.selectedProfileSegment {
        case .posts:
            self.isLoadingPosts = true
            self.tableView.tableFooterView = self.loadingTableFooterView
            self.queryPostsDateSorted(userId, startFromBeginning: true)
        case .skills:
            self.isLoadingUserCategories = true
            self.tableView.tableFooterView = self.loadingTableFooterView
            self.queryUserCategoriesNumberOfPostsSorted(userId)
        }
    }
    
    // MARK: Early AWS
    
    fileprivate func getAmIBlocked(_ userId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getAmIBlockedDynamoDB(userId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    print("getAmIBlocked error: \(error)")
                } else {
                    self.isLoadingAmIBlocked = false
                    if let awsBlocks = response?.items as? [AWSBlock], awsBlocks.count != 0 {
                        self.amIBlocked = true
                        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.numberOfPostsButton.isEnabled = false
                        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.numberOfFollowersButton.isEnabled = false
                        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.numberOfCategoriesButton.isEnabled = false
                        // I can block as well.
                        self.settingsButton = UIBarButtonItem(image: UIImage(named: "ic_more_vertical_big"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.blockButtonTapped(_:)))
                        self.navigationItem.rightBarButtonItem = self.settingsButton
                        // Get block for other as well so I can block them too.
                        self.getBlock(userId)
                    } else {
                        self.amIBlocked = false
                        self.queryUserData(userId)
                    }
                    self.tableView.reloadData()
                }
            })
        })
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
        if let destinationViewController = segue.destination as? MessagesViewController {
            destinationViewController.participant = self.user?.copyUser()
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController =  navigationController.childViewControllers[0] as? ReportTableViewController {
            if let cell = sender as? PostSmallTableViewCell, let indexPath = self.tableView.indexPath(for: cell) {
                childViewController.userId = self.posts[indexPath.row].userId
                childViewController.postId = self.posts[indexPath.row].postId
                childViewController.reportType = ReportType.post
            } else {
                childViewController.userId = self.user?.userId
                childViewController.reportType = ReportType.user
            }
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController =  navigationController.childViewControllers[0] as? EditPostTableViewController,
            let cell = sender as? PostSmallTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            childViewController.editPost = self.posts[indexPath.row].copyEditPost()
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
            if !self.isLoadingPosts && self.posts.count == 0 || self.isBlocking || self.amIBlocked {
                return 1
            }
            return self.posts.count
        case .skills:
            if !self.isLoadingUserCategories && self.userCategories.count == 0 || self.isBlocking || self.amIBlocked {
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
                cell.numberOfCategoriesButton.setTitle(self.user?.numberOfCategoriesInt.numberToString(), for: UIControlState.normal)
                if self.isCurrentUser {
                    cell.messageButton.isHidden = true
                    cell.messageButtonWidthConstraint.constant = 0.0
                    if !self.isLoadingUser {
                        cell.setEditButton()
                    }
                } else {
                    if !self.isLoadingBlock && !self.isBlocking && !self.isLoadingRelationship {
                        self.isFollowing ? cell.setFollowingButton() : cell.setFollowButton()
                        cell.messageButton.isHidden = false
                    } else {
                        cell.messageButton.isHidden = true
                    }
                }
                cell.profileMainTableViewCellDelegate = self
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileInfo", for: indexPath) as! ProfileInfoTableViewCell
                cell.fullNameLabel.text = self.user?.fullName
                cell.professionNameLabel.text = self.user?.professionNameWhitespace
                cell.schoolNameLabel.text = self.user?.schoolName
                cell.schoolStackView.isHidden = self.user?.schoolName != nil ? false : true
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
            if self.posts.count == 0 || self.isBlocking || self.amIBlocked {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileEmpty", for: indexPath) as! ProfileEmptyTableViewCell
                cell.emptyMessageLabel.text = !self.amIBlocked ? "No posts yet." : "You are blocked from following and viewing this account."
                cell.addButton.isHidden = self.isCurrentUser ? false : true
                cell.addButtonType = AddButtonType.post
                cell.setAddPostButton()
                cell.profileEmptyTableViewCellDelegate = self
                return cell
            }
            // Reported posts.
            if self.posts[indexPath.row].isReportedByCurrentUser {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostReport", for: indexPath) as! PostReportTableViewCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostSmall", for: indexPath) as! PostSmallTableViewCell
            let post = self.posts[indexPath.row]
            cell.postImageView.image = post.image
            cell.titleLabel.text = post.caption
            cell.categoryNameLabel.text = post.categoryNameWhitespace
            cell.createdLabel.text = post.createdString
            cell.numberOfLikesLabel.text = post.numberOfLikesSmallString
            cell.postSmallTableViewCellDelegate = self
            return cell
        case .skills:
            if self.userCategories.count == 0 || self.isBlocking || self.amIBlocked {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileEmpty", for: indexPath) as! ProfileEmptyTableViewCell
                cell.emptyMessageLabel.text = !self.amIBlocked ? "No posts with skills yet." : "You are blocked from following and viewing this account."
                cell.addButton.isHidden = self.isCurrentUser ? false : true
                cell.addButtonType = AddButtonType.post
                cell.setAddPostButton()
                cell.profileEmptyTableViewCellDelegate = self
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellUserCategory", for: indexPath) as! UserCategoryTableViewCell
            let userCategory = self.userCategories[indexPath.row]
            cell.categoryNameLabel.text = userCategory.categoryNameWhitespace
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
            if self.posts.count == 0 || self.isBlocking || self.amIBlocked {
                return 112.0
            }
            return 112.0
        case .skills:
            if self.userCategories.count == 0 || self.isBlocking || self.amIBlocked {
                return 112.0
            }
            return 58.0
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
            if self.posts.count == 0 || self.isBlocking || self.amIBlocked {
                return 112.0
            }
            return 112.0
        case .skills:
            if self.userCategories.count == 0 || self.isBlocking || self.amIBlocked {
                return 112.0
            }
            return UITableViewAutomaticDimension
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
            return 38.0
        }
        return 0.0
    }
    
    // MARK: Tappers
    
    func settingsButtonTapped(_ sender: AnyObject) {
        if self.isCurrentUser {
            self.performSegue(withIdentifier: "segueToSettingsVc", sender: self)
        }
    }
    
    func blockButtonTapped(_ sender: AnyObject) {
        if !self.isCurrentUser, !self.isLoadingBlock, let blockingId = self.user?.userId, let preferredUsername = self.user?.preferredUsername {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            // Block/Unblock.
            if !self.isBlocking {
                let blockAction = UIAlertAction(title: "Block", style: UIAlertActionStyle.destructive, handler: {
                    (alert: UIAlertAction) in
                    let alertController = UIAlertController(title: "Block \(preferredUsername)", message: "If you block \(preferredUsername), you won't be able to follow or interact with each other.", preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    let blockConfirmAction = UIAlertAction(title: "Block", style: UIAlertActionStyle.destructive, handler: {
                        (alert: UIAlertAction) in
                        // In background.
                        self.createBlock(blockingId)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: BlockUserNotificationKey), object: self, userInfo: ["blockingId": blockingId])
                        
                    })
                    alertController.addAction(blockConfirmAction)
                    self.present(alertController, animated: true, completion: nil)
                })
                alertController.addAction(blockAction)
                
            } else {
                let unblockAction = UIAlertAction(title: "Unblock", style: UIAlertActionStyle.destructive, handler: {
                    (alert: UIAlertAction) in
                    // In background.
                    self.removeBlock(blockingId)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: UnblockUserNotificationKey), object: self, userInfo: ["blockingId": blockingId])
                })
                alertController.addAction(unblockAction)
            }
            // Report.
            let reportAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.destructive, handler: {
                (alert: UIAlertAction) in
                self.performSegue(withIdentifier: "segueToReportVc", sender: sender)
            })
            alertController.addAction(reportAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
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
                let user = FullUser(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, schoolId: awsUser._schoolId, schoolName: awsUser._schoolName, website: awsUser._website, about: awsUser._about, numberOfFollowers: awsUser._numberOfFollowers, numberOfPosts: awsUser._numberOfPosts, numberOfCategories: awsUser._numberOfCategories, email: awsUser._email, emailVerified: awsUser._emailVerified, isFacebookUser: awsUser._isFacebookUser)
                self.user = user
                
                // Reset flags and animations that were initiated.
                self.isLoadingUser = false
                
                self.navigationItem.title = self.user?.preferredUsername
                self.refreshControl?.endRefreshing()
                
                // Set/reinit settings button. This happens only once.
                if !self.isSettingsButtonSet {
                    self.isSettingsButtonSet = true
                    if self.isCurrentUser {
                        self.settingsButton = UIBarButtonItem(image: UIImage(named: "ic_settings"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.settingsButtonTapped(_:)))
                    } else {
                        self.settingsButton = UIBarButtonItem(image: UIImage(named: "ic_more_vertical_big"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.blockButtonTapped(_:)))
                    }
                    self.navigationItem.rightBarButtonItem = self.settingsButton
                    
                }
                
                // Reload cells with downloaded user.
                if self.isCurrentUser {
                    (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.setEditButton()
                }
                let profileInfoTableViewCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ProfileInfoTableViewCell
                profileInfoTableViewCell?.fullNameLabel.text = self.user?.fullName
                profileInfoTableViewCell?.professionNameLabel.text = self.user?.professionNameWhitespace
                profileInfoTableViewCell?.schoolNameLabel.text = self.user?.schoolName
                profileInfoTableViewCell?.schoolStackView.isHidden = self.user?.schoolName != nil ? false : true
                profileInfoTableViewCell?.aboutLabel.text = self.user?.about
                profileInfoTableViewCell?.websiteButton.setTitle(self.user?.website, for: UIControlState.normal)
                profileInfoTableViewCell?.websiteButton.isHidden = self.user?.website != nil ? false : true
                self.tableView.reloadData()
                
                
                // Load profilePic.
                if let profilePicUrl = awsUser._profilePicUrl {
                    PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                }
                
                // Load block before relationship.
                if let userId = awsUser._userId, !self.isCurrentUser {
                    self.getBlock(userId)
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
                        // Immediately getLike.
                        if let postId = awsPost._postId {
                            self.getLike(postId)
                        }
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
                    // Show messageButton.
                    (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.messageButton.isHidden = false
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
    
    // In background.
    fileprivate func removePost(_ postId: String, imageKey: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removePostDynamoDB(postId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("removePost error: \(error)")
                } else {
                    PRFYS3Manager.defaultS3Manager().removeImageS3(imageKey)
                }
            })
            return nil
        })
    }
    
    fileprivate func getBlock(_ userId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getBlockDynamoDB(userId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getBlock error: \(error)")
                } else {
                    self.isLoadingBlock = false
                    if task.result != nil {
                        self.isBlocking = true
                        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell
                        cell?.messageButton.isHidden = true
                        cell?.setBlockingButton()
                    } else {
                        self.isBlocking = false
                        // Load relationship only if not blocking and not blocked.
                        if !self.amIBlocked {
                            self.getRelationship(userId)
                        }
                    }
                    self.tableView.reloadData()
                }
            })
            return nil
        })
    }
    
    // In background.
    fileprivate func createBlock(_ blockingId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().createBlockDynamoDB(blockingId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("createBlock error: \(error)")
                }
                // Unfollow as well in background.
                self.unfollowUser(blockingId)
            })
            return nil
        })
    }
    
    // In background.
    fileprivate func removeBlock(_ blockingId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removeBlockDynamoDB(blockingId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("removeBlock error: \(error)")
                }
            })
            return nil
        })
    }
    
    fileprivate func getLike(_ postId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getLikeDynamoDB(postId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("getLike error: \(error)")
                } else {
                    if task.result != nil, let postIndex = self.posts.index(where: { $0.postId == postId }) {
                        // Update data source and cells.
                        let post = self.posts[postIndex]
                        post.isLikedByCurrentUser = true
                        // Notify observers (PostDetailsVc).
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: GetLikeNotificationKey), object: self, userInfo: ["postId": postId])
                    }
                }
            })
            return nil
        })
    }
    
    // MARK: Helpers
    
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
        if self.selectedProfileSegment == ProfileSegment.posts {
            if self.posts.count > 0 {
               self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: UITableViewScrollPosition.top, animated: true)
            }
        } else {
            if let segmentedControl = (self.tableView.headerView(forSection: 1) as? ProfileSegmentedControlSectionHeader)?.segmentedControl {
                segmentedControl.selectedSegmentIndex = 0
                self.segmentChanged(ProfileSegment.posts)
            }
        }
    }
    
    func numberOfFollowersButtonTapped() {
        self.performSegue(withIdentifier: "segueToFollowersFollowingVc", sender: self)
    }
    
    func numberOfCategoriesButtonTapped() {
        if self.selectedProfileSegment == ProfileSegment.skills {
            if self.userCategories.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: UITableViewScrollPosition.top, animated: true)
            }
        } else {
            if let segmentedControl = (self.tableView.headerView(forSection: 1) as? ProfileSegmentedControlSectionHeader)?.segmentedControl {
                segmentedControl.selectedSegmentIndex = 1
                self.segmentChanged(ProfileSegment.skills)
            }
        }
    }
    
    func followButtonTapped() {
        if self.isCurrentUser, !self.isLoadingUser {
            self.performSegue(withIdentifier: "segueToEditProfileVc", sender: self)
        } else if !self.isLoadingBlock, self.isBlocking {
            self.blockButtonTapped(self)
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
    
    func messageButtonTapped() {
        self.performSegue(withIdentifier: "segueToMessagesVc", sender: self)
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
        self.user?.schoolId = editUser.schoolId
        self.user?.schoolName = editUser.schoolName
        self.user?.about = editUser.about
        self.user?.website = editUser.website
        self.user?.profilePic = editUser.profilePic
        // Update cells.
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.profilePicImageView.image = self.user?.profilePic
        let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ProfileInfoTableViewCell
        cell?.fullNameLabel.text = self.user?.fullName
        cell?.professionNameLabel.text = self.user?.professionNameWhitespace
        cell?.schoolNameLabel.text = self.user?.schoolName
        cell?.schoolStackView.isHidden = self.user?.schoolName != nil ? false : true
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
            (self.tableView.cellForRow(at: IndexPath(row: postIndex, section: 1)) as? PostSmallTableViewCell)?.categoryNameLabel.text = post.categoryNameWhitespace
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
    
    func createReportNotification(_ notification: NSNotification) {
        guard let postId = notification.userInfo?["postId"] as? String, notification.userInfo?["commentId"] == nil else {
            return
        }
        guard let postIndex = self.posts.index(where: { $0.postId == postId }) else {
            return
        }
        let post = self.posts[postIndex]
        post.isReportedByCurrentUser = true
        if self.selectedProfileSegment == ProfileSegment.posts {
            self.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 1)], with: UITableViewRowAnimation.none)
        }
    }
    
    func blockUserNotification(_ notification: NSNotification) {
        guard let blockingId = notification.userInfo?["blockingId"] as? String else {
            return
        }
        guard self.user?.userId == blockingId else {
            return
        }
        guard !self.isLoadingBlock, !self.isBlocking else {
            return
        }
        self.isBlocking = true
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.messageButton.isHidden = true
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.setBlockingButton()
        self.tableView.reloadData()
    }
    
    func unblockUserNotification(_ notification: NSNotification) {
        guard let blockingId = notification.userInfo?["blockingId"] as? String else {
            return
        }
        guard self.user?.userId == blockingId else {
            return
        }
        guard !self.isLoadingBlock, self.isBlocking else {
            return
        }
        self.isBlocking = false
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.messageButton.isHidden = false
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileMainTableViewCell)?.setFollowButton()
        
        // Load relationship.
        self.isLoadingRelationship = true
        self.getRelationship(blockingId)
        self.tableView.reloadData()
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
        }
    }
}

extension ProfileTableViewController: PostSmallTableViewCellDelegate {
    
    func moreButtonTapped(_ cell: PostSmallTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        let post = self.posts[indexPath.row]
        guard let postId = post.postId, let postUserId = post.userId, let imageKey = post.imageUrl else {
            return
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        // Share.
        let shareAction = UIAlertAction(title: "Share", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction) in
            var activityItems:[Any] = []
            if postUserId != AWSIdentityManager.defaultIdentityManager().identityId, let preferredUsername = post.user?.preferredUsername {
                activityItems.append("\(preferredUsername)'s post")
            }
            if let image = post.image {
                activityItems.append(image)
            }
            let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            activityController.popoverPresentationController?.barButtonItem = UIBarButtonItem(title: "Share", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
            self.present(activityController, animated: true, completion: nil)
        })
        alertController.addAction(shareAction)
        
        if postUserId == AWSIdentityManager.defaultIdentityManager().identityId {
            // Edit.
            let editAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction) in
                self.performSegue(withIdentifier: "segueToEditPostVc", sender: cell)
            })
            alertController.addAction(editAction)
            // Delete.
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {
                (alert: UIAlertAction) in
                let alertController = UIAlertController(title: "Delete Post?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction)
                let deleteConfirmAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: {
                    (alert: UIAlertAction) in
                    // In background
                    self.removePost(postId, imageKey: imageKey)
                    // Notifiy observers.
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: DeletePostNotificationKey), object: self, userInfo: ["postId": postId])
                })
                alertController.addAction(deleteConfirmAction)
                self.present(alertController, animated: true, completion: nil)
            })
            alertController.addAction(deleteAction)
        } else {
            // Report.
            let reportAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.destructive, handler: {
                (alert: UIAlertAction) in
                self.performSegue(withIdentifier: "segueToReportVc", sender: cell)
            })
            alertController.addAction(reportAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
