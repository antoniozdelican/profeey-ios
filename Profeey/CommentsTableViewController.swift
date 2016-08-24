//
//  CommentsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController {
    
    var comments: [Comment]?
    private var commentsArray: [Comment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 56.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentOffset = CGPointMake(0.0, CGFloat.max)
        
        let user1 = User(userId: nil, firstName: "Antonio", lastName: "Zdelican", preferredUsername: "antonio", profession: "Engineer", profilePicUrl: nil, location: nil, about: nil)
        let comment1 = Comment(user: user1, commentText: "Currently discovering iOS and energy management.")
        let comment2 = Comment(user: user1, commentText: "Awesome")
        let comment3 = Comment(user: user1, commentText: "Bla")
        let comment4 = Comment(user: user1, commentText: "Lorem ipsum dolor sit amet, eu mea legendos scribentur, an est paulo soluta aliquid, enim duis ut cum. Nostro meliore phaedrum et has. In mea essent dicunt, solum tation regione id eum, at assum legendos his. Minim nobis vitae nec in, volutpat adipiscing pri in. Nam cu audiam volutpat expetenda, docendi copiosae oportere et quo. Eu impedit periculis qui. Eu cum vitae lobortis necessitatibus, eum dictas docendi epicuri ut. Sale voluptua at eos. Homero audiam legendos sea ei, et usu odio putent tincidunt.")
        let comment5 = Comment(user: user1, commentText: "Lorem ipsum dolor sit amet, eu mea legendos scribentur, an est paulo soluta aliquid, enim duis ut cum. Nostro meliore phaedrum et has. In mea essent dicunt, solum tation regione id eum, at assum legendos his. Minim nobis vitae nec in, volutpat adipiscing pri in. Nam cu audiam volutpat expetenda, docendi copiosae oportere et quo. Eu impedit periculis qui. Eu cum vitae lobortis necessitatibus, eum dictas docendi epicuri ut. Sale voluptua at eos. Homero audiam legendos sea ei, et usu odio putent tincidunt.")
        let comment6 = Comment(user: user1, commentText: "Lorem ipsum dolor sit amet, eu mea legendos scribentur, an est paulo soluta aliquid, enim duis ut cum. Nostro meliore phaedrum et has. In mea essent dicunt, solum tation regione id eum, at assum legendos his. Minim nobis vitae nec in, volutpat adipiscing pri in. Nam cu audiam volutpat expetenda, docendi copiosae oportere et quo. Eu impedit periculis qui. Eu cum vitae lobortis necessitatibus, eum dictas docendi epicuri ut. Sale voluptua at eos. Homero audiam legendos sea ei, et usu odio putent tincidunt.")
        
        self.comments = [comment1, comment2, comment3, comment4, comment5, comment6]
        
        if let comments = self.comments {
            self.commentsArray = comments
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentsArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellComment", forIndexPath: indexPath) as! CommentTableViewCell
        let comment = self.commentsArray[indexPath.row]
        let user = comment.user
        cell.profilePicImageView.image = user?.profilePic
        cell.fullNameLabel.text = user?.fullName
        cell.professionLabel.text = user?.profession
        cell.commentLabel.text = comment.commentText
        cell.timeLabel.text = "2 minutes ago"
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
}

extension CommentsTableViewController: CommentsViewControllerDelegate {
    
    func commentPosted(comment: Comment) {
        self.commentsArray.append(comment)
        let indexPath = NSIndexPath(forRow: self.commentsArray.count - 1, inSection: 0)
        
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        self.tableView.endUpdates()
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
    }
}
