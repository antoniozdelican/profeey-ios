//
//  MainTabBarController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

enum MainChildController: Int {
    case home = 0
    case search = 1
    case notifications = 2
    case profile = 3
}

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.whiteDark
        self.delegate = self
        self.configureView()
        self.configureStatusBar()
        
        // Get currentUser from DynamoDB upon initialization of this rootVc.
        if AWSIdentityManager.defaultIdentityManager().isLoggedIn && PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB == nil {
            self.getCurrentUser()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureView() {
        // Set images for tabBar items
        for navigationController in self.childViewControllers {
            let tabBarItem = navigationController.tabBarItem
            if tabBarItem?.tag == 0 {
                guard let image = UIImage(named: "ic_home"), let selectedImage = UIImage(named: "ic_home_active") else {
                    return
                }
                tabBarItem?.image = image.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                // Because of different selected color.
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
                guard let image = UIImage(named: "ic_notifications"), let selectedImage = UIImage(named: "ic_notifications_active") else {
                    return
                }
                tabBarItem?.image = image.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                tabBarItem?.selectedImage = selectedImage
            }
            if tabBarItem?.tag == 3 {
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
    
    // Add backgroundView and color behind statusBar.
    fileprivate func configureStatusBar() {
        let statusBarFrame = UIApplication.shared.statusBarFrame
        let statusBarBackgroundView = UIView(frame: statusBarFrame)
        statusBarBackgroundView.backgroundColor = Colors.whiteDark
        self.view.addSubview(statusBarBackgroundView)
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
                        // This only happens if users closes the app on the UsernameTableViewController of the Welcome flow.
                        print("getCurrentUser error: currentUser doesn't have preferredUsername.")
                        self.redirectToWelcome()
                        return
                    }
                    let currentUser = CurrentUser(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationName: awsUser._locationName)
                    // Store properties.
                    PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB = currentUser
                    // Get profilePic.
                    if let profilePicUrl = awsUser._profilePicUrl {
                        self.downloadImage(profilePicUrl, imageType: .currentUserProfilePic)
                    }
                }
            })
            return nil
        })
    }
    
    fileprivate func downloadImage(_ imageKey: String, imageType: ImageType) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let content = AWSUserFileManager.defaultUserFileManager().content(withKey: imageKey)
        // TODO check if content.isImage()
        if content.isCached {
            print("Content cached:")
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            let image = UIImage(data: content.cachedData)
            switch imageType {
            case .currentUserProfilePic:
                // Store profilePic.
                PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB?.profilePic = image
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
                    (content: AWSContent?, data: Data?, error:  Error?) in
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if let error = error {
                            print("downloadImage error: \(error)")
                        } else {
                            if let imageData = data {
                                let image = UIImage(data: imageData)
                                switch imageType {
                                case .currentUserProfilePic:
                                    // Store profilePic.
                                    PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB?.profilePic = image
                                default:
                                    return
                                }
                            }
                        }
                    })
            })
        }
    }
    
    // MARK: Helpers
    
    fileprivate func redirectToWelcome() {
        guard let window = UIApplication.shared.keyWindow,
            let initialViewController = UIStoryboard(name: "Welcome", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
    
    // MARK: Public
    
    // Public method to open NotificationsVc as response to user tapping push notification.
    func selectMainChildViewController(_ mainChildController: MainChildController) {
        self.selectedIndex = mainChildController.rawValue
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let navigationController = viewController as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? HomeTableViewController {
            // Set tabBarSwitch.
            childViewController.isTabBarSwitch = true
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let navigationController = viewController as? UINavigationController else {
            return
        }
        if let childViewController = navigationController.childViewControllers[0] as? HomeTableViewController, tabBarController.selectedIndex == 0 {
            childViewController.navigationController?.setNavigationBarHidden(false, animated: true)
            // Offset is 1.0 on y due to the inset of -1.0 and upper separator.
            childViewController.tableView.setContentOffset(CGPoint(x: 0.0, y: 1.0), animated: true)
        }
        if let childViewController = navigationController.childViewControllers[0] as? SearchViewController, tabBarController.selectedIndex == 1 {
            childViewController.searchTabBarButtonTapped()
        }
        if let childViewController = navigationController.childViewControllers[0] as? NotificationsTableViewController, tabBarController.selectedIndex == 2 {
            childViewController.tableView.setContentOffset(CGPoint.zero, animated: true)
        }
        if let childViewController = navigationController.childViewControllers[0] as? ProfileTableViewController, tabBarController.selectedIndex == 3 {
            childViewController.tableView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
}
