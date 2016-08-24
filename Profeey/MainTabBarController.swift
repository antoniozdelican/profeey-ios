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
        for navigationController in self.childViewControllers {
            let tabBarItem = navigationController.tabBarItem
            if tabBarItem.tag == 0 {
                guard let image = UIImage(named: "ic_home"), let selectedImage = UIImage(named: "ic_home_selected") else {
                    return
                }
                tabBarItem.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                tabBarItem.selectedImage = selectedImage
            }
            if tabBarItem.tag == 1 {
                guard let image = UIImage(named: "ic_search"), let selectedImage = UIImage(named: "ic_search_selected") else {
                    return
                }
                tabBarItem.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                tabBarItem.selectedImage = selectedImage
            }
            if tabBarItem.tag == 2 {
                guard let image = UIImage(named: "ic_capture"), let selectedImage = UIImage(named: "ic_capture_selected") else {
                    return
                }
                tabBarItem.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                tabBarItem.selectedImage = selectedImage
            }
            if tabBarItem.tag == 3 {
                guard let image = UIImage(named: "ic_notifications"), let selectedImage = UIImage(named: "ic_notifications_selected") else {
                    return
                }
                tabBarItem.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                tabBarItem.selectedImage = selectedImage
            }
            if tabBarItem.tag == 4 {
                guard let image = UIImage(named: "ic_profile"), let selectedImage = UIImage(named: "ic_profile_selected") else {
                    return
                }
                tabBarItem.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                tabBarItem.selectedImage = selectedImage
                
                // Set currentUser flag.
                if let childViewController = navigationController.childViewControllers[0] as? ProfileTableViewController {
                    childViewController.isCurrentUser = true
                }
            }
        }
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("here")
        print(segue.destinationViewController)
        if let navigationController = segue.destinationViewController as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? ProfileTableViewController {
            print("YEEES")
            childViewController.isCurrentUser = true
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
