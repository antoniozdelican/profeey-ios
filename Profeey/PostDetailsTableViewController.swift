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
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var mainTableViewCell: UITableViewCell!
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var userTableViewCell: UITableViewCell!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var post: Post?
    private var newImageViewHeight: CGFloat?
    
    private var comments: [Comment]?
    
    // TEST
    var isLiked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.automaticallyAdjustsScrollViewInsets = false
        self.mainTableViewCell.selectionStyle = UITableViewCellSelectionStyle.None
        self.configurePost()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    private func configurePost() {
        // PostPic.
        if let image = self.post?.image {
            let aspectRatio = image.size.width / image.size.height
            let imageHeight = self.view.bounds.width / aspectRatio
            self.postPicImageViewHeightConstraint.constant = imageHeight
            self.postPicImageView.image = image
            self.newImageViewHeight = imageHeight
        }
        // Title and categories.
        self.titleLabel.text = self.post?.title
        self.categoryLabel.text = self.post?.category
        // User.
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        self.profilePicImageView.image = self.post?.user?.profilePic
        self.fullNameLabel.text = self.post?.user?.fullName
        self.professionLabel.text = self.post?.user?.profession
        // Likes and comments.
//        if let numberOfLikes = self.post?.numberOfLikes.numberToString() {
//            self.numberOfLikesButton.setTitle("\(numberOfLikes) likes", forState: UIControlState.Normal)
//        }
//        if let numberOfComments = self.post?.numberOfComments.numberToString() {
//            self.numberOfCommentsButton.setTitle("\(numberOfComments) comments", forState: UIControlState.Normal)
//        }
        // Other.
        self.descriptionLabel.text = self.post?.postDescription
        self.timeLabel.text = self.post?.creationDateString
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //TEST
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.clearColor()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //TEST
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.backgroundColor = Colors.greyLight
        self.navigationController?.navigationBar.barTintColor = Colors.greyLight
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = Colors.blue
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? UsersTableViewController {
            destinationViewController.isLikers = true
        }
        if let destinationViewController = segue.destinationViewController as? CommentsViewController {
            // If button was tapped.
            if segue.identifier == "segueButtonToCommentsVc" {
                destinationViewController.isCommentButton = true
            } else {
                destinationViewController.isCommentButton = false
            }
            destinationViewController.hidesBottomBarWhenPushed = true
        }
        if let destinationViewController = segue.destinationViewController as? ProfileTableViewController {
            destinationViewController.user = self.post?.user
            destinationViewController.isCurrentUser = false
        }
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
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell == self.userTableViewCell {
            self.performSegueWithIdentifier("segueToProfileVc", sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        if cell == self.userTableViewCell {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
    }
    
    // MARK: IBActions
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        if self.isLiked {
            self.likeButton.setImage(UIImage(named: "ic_like_black_big"), forState: UIControlState.Normal)
            self.isLiked = false
        } else {
            self.likeButton.setImage(UIImage(named: "ic_like_blue_big"), forState: UIControlState.Normal)
            self.isLiked = true
        }
    }
    
    @IBAction func numberOfLikesButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("segueToUsersVc", sender: self)
    }
    
    
    @IBAction func commentButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("segueButtonToCommentsVc", sender: self)
    }
    
    @IBAction func numberOfCommentsButton(sender: AnyObject) {
        self.performSegueWithIdentifier("segueToCommentsVc", sender: self)
    }
    
    
}
