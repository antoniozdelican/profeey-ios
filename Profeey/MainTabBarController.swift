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
}
