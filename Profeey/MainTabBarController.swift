//
//  MainTabBarController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

enum MainChildController: Int {
    case home = 0
    case search = 1
    case capture = 2
    case notifications = 3
    case profile = 4
}

class MainTabBarController: UITabBarController {
    
    fileprivate var previousViewController: UIViewController?
    fileprivate var newNotificationsView: UIView?
    
    fileprivate var notifications: [PRFYNotification] = []
    fileprivate var isLoadingNotifications: Bool = false
    fileprivate var notificationsLastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    
    fileprivate var conversations: [Conversation] = []
    fileprivate var isLoadingConversations: Bool = false
    fileprivate var conversationsLastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    
    fileprivate var noNetworkConnection: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.whiteDark
        self.delegate = self
        self.configureTabBarItems()
        self.configureNewNotificationsView()
        
        if AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            // Get currentUser from DynamoDB upon initialization of this rootVc.
            self.getCurrentUser()
            // Query initial Notifications.
            self.isLoadingNotifications = true
            self.queryNotificationsDateSorted()
            // Query initial Conversations.
            self.isLoadingConversations = true
            self.queryConversationsDateSorted()
        }
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureTabBarItems() {
        // Set images for tabBar items
        for navigationController in self.childViewControllers {
            let tabBarItem = navigationController.tabBarItem
            if tabBarItem?.tag == 0 {
                guard let image = UIImage(named: "ic_home"), let selectedImage = UIImage(named: "ic_home_active") else {
                    return
                }
                tabBarItem?.image = image.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                tabBarItem?.selectedImage = selectedImage.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            }
            if tabBarItem?.tag == 1 {
                guard let image = UIImage(named: "ic_search"), let selectedImage = UIImage(named: "ic_search_active") else {
                    return
                }
                tabBarItem?.image = image.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                tabBarItem?.selectedImage = selectedImage
            }
            if tabBarItem?.tag == 2 {
                guard let image = UIImage(named: "ic_camera"), let selectedImage = UIImage(named: "ic_camera_active") else {
                    return
                }
                tabBarItem?.image = image.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                tabBarItem?.selectedImage = selectedImage
            }
            if tabBarItem?.tag == 3 {
                guard let image = UIImage(named: "ic_notifications"), let selectedImage = UIImage(named: "ic_notifications_active") else {
                    return
                }
                tabBarItem?.image = image.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                tabBarItem?.selectedImage = selectedImage
            }
            if tabBarItem?.tag == 4 {
                guard let image = UIImage(named: "ic_profile"), let selectedImage = UIImage(named: "ic_profile_active") else {
                    return
                }
                tabBarItem?.image = image.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                tabBarItem?.selectedImage = selectedImage
                
                // Set currentUser flag.
                if let childViewController = navigationController.childViewControllers[0] as? ProfileTableViewController {
                    childViewController.isCurrentUser = true
                }
            }
        }
    }
    
    fileprivate func configureNewNotificationsView() {
        guard let tabBarItemsCount = self.tabBar.items?.count else {
            return
        }
        let taBarItemWidth = self.tabBar.frame.width / CGFloat(tabBarItemsCount)
        // Position newNotificationsView close to middle and below notificaionsTabBarItem.
        let x = (taBarItemWidth * CGFloat(tabBarItemsCount - 2)) + (34.0)
        let y = self.tabBar.frame.height - 12.0
        let frame = CGRect(x: x, y: y, width: 8.0, height: 8.0)
        self.newNotificationsView = UIView(frame: frame)
        if self.newNotificationsView != nil {
            self.newNotificationsView!.backgroundColor = Colors.turquoise
            self.newNotificationsView!.layer.cornerRadius = 4.0
            self.tabBar.addSubview(self.newNotificationsView!)
            self.toggleNewNotificationsView(true)
        }
    }
    
    // MARK: Helpers
    
    fileprivate func showMissingUsernameFlow() {
        let navigationController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "missingUsernameNavigationController")
        self.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: Public
    
    // Open NotificationsVc as response to user tapping push notification.
    func selectNotificationsViewController() {
        self.selectedIndex = MainChildController.notifications.rawValue
    }
    
    func toggleNewNotificationsView(_ isHidden: Bool) {
        self.newNotificationsView?.isHidden = isHidden
    }
    
    // MARK: AWS
    
    // Gets currentUser and creates currentUserDynamoDB on PRFYDynamoDBManager singleton.
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
                    guard awsUser._preferredUsername != nil else {
                        // This only happens if users closes the app on the UsernameTableViewController of the Onboarding flow.
                        print("getCurrentUser error: currentUser doesn't have preferredUsername.")
                        self.showMissingUsernameFlow()
                        return
                    }
                    // Update locally.
                    PRFYDynamoDBManager.defaultDynamoDBManager().updateCurrentUserLocal(awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationId: awsUser._locationId, locationName: awsUser._locationName, profilePic: nil)
                    // Get profilePic.
                    if let profilePicUrl = awsUser._profilePicUrl {
                        PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: ImageType.userProfilePic)
                    }
                }
            })
            return nil
        })
    }
    
    // Preload notifications as soon as MainTabBar is loaded.
    fileprivate func queryNotificationsDateSorted() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryNotificationsDateSortedDynamoDB(nil, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryNotificationsDateSorted error: \(error!)")
                    self.isLoadingNotifications = false
                    if (error as! NSError).code == -1009 {
                        self.noNetworkConnection = true
                    }
                    return
                }
                if let awsNotifications = response?.items as? [AWSNotification] {
                    for awsNotification in awsNotifications {
                        let user = User(userId: awsNotification._notifierUserId, firstName: awsNotification._firstName, lastName: awsNotification._lastName, preferredUsername: awsNotification._preferredUsername, professionName: awsNotification._professionName, profilePicUrl: awsNotification._profilePicUrl)
                        let notification = PRFYNotification(userId: awsNotification._userId, notificationId: awsNotification._notificationId, creationDate: awsNotification._creationDate, notificationType: awsNotification._notificationType, postId: awsNotification._postId, user: user)
                        self.notifications.append(notification)
                    }
                }
                // Reset flags and animations that were initiated.
                self.isLoadingNotifications = false
                self.noNetworkConnection = false
                self.notificationsLastEvaluatedKey = response?.lastEvaluatedKey
            })
        })
    }
    
    // Preload conversations as soon as MainTabBar is loaded.
    fileprivate func queryConversationsDateSorted() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryConversationsDateSortedDynamoDB(nil, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryConversationsDateSorted error: \(error!)")
                    self.isLoadingConversations = false
                    if (error as! NSError).code == -1009 {
                        self.noNetworkConnection = true
                    }
                    return
                }
                if let awsConversations = response?.items as? [AWSConversation] {
                    for awsConversation in awsConversations {
                        let participant = User(userId: awsConversation._participantId, firstName: awsConversation._participantFirstName, lastName: awsConversation._participantLastName, preferredUsername: awsConversation._participantPreferredUsername, professionName: awsConversation._participantProfessionName, profilePicUrl: awsConversation._participantProfilePicUrl)
                        let conversation = Conversation(userId: awsConversation._userId, conversationId: awsConversation._conversationId, lastMessageText: awsConversation._lastMessageText, lastMessageCreated: awsConversation._lastMessageCreated, participant: participant)
                        self.conversations.append(conversation)
                    }
                }
                // Reset flags and animations that were initiated.
                self.isLoadingConversations = false
                self.noNetworkConnection = false
                self.conversationsLastEvaluatedKey = response?.lastEvaluatedKey
            })
        })
    }
}

extension MainTabBarController {
    
    // MARK: NotificationCenterActions
    
    func downloadImageNotification(_ notification: NSNotification) {
        guard let imageKey = notification.userInfo?["imageKey"] as? String, let imageType = notification.userInfo?["imageType"] as? ImageType, let imageData = notification.userInfo?["imageData"] as? Data else {
            return
        }
        guard imageType == ImageType.userProfilePic, imageKey == PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB?.profilePicUrl else {
            return
        }
        // Store profilePic.
        PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB?.profilePic = UIImage(data: imageData)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // If it's dummyCaptureNavigationController, don't show it and instead present Capture.storyboard.
        if let restorationIdentifier = viewController.restorationIdentifier, restorationIdentifier == "dummyCaptureNavigationController" {
            if let captureNavigationController = UIStoryboard(name: "Capture", bundle: nil).instantiateInitialViewController() {
                self.present(captureNavigationController, animated: true, completion: nil)
            }
            return false
        }
        
        if let navigationController = viewController as? UINavigationController, let childViewController = navigationController.childViewControllers[0] as? HomeTableViewController {
            // Set tabBarSwitch.
            childViewController.isTabBarSwitch = true
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let navigationController = viewController as? UINavigationController else {
            return
        }

        if let childViewController = navigationController.childViewControllers[0] as? HomeTableViewController {
            if self.previousViewController == childViewController || self.previousViewController == nil {
                childViewController.homeTabBarButtonTapped()
            }
            self.previousViewController = childViewController
        }
        if let childViewController = navigationController.childViewControllers[0] as? SearchViewController {
            if self.previousViewController == childViewController {
                childViewController.searchTabBarButtonTapped()
            }
            self.previousViewController = childViewController
        }
        if let childViewController = navigationController.childViewControllers[0] as? NotificationsViewController {
            if self.previousViewController == childViewController {
                childViewController.notificationsTabBarButtonTapped()
            }
            self.previousViewController = childViewController
            
            // Set downloaded Notifications and clear variables.
            childViewController.notifications = self.notifications
            childViewController.isLoadingNotifications = self.isLoadingNotifications
            childViewController.notificationsLastEvaluatedKey = self.notificationsLastEvaluatedKey
            self.notifications = []
            self.notificationsLastEvaluatedKey = nil
            // Set downloaded Conversations and clear variables.
            childViewController.conversations = self.conversations
            childViewController.isLoadingConversations = self.isLoadingConversations
            childViewController.conversationsLastEvaluatedKey = self.conversationsLastEvaluatedKey
            self.conversations = []
            self.conversationsLastEvaluatedKey = nil
            
            childViewController.noNetworkConnection = self.noNetworkConnection
        }
        if let childViewController = navigationController.childViewControllers[0] as? ProfileTableViewController {
            if self.previousViewController == childViewController {
                childViewController.profileTabBarButtonTapped()
            }
            self.previousViewController = childViewController
        }
    }
}
