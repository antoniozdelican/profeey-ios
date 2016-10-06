//
//  CaptureScrollViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 29/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class CaptureScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    // If it's profilePic make it square.
    var isProfilePic: Bool = false
    var profilePicUnwind: ProfilePicUnwind?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Prepare scrollView to show camera first.
        self.scrollView.layoutIfNeeded()
        self.scrollView.contentOffset = CGPoint(x: self.view.bounds.width, y: 0.0)
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? CaptureViewController {
            childViewController.captureDelegate = self
            childViewController.isProfilePic = self.isProfilePic
            childViewController.profilePicUnwind = self.profilePicUnwind
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? GalleryViewController {
            childViewController.galleryDelegate = self
            childViewController.isProfilePic = self.isProfilePic
            childViewController.profilePicUnwind = self.profilePicUnwind
        }
    }
}

extension CaptureScrollViewController: CaptureDelegate {
    
    func galleryButtonTapped() {
        // Scroll to gallery.
        self.scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
}

extension CaptureScrollViewController: GalleryDelegate {
    
    func cameraButtonTapped() {
        // Scroll to camera.
        self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0.0), animated: true)
    }
}
