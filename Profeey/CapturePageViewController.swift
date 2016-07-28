//
//  CapturePageViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class CapturePageViewController: UIPageViewController {
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.configureGalleryViewController(),
                self.configureCaptureViewController()]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.automaticallyAdjustsScrollViewInsets = false
        self.dataSource = self
        self.delegate = self
        
        if let currentViewController = self.orderedViewControllers[1] as? CaptureProfilePicViewController {
            self.setViewControllers(
                [currentViewController],
                direction: .Forward,
                animated: true,
                completion: nil)
            self.navigationItem.setRightBarButtonItem(currentViewController.switchCameraButton, animated: true)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    private func configureCaptureViewController() -> UIViewController {
        return self.storyboard!.instantiateViewControllerWithIdentifier("CaptureProfilePicVc")
    }
    
    private func configureGalleryViewController() -> UIViewController {
        return self.storyboard!.instantiateViewControllerWithIdentifier("GalleryCollectionVc")
    }
    
    // MARK: IBActions
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CapturePageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }
}

extension CapturePageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewControllers = pageViewController.viewControllers else {
            return
        }
        // pageViewController.viewControllers[0] is always currentViewController.
        if let currentViewController = viewControllers[0] as? CaptureProfilePicViewController {
            self.navigationItem.titleView = UIView()
            self.navigationItem.setRightBarButtonItem(currentViewController.switchCameraButton, animated: true)
        } else if let currentViewController = viewControllers[0] as? GalleryCollectionViewController {
            self.navigationItem.titleView = currentViewController.albumNameButton
            self.navigationItem.setRightBarButtonItem(UIBarButtonItem(), animated: true)
        }
    }
    
}
