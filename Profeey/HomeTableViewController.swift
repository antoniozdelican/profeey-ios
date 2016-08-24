//
//  HomeTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    //TEST
    private var popularCategories: [Category] = []
    
    private var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.tableView.estimatedRowHeight = 155.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //TEST
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.translucent = true
//        self.navigationController?.navigationBar.barTintColor = UIColor.clearColor()
//        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // MOCK
        let user1 = User(firstName: "Ivan", lastName: "Zdelican", preferredUsername: "ivan", profession: "Fruit Grower", profilePic: UIImage(named: "pic_ivan"))
        let user2 = User(firstName: "Filip", lastName: "Vargovic", preferredUsername: "filja", profession: "Yacht Skipper", profilePic: UIImage(named: "pic_filip"))
        let user3 = User(firstName: "Josip", lastName: "Zdelican", preferredUsername: "jole", profession: "Agricultural Engineer", profilePic: UIImage(named: "pic_josip"))
        
        // MOCK
        let category1 = Category(categoryName: "Melon Production", numberOfUsers: 2, numberOfPosts: 12, featuredImage: UIImage(named: "post_pic_ivan_4"))
        let category2 = Category(categoryName: "Yachting", numberOfUsers: 1, numberOfPosts: 5, featuredImage: UIImage(named: "post_pic_filip"))
        let category3 = Category(categoryName: "Agriculture", numberOfUsers: 3, numberOfPosts: 28, featuredImage: UIImage(named: "post_pic_ivan_2"))
        let category4 = Category(categoryName: "Tobacco industry", numberOfUsers: 1, numberOfPosts: 1, featuredImage: UIImage(named: "post_pic_josip"))
        self.popularCategories = [category1, category2, category3, category4]
        
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
        if let destinationViewController = segue.destinationViewController as? CategoryTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.category = self.popularCategories[indexPath.row]
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
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader", forIndexPath: indexPath) as! HomeHeaderTableViewCell
            cell.headerTitleLabel.text = "Subscribed Skills"
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellCategory", forIndexPath: indexPath) as! MyCategoriesTableViewCell
            // Set dataSource and delegate.
            cell.categoriesCollectionView.dataSource = self
            cell.categoriesCollectionView.delegate = self
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader", forIndexPath: indexPath) as! HomeHeaderTableViewCell
            cell.headerTitleLabel.text = "Following"
            cell.selectionStyle = UITableViewCellSelectionStyle.None
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
            cell.categoriesLabel.text = post.categories?.flatMap({ $0.categoryName }).joinWithSeparator(" · ")
            cell.timeLabel.text = "2 minutes ago"
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
        if indexPath.section == 0 || indexPath.section == 2 {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
    }
}

extension HomeTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.popularCategories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellCategory", forIndexPath: indexPath) as! MyCategoryCollectionViewCell
        let category = self.popularCategories[indexPath.row]
        cell.categoryImageView.image = category.featuredImage
        cell.categoryNameLabel.text = category.categoryName
        if let numberOfPosts = category.numberOfPosts {
            cell.numberOfPostsLabel.text = "\(numberOfPosts.numberToString()) posts"
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("segueToCategoryVc", sender: indexPath)
    }
}
