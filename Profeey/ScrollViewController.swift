//
//  ScrollViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 29/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Prepare scrollView to show camera first.
        self.scrollView.layoutIfNeeded()
        self.scrollView.contentOffset = CGPointMake(self.view.bounds.width, 0.0)

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? CaptureViewController {
            childViewController.captureDelegate = self
        }
        if let navigationController = segue.destinationViewController as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? GalleryViewController {
            childViewController.galleryDelegate = self
        }
    }
}

extension ScrollViewController: CaptureDelegate {
    
    func galleryButtonTapped() {
        // Scroll to gallery.
        self.scrollView.setContentOffset(CGPointMake(0.0, 0.0), animated: true)
    }
}

extension ScrollViewController: GalleryDelegate {
    
    func cameraButtonTapped() {
        // Scroll to camera.
        self.scrollView.setContentOffset(CGPointMake(self.view.bounds.width, 0.0), animated: true)
    }
}
