//
//  CategoryTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class CategoryTableViewController: UITableViewController {

    var category: Category?
    private var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.tableView.estimatedRowHeight = 155.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.title = self.category?.categoryName
        
        // MOCK
        let user1 = User(firstName: "Ivan", lastName: "Zdelican", preferredUsername: "ivan", profession: "Fruit Grower", profilePic: UIImage(named: "pic_ivan"))
        let user2 = User(firstName: "Filip", lastName: "Vargovic", preferredUsername: "filja", profession: "Yacht Skipper", profilePic: UIImage(named: "pic_filip"))
        let user3 = User(firstName: "Josip", lastName: "Zdelican", preferredUsername: "jole", profession: "Agricultural Engineer", profilePic: UIImage(named: "pic_josip"))
        
        // MOCK
        let category1 = Category(categoryName: "Melon Production", numberOfPosts: 12)
        let category2 = Category(categoryName: "Yachting", numberOfPosts: 5)
        let category3 = Category(categoryName: "Agriculture", numberOfPosts: 28)
        let category4 = Category(categoryName: "Tobacco industry", numberOfPosts: 1)
        
        let post1 = Post(user: user1, postDescription: nil, imageUrl: nil, title: "Melon harvest - peak of the season", image: UIImage(named: "post_pic_ivan"), categories: [category1, category3])
        let post2 = Post(user: user2, postDescription: nil, imageUrl: nil, title: "New boat for this summer's tour", image: UIImage(named: "post_pic_filip"), categories: [category2])
        let post3 = Post(user: user3, postDescription: nil, imageUrl: nil, title: "Desired tobacco color of type Berlej before the final stage of drying", image: UIImage(named: "post_pic_josip"), categories: [category3, category4])
        self.posts = [post1, post2, post3]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? PostDetailsTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.post = self.posts[indexPath.row]
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return self.posts.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader", forIndexPath: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPost", forIndexPath: indexPath) as! PostTableViewCell
            let post = self.posts[indexPath.row]
            let user = post.user
            cell.profilePicImageView.image = user?.profilePic
            cell.fullNameLabel.text = user?.fullName
            cell.professionLabel.text = user?.profession
            cell.postPicImageView.image = post.image
            cell.titleLabel.text = post.title
//            cell.categoryLabel.text = post.categories?.flatMap({ $0.categoryName }).joinWithSeparator(" · ")
            cell.categoryLabel.text = post.category
            cell.timeLabel.text = post.creationDateString
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is PostTableViewCell {
            self.performSegueWithIdentifier("segueToPostDetailsVc", sender: indexPath)
        }
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        if indexPath.section == 0 {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
    }
}
