//
//  TestViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 28/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = self.image {
            self.imageViewWidthConstraint.constant = 355.0
            self.imageViewHeightConstraint.constant = 355.0
            self.imageView.image = image
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
