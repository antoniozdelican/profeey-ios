//
//  PreviewViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var photo: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.backButton.image = UIImage(named: "btn_back")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.photoImageView.image = photo
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: IBActions
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
}
