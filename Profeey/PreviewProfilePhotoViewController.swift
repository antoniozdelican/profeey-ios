//
//  PreviewProfilePhotoViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 01/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol PreviewProfilePicDelegate {
    func saveProfilePic(profilePic: UIImage)
}

class PreviewProfilePhotoViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var photo: UIImage!
    var previewProfilePicDelegate: PreviewProfilePicDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoImageView.clipsToBounds = true
        self.photoImageView.layer.cornerRadius = 2.0
        self.photoImageView.image = photo
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? ProfileTableViewController {
            // Start upload in background.
            self.previewProfilePicDelegate?.saveProfilePic(self.photo)
        }
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("segueUnwindToProfileTableVc", sender: self)
    }
}
