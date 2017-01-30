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
import PhotosUI

enum MainChildController: Int {
    case home = 0
    case search = 1
    case capture = 2
    case notifications = 3
    case profile = 4
}

enum NotificationType: Int {
    case like = 0
    case comment = 1
    case following = 2
    case recommendation = 3
    case message = 4
}

class MainTabBarController: UITabBarController {
    
    fileprivate var previousViewController: UIViewController?
    fileprivate var newNotificationsView: UIView?
    
    // Special case when user opens the app, and not internet connection. Loading of currentUser has to be redone.
    fileprivate var isLoadingCurrentUser: Bool = false
    fileprivate var hasLoadedCurrentUser: Bool = false
    
    // Last seen date for Notifications.
    var lastSeenDate: NSNumber?
    fileprivate var isLoadingNotificationsCounter: Bool = false
    
    // Counter of unseen conversations.
    var unseenConversationsIds: [String] = []
    fileprivate var isLoadingNumberOfUnseenConversations = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.whiteDark
        self.delegate = self
        self.configureTabBarItems()
        self.configureNewNotificationsView()
        
        if AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            // Get currentUser from DynamoDB upon initialization of this rootVc.
            self.isLoadingCurrentUser = true
            self.getCurrentUser()
            // Get numberOfNewNotifications
            self.isLoadingNotificationsCounter = true
            self.getNotificationsCounter()
            // Query numberOfUnseenConversations.
            self.isLoadingNumberOfUnseenConversations = true
            self.queryUnseenConversations()
            
            // Set delegate.
            AWSPushManager.defaultPushManager().delegate = self
            /*
             It is safe to call it here. 
             The first time User install the app and Sings Up / Logs In it will 
             registerForPushNotifications and set new token.
             Other times it will just pass the same token.
             */
            AWSPushManager.defaultPushManager().interceptApplication(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        }
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.uiApplicationDidBecomeActiveNotification(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
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
        let frame = CGRect(x: x, y: y, width: 5.0, height: 5.0)
        self.newNotificationsView = UIView(frame: frame)
        self.newNotificationsView?.backgroundColor = Colors.red
        self.newNotificationsView?.layer.cornerRadius = 2.5
        if self.newNotificationsView != nil {
            self.tabBar.addSubview(self.newNotificationsView!)
            self.toggleNewNotificationsView(isHidden: true)
        }
    }
    
    // MARK: Helpers
    
    fileprivate func showMissingUsernameFlow() {
        let navigationController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "missingUsernameNavigationController")
        self.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: Public
    
    func toggleNewNotificationsView(isHidden: Bool) {
        self.newNotificationsView?.isHidden = isHidden
    }
    
    func updateUnseenConversationsIds(_ conversationId: String, shouldRemove: Bool) {
        if shouldRemove {
            guard let unseenConversationIdIndex = self.unseenConversationsIds.index(of: conversationId) else {
                return
            }
            self.unseenConversationsIds.remove(at: unseenConversationIdIndex)
        } else {
            guard self.unseenConversationsIds.index(of: conversationId) == nil else {
                return
            }
            self.unseenConversationsIds.append(conversationId)
        }
    }
    
    func updateUnseenConversationsBadge() {
        // Update inner app badge.
        self.tabBar.items?[3].badgeValue = self.unseenConversationsIds.count > 0 ? "\(self.unseenConversationsIds.count)" : nil
        // Update outer app badge.
        UIApplication.shared.applicationIconBadgeNumber = self.unseenConversationsIds.count > 0 ? self.unseenConversationsIds.count : 0
        // Update unseenConversationsView on NotificationsVc if visible.
        if let notificationsViewController = (self.selectedViewController as? UINavigationController)?.visibleViewController as? NotificationsViewController {
            notificationsViewController.unseenConversationsView.isHidden = self.unseenConversationsIds.count > 0 ? false : true
        }
    }
    
    // MARK: AWS
    
    // Gets currentUser and creates currentUserDynamoDB on PRFYDynamoDBManager singleton.
    fileprivate func getCurrentUser() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getCurrentUserDynamoDB({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingCurrentUser = false
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
                    // Set flag that currentUser has been loaded.
                    self.hasLoadedCurrentUser = true
                }
            })
            return nil
        })
    }
    
    // Check newNotifications every time app becomes active.
    fileprivate func getNotificationsCounter() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getNotificationsCounterDynamoDB({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingNotificationsCounter = false
                guard task.error == nil else {
                    print("getNotificationsCounter error: \(task.error!)")
                    return
                }
                if let awsNotificationsCounter = task.result as? AWSNotificationsCounter {
                    if let numberOfNewNotifications = awsNotificationsCounter._numberOfNewNotifications, numberOfNewNotifications.intValue > 0 {
                        self.toggleNewNotificationsView(isHidden: false)
                    } else {
                        self.toggleNewNotificationsView(isHidden: true)
                    }
                    self.lastSeenDate = awsNotificationsCounter._lastSeenDate
                }
                // Reset every time, even if notificationsCounter doesn't yet exists (new user).
                self.updateNotificationsCounter()
            })
        })
    }
    
    // After getting notificationsCounter, immediately set counter to 0 and update lastSeenDate.
    fileprivate func updateNotificationsCounter() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().updateNotificationsCounterDynamoDB({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    print("updateNotificationsCounter error: \(task.error!)")
                    return
                }
            })
        })
    }
    
    // Query unseenIndex aka where lastMessageSeen == 0.
    fileprivate func queryUnseenConversations() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryUnseenConversationsDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingNumberOfUnseenConversations = false
                guard error == nil else {
                    print("queryUnseenConversations error: \(error!)")
                    return
                }
                guard let awsConversations = response?.items as? [AWSConversation] else {
                    return
                }
                self.unseenConversationsIds = []
                for conversationId in awsConversations.flatMap({ $0._conversationId }) {
                    self.updateUnseenConversationsIds(conversationId, shouldRemove: false)
                }
                // Update badge.
                self.updateUnseenConversationsBadge()
            })
        })
    }
    
    // AppDelegate is calling this.
    func getMessage(_ conversationId: String, messageId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getMessageDynamoDB(conversationId, messageId: messageId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    print("getConversationMessage error: \(task.error!)")
                    return
                }
                guard let awsMessage = task.result as? AWSMessage else {
                    print("getMessage error: Not AWSMessage. This should not happen.")
                    return
                }
                let message = Message(conversationId: awsMessage._conversationId, messageId: awsMessage._messageId, created: awsMessage._created, messageText: awsMessage._messageText, senderId: awsMessage._senderId, recipientId: awsMessage._recipientId)
                // Update badge.
                self.updateUnseenConversationsIds(conversationId, shouldRemove: false)
                // Update badge only if not on MessagesVc to avoid annoying badge toggle.
                if !((self.selectedViewController as? UINavigationController)?.visibleViewController is MessagesViewController) {
                    self.updateUnseenConversationsBadge()
                }
                // Notify observers.
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: APNsNewMessageNotificationKey), object: self, userInfo: ["message": message])
            })
            return nil
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
    
    func uiApplicationDidBecomeActiveNotification(_ notification: NSNotification) {
        guard AWSIdentityManager.defaultIdentityManager().isLoggedIn == true else {
            return
        }
        if !self.isLoadingCurrentUser && !self.hasLoadedCurrentUser {
            // Special case (no internet connection) when currentUser hasn't been loaded.
            self.getCurrentUser()
        }
        if !self.isLoadingNotificationsCounter {
            self.getNotificationsCounter()
        }
        if !self.isLoadingNumberOfUnseenConversations {
            self.queryUnseenConversations()
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // If it's dummyCaptureNavigationController, don't show it and instead present Capture.storyboard.
        if let restorationIdentifier = viewController.restorationIdentifier, restorationIdentifier == "dummyCaptureNavigationController" {
            if let captureNavigationController = UIStoryboard(name: "Capture", bundle: nil).instantiateInitialViewController() {
                
                // Check Photos access for the first time.
                if PHPhotoLibrary.authorizationStatus() == .notDetermined {
                    PHPhotoLibrary.requestAuthorization({
                        (status: PHAuthorizationStatus) in
                        self.present(captureNavigationController, animated: true, completion: nil)
                    })
                } else {
                    self.present(captureNavigationController, animated: true, completion: nil)
                }
            }
            return false
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
            // Clear newNotificationsView.
            self.toggleNewNotificationsView(isHidden: true)
        }
        if let childViewController = navigationController.childViewControllers[0] as? ProfileTableViewController {
            if self.previousViewController == childViewController {
                childViewController.profileTabBarButtonTapped()
            }
            self.previousViewController = childViewController
        }
    }
}

extension MainTabBarController: AWSPushManagerDelegate {
    
    func pushManagerDidRegister(_ pushManager: AWSPushManager) {
        print("pushManagerDidRegister:")
        if let endpointARN = AWSPushManager.defaultPushManager().endpointARN {
            print(endpointARN)
        }
        // When user Signs Up and accepts remote notifications, create an EnpointUser in DynamoDB. Be sure to delete it on sign out.
        if let endpointARN = AWSPushManager.defaultPushManager().endpointARN {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            PRFYDynamoDBManager.defaultDynamoDBManager().createEndpointUserDynamoDB(endpointARN, completionHandler: {
                (task: AWSTask) in
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let error = task.error {
                        print("createEndpointUser error :\(error)")
                    }
                })
                return nil
            })
        }
    }
    
    func pushManager(_ pushManager: AWSPushManager, didFailToRegisterWithError error: Error) {
        // Do nothing.
    }
    
    func pushManager(_ pushManager: AWSPushManager, didReceivePushNotification userInfo: [AnyHashable : Any]) {
        
        print("Hello it's hereeee")
        // Do nothing.
        
        // Try fix bug here.
    }
    
    func pushManagerDidDisable(_ pushManager: AWSPushManager) {
        // Do nothing.
    }
    
    func pushManager(_ pushManager: AWSPushManager, didFailToDisableWithError error: Error) {
        // Do nothing.
    }
}

extension MainTabBarController: AWSPushTopicDelegate {
    
    func topicDidSubscribe(_ topic: AWSPushTopic) {
        // Do nothing.
    }
    
    func topic(_ topic: AWSPushTopic, didFailToSubscribeWithError error: Error) {
        // Do nothing.
    }
    
    func topicDidUnsubscribe(_ topic: AWSPushTopic) {
        // Do nothing.
    }
    
    func topic(_ topic: AWSPushTopic, didFailToUnsubscribeWithError error: Error) {
        // Do nothing.
    }
}
