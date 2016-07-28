//
//  PostDetailsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 16/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class PostDetailsTableViewController: UITableViewController {

    @IBOutlet weak var postPicImageView: UIImageView!
    @IBOutlet weak var postPicImageViewHeightConstraint: NSLayoutConstraint!
    
    var imageData: NSData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = Colors.grey
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        if let imageData = self.imageData, let image = UIImage(data: imageData) {
            let aspectRatio = image.size.width / image.size.height
            let imageHeight = self.view.bounds.width / aspectRatio
            self.postPicImageViewHeightConstraint.constant = imageHeight
            self.postPicImageView.image = image
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: IBActions
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
