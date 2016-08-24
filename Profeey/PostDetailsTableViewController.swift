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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var mainTableViewCell: UITableViewCell!
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var userTableViewCell: UITableViewCell!
    
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var numberOfLikesButton: UIButton!
    @IBOutlet weak var numberOfCommentsButton: UIButton!
    
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
        self.categoriesLabel.text = self.post?.categories?.flatMap({ $0.categoryName }).joinWithSeparator(" · ")
        // User.
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        self.profilePicImageView.image = self.post?.user?.profilePic
        self.fullNameLabel.text = self.post?.user?.fullName
        self.professionLabel.text = self.post?.user?.profession
        // Likes and comments.
        if let numberOfLikes = self.post?.numberOfLikes.numberToString() {
            self.numberOfLikesButton.setTitle("\(numberOfLikes) likes", forState: UIControlState.Normal)
        }
        if let numberOfComments = self.post?.numberOfComments.numberToString() {
            self.numberOfCommentsButton.setTitle("\(numberOfComments) comments", forState: UIControlState.Normal)
        }
        // Other.
        self.timeLabel.text = "Posted 2 minutes ago"
        self.descriptionLabel.text = "Lorem ipsum dolor sit amet, eu mea legendos scribentur, an est paulo soluta aliquid, enim duis ut cum. Nostro meliore phaedrum et has. In mea essent dicunt, solum tation regione id eum, at assum legendos his. Minim nobis vitae nec in, volutpat adipiscing pri in. Nam cu audiam volutpat expetenda, docendi copiosae oportere et quo. Eu impedit periculis qui. Eu cum vitae lobortis necessitatibus, eum dictas docendi epicuri ut. Sale voluptua at eos. Homero audiam legendos sea ei, et usu odio putent tincidunt. \n Adipisci intellegat nec ea, sed animal euismod pericula no. Pro summo postea ad, probo mediocritatem sit no. An est putant iisque, ea usu etiam perfecto conceptam. Aliquip referrentur eum et. \n Id iisque latine usu, sea ei solum facer scriptorem, illud vivendum no duo. Nec melius integre mnesarchum ut, quo at mutat accusamus similique, cum et tale putant quodsi. Pro probo definitiones ex, at cum modus novum diceret. Dicunt sententiae cotidieque nam in, graeco molestie mei ea. Eam omnes deserunt quaestio an, ipsum adipisci erroribus mel et, pri ex dicant facilisi euripidis. At lucilius oportere deseruisse nec, sed magna explicari id, nonumes maiestatis repudiandae pri at. \n Id iisque latine usu, sea ei solum facer scriptorem, illud vivendum no duo. Nec melius integre mnesarchum ut, quo at mutat accusamus similique, cum et tale putant quodsi. Pro probo definitiones ex, at cum modus novum diceret. Dicunt sententiae cotidieque nam in, graeco molestie mei ea. Eam omnes deserunt quaestio an, ipsum adipisci erroribus mel et, pri ex dicant facilisi euripidis. At lucilius oportere deseruisse nec, sed magna explicari id, nonumes maiestatis repudiandae pri at."
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
