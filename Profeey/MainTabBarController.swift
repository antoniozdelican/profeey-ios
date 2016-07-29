//
//  MainTabBarController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set delegation to its own tabBar
        self.delegate = self
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    func configureView() {
        // Set images for tabBar items
        // Fetch child navbarControllers to set tabItems since they are in different storyboards
        for navController in self.childViewControllers {
            let tbItem = navController.tabBarItem
            if tbItem.tag == 0 {
                guard let image = UIImage(named: "ic_home"), let selectedImage = UIImage(named: "ic_home_selected") else {
                    return
                }
                tbItem.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                tbItem.selectedImage = selectedImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            }
            if tbItem.tag == 1 {
                guard let image = UIImage(named: "ic_search"), let selectedImage = UIImage(named: "ic_search_selected") else {
                    return
                }
                tbItem.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                tbItem.selectedImage = selectedImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            }
            if tbItem.tag == 2 {
                guard let image = UIImage(named: "ic_capture"), let selectedImage = UIImage(named: "ic_capture_selected") else {
                    return
                }
                tbItem.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                tbItem.selectedImage = selectedImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            }
            if tbItem.tag == 3 {
                guard let image = UIImage(named: "ic_notifications"), let selectedImage = UIImage(named: "ic_notifications_selected") else {
                    return
                }
                tbItem.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                tbItem.selectedImage = selectedImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            }
            if tbItem.tag == 4 {
                guard let image = UIImage(named: "ic_profile"), let selectedImage = UIImage(named: "ic_profile_selected") else {
                    return
                }
                tbItem.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                tbItem.selectedImage = selectedImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            }
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        // If view controller is Dummy controller, don't show it and instead get CaptureScrollViewController
        if viewController is FakeCaptureNavigationController {
            let caputeViewController = UIStoryboard(name: "Capture", bundle: nil).instantiateViewControllerWithIdentifier("captureScrollViewController")
            self.presentViewController(caputeViewController, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
}
