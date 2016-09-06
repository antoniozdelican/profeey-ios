//
//  SearchTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

protocol ScrollViewDelegate {
    func scrollViewWillBeginDragging()
}

protocol SearchDelegate {
    func toggleSearchCategories(categories: [Category], isSearching: Bool)
    func toggleSearchUsers(users: [User], isSearching: Bool)
}

class SearchTableViewController: UITableViewController {
    
    private var searchController: UISearchController?
    private var searchResultsController: SearchResultsViewController?
    private var searchDelegate: SearchDelegate?
    
    private var featuredCategories: [FeaturedCategory] = []
    private var searchedUsers: [User] = []
    private var searchedCategories: [Category] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.tableView.estimatedRowHeight = 85.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.automaticallyAdjustsScrollViewInsets = false
        self.configureSearchController()
        
        // Get featured categories.
        self.scanFeaturedCategories()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Mark: Configuration
    
    private func configureSearchController() {
        self.searchResultsController = self.storyboard?.instantiateViewControllerWithIdentifier("searchResultsViewController") as? SearchResultsViewController
        
        // Set delegate to dismiss keyboard on drag.
        self.searchResultsController?.scrollViewDelegate = self
        
        // Set search delegate.
        self.searchDelegate = self.searchResultsController
        
        // Set select user delegate.
        self.searchResultsController?.selectUserDelegate = self
        
        // Set select category delegate.
        self.searchResultsController?.selectCategoryDelegate = self
        
        self.searchController = UISearchController(searchResultsController: self.searchResultsController)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.hidesNavigationBarDuringPresentation = false
        self.searchController?.dimsBackgroundDuringPresentation = false
        // Set searchBar delegate.
        self.searchController?.searchBar.delegate = self
        
        self.definesPresentationContext = true
        self.navigationItem.titleView = self.searchController?.searchBar
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? ProfileTableViewController,
            let index = sender as? Int {
            destinationViewController.user = self.searchedUsers[index]
        }
//        if let destinationViewController = segue.destinationViewController as? CategoryTableViewController,
//            let indexPath = sender as? NSIndexPath,
//            let searchController = self.searchController,
//            let text = searchController.searchBar.text {
//            if searchController.active {
//                // Searched or all categories.
////                destinationViewController.category = text.trimm().isEmpty ? self.allCategories[indexPath.row] : self.searchedCategories[indexPath.row]
//            } else {
//                // Popular categories.
//                //destinationViewController.category = self.popularCategories[indexPath.row]
//            }
//        }
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
            return self.featuredCategories.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader", forIndexPath: indexPath) as! HomeHeaderTableViewCell
            cell.headerTitleLabel.text = "Popular Skills"
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellPopularCategory", forIndexPath: indexPath) as! PopularCategoryTableViewCell
            cell.categoryNameLabel.text = self.featuredCategories[indexPath.row].categoryName
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // Popular category selected.
        self.performSegueWithIdentifier("segueToCategoryVc", sender: indexPath)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        default:
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    // MARK: AWS
    
    private func scanUsersByFirsLastName(searchText: String) {
        let searchFirstName = searchText.lowercaseString
        let searchLastName = searchText.lowercaseString
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.searchDelegate?.toggleSearchUsers([], isSearching: true)
        PRFYDynamoDBManager.defaultDynamoDBManager().scanUsersByFirstLastNameDynamoDB(searchFirstName, searchLastName: searchLastName, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("scanUsersByFirsLastName error: \(error)")
                    self.searchDelegate?.toggleSearchUsers([], isSearching: false)
                } else {
                    if let awsUsers = response?.items as? [AWSUser] {
                        
                        // Clear for fresh search.
                        self.searchedUsers = []
                        for(index, awsUser) in awsUsers.enumerate() {
                            let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, profession: awsUser._profession, profilePicUrl: awsUser._profilePicUrl, location: awsUser._location, about: awsUser._about)
                            self.searchedUsers.append(user)
                            
                            // Get profilePic.
                            if let profilePicUrl = awsUser._profilePicUrl {
                                self.downloadImage(profilePicUrl, index: index)
                            }
                        }
                        self.searchDelegate?.toggleSearchUsers(self.searchedUsers, isSearching: false)
                    }
                }
            })
        })
    }
    
    private func scanCategoriesByCategoryName(searchText: String) {
        let searchCategoryName = searchText.lowercaseString
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.searchDelegate?.toggleSearchCategories([], isSearching: true)
        PRFYDynamoDBManager.defaultDynamoDBManager().scanCategoriesByCategoryNameDynamoDB(searchCategoryName, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("scanCategoriesByCategoryName error: \(error)")
                    self.searchDelegate?.toggleSearchCategories([], isSearching: false)
                } else {
                    if let awsCategories = response?.items as? [AWSCategory] {
                        
                        // Clear for fresh search.
                        self.searchedCategories = []
                        for awsCategory in awsCategories {
                            let category = Category(categoryName: awsCategory._categoryName, numberOfPosts: awsCategory._numberOfPosts)
                            self.searchedCategories.append(category)
                        }
                        self.searchDelegate?.toggleSearchCategories(self.searchedCategories, isSearching: false)
                    }
                }
            })
        })
    }
    
    private func scanFeaturedCategories() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanFeaturedCategoriesDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("scanFeaturedCategories error: \(error)")
                } else {
                    if let awsFeaturedCategories = response?.items as? [AWSFeaturedCategory] {
                        
                        for awsFeaturedCategory in awsFeaturedCategories {
                            let featuredCategory = FeaturedCategory(categoryName: awsFeaturedCategory._categoryName, featuredImageUrl: awsFeaturedCategory._featuredImageUrl, numberOfPosts: awsFeaturedCategory._numberOfPosts)
                            self.featuredCategories.append(featuredCategory)
                            self.tableView.reloadData()
                        }
                    }
                }
            })
        })
    }
    
    private func downloadImage(imageKey: String, index: Int) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let content = AWSUserFileManager.custom(key: "USEast1BucketManager").contentWithKey(imageKey)
        // TODO check if content.isImage()
        if content.cached {
            print("Content cached:")
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
            let image = UIImage(data: content.cachedData)
            self.searchedUsers[index].profilePic = image
            self.searchDelegate?.toggleSearchUsers(self.searchedUsers, isSearching: false)
        } else {
            print("Download content:")
            content.downloadWithDownloadType(
                AWSContentDownloadType.IfNewerExists,
                pinOnCompletion: false,
                progressBlock: {
                    (content: AWSContent?, progress: NSProgress?) -> Void in
                    // TODO
                },
                completionHandler: {
                    (content: AWSContent?, data: NSData?, error: NSError?) in
                    dispatch_async(dispatch_get_main_queue(), {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        if let error = error {
                            print("downloadImage error: \(error)")
                        } else {
                            if let imageData = data {
                                let image = UIImage(data: imageData)
                                self.searchedUsers[index].profilePic = image
                                self.searchDelegate?.toggleSearchUsers(self.searchedUsers, isSearching: false)
                            }
                        }
                    })
            })
        }
    }
}

extension SearchTableViewController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchResultsController = searchController.searchResultsController as? SearchResultsViewController,
            let text = searchController.searchBar.text else {
            return
        }
        let searchText = text.trimm()
        // Show searchResultsController view even if the text is empty
        if searchText.isEmpty && searchResultsController.view.hidden {
            searchController.searchResultsController?.view.hidden = false
        }
        // If search text is empty show NO users.
        if searchText.isEmpty {
            self.searchDelegate?.toggleSearchUsers([], isSearching: false)
            self.searchDelegate?.toggleSearchCategories([], isSearching: false)
        }
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.trimm()
        // If search text is not empty, do the search.
        if !searchText.isEmpty {
            self.scanUsersByFirsLastName(searchText)
            self.scanCategoriesByCategoryName(searchText)
        }
    }
}

extension SearchTableViewController: ScrollViewDelegate {
    
    func scrollViewWillBeginDragging() {
        self.searchController?.searchBar.resignFirstResponder()
    }
}

extension SearchTableViewController: SelectUserDelegate {
    
    func userSelected(index: Int) {
        self.performSegueWithIdentifier("segueToProfileVc", sender: index)
    }
}

extension SearchTableViewController: SelectCategoryDelegate {
    
    func categorySelected(index: Int) {
        let indexPath = NSIndexPath(forRow: index, inSection: 1)
        self.performSegueWithIdentifier("segueToCategoryVc", sender: indexPath)
    }
}
