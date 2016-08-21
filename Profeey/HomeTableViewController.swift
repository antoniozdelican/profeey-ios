//
//  HomeTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    private var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 155.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //TEST
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.translucent = true
//        self.navigationController?.navigationBar.barTintColor = UIColor.clearColor()
//        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        // MOCK
        let user1 = User(firstName: "Ivan", lastName: "Zdelican", preferredUsername: "ivan", professions: ["Fruit Grower"], profilePicData: UIImageJPEGRepresentation(UIImage(named: "pic_ivan")!, 0.6))
        let user2 = User(firstName: "Filip", lastName: "Vargovic", preferredUsername: "filja", professions: ["Yacht Skipper", "Fitness Trainer"], profilePicData: UIImageJPEGRepresentation(UIImage(named: "pic_filip")!, 0.6))
        let user3 = User(firstName: "Josip", lastName: "Zdelican", preferredUsername: "jole", professions: ["Agricultural Engineer"], profilePicData: UIImageJPEGRepresentation(UIImage(named: "pic_josip")!, 0.6))
        
        // MOCK
        let category1 = Category(categoryName: "Melon Production", numberOfUsers: 2, numberOfPosts: 12)
        let category2 = Category(categoryName: "Yachting", numberOfUsers: 1, numberOfPosts: 5)
        let category3 = Category(categoryName: "Agriculture", numberOfUsers: 3, numberOfPosts: 28)
        let category4 = Category(categoryName: "Tobacco industry", numberOfUsers: 1, numberOfPosts: 1)
        
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
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        default:
            return self.posts.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHomeHeader", forIndexPath: indexPath) as! HomeHeaderTableViewCell
            cell.headerTitleLabel.text = "Popular Skills"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellCategory", forIndexPath: indexPath) as! MyCategoriesTableViewCell
            cell.categoriesCollectionView.dataSource = self
            cell.categoriesCollectionView.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHomeHeader", forIndexPath: indexPath) as! HomeHeaderTableViewCell
            cell.headerTitleLabel.text = "Following"
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPost2", forIndexPath: indexPath) as! PostTableViewCell
            let post = self.posts[indexPath.row]
            let user = post.user
            cell.profilePicImageView.image = user?.profilePic
            cell.fullNameLabel.text = user?.fullName
            cell.professionsLabel.text = user?.professions?.joinWithSeparator(" · ")
            cell.postPicImageView.image = post.image
            cell.titleLabel.text = post.title
            cell.categoriesLabel.text = post.categories?.flatMap({ $0.categoryName }).joinWithSeparator(" · ")
            cell.timeLabel.text = "2 minutes ago"
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("segueToPostDetailsVc", sender: indexPath)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        case 1:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        case 2:
            cell.layoutMargins = UIEdgeInsetsZero
        default:
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
}

//TEST

extension HomeTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellCategory", forIndexPath: indexPath) as! MyCategoryCollectionViewCell
        cell.categoryImageView.image = posts[indexPath.row].image
        return cell
    }
}
