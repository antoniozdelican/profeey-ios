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
        self.automaticallyAdjustsScrollViewInsets = false
        self.configureSearchController()
        
        // Get featured categories.
        //self.scanFeaturedCategories()
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
            let indexPath = sender as? NSIndexPath {
            destinationViewController.user = self.searchedUsers[indexPath.row]
        }
        if let destinationViewController = segue.destinationViewController as? CategoryTableViewController,
            let indexPath = sender as? NSIndexPath,
            let searchController = self.searchController {
            if searchController.active {
                // Searched category.
                destinationViewController.categoryName = self.searchedCategories[indexPath.row].categoryName
            } else {
                // Featured category.
                destinationViewController.categoryName = self.featuredCategories[indexPath.row].categoryName
            }
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.featuredCategories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellPopularCategory", forIndexPath: indexPath) as! PopularCategoryTableViewCell
        cell.categoryNameLabel.text = self.featuredCategories[indexPath.row].categoryName
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader") as! HeaderTableViewCell
        cell.headerTitle.text = "POPULAR SKILLS"
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is PopularCategoryTableViewCell {
            self.performSegueWithIdentifier("segueToCategoryVc", sender: indexPath.row)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
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
                    guard let awsUsers = response?.items as? [AWSUser] else {
                       self.searchDelegate?.toggleSearchUsers([], isSearching: false)
                        return
                    }
                    // Clear for fresh search.
                    self.searchedUsers = []
                    for(index, awsUser) in awsUsers.enumerate() {
                        let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl)
                        self.searchedUsers.append(user)
                        
                        if let profilePicUrl = awsUser._profilePicUrl {
                            let indexPath = NSIndexPath(forRow: index, inSection: 0)
                            self.downloadImage(profilePicUrl, imageType: .UserProfilePic, indexPath: indexPath)
                        }
                    }
                    self.searchDelegate?.toggleSearchUsers(self.searchedUsers, isSearching: false)
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
                    guard let awsCategories = response?.items as? [AWSCategory] else {
                        self.searchDelegate?.toggleSearchCategories([], isSearching: false)
                        return
                    }
                    // Clear for fresh search.
                    self.searchedCategories = []
                    for awsCategory in awsCategories {
                        let category = Category(categoryName: awsCategory._categoryName, numberOfPosts: awsCategory._numberOfPosts)
                        self.searchedCategories.append(category)
                    }
                    self.searchDelegate?.toggleSearchCategories(self.searchedCategories, isSearching: false)
                }
            })
        })
    }
    
    private func downloadImage(imageKey: String, imageType: ImageType, indexPath: NSIndexPath?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let content = AWSUserFileManager.custom(key: "USEast1BucketManager").contentWithKey(imageKey)
        // TODO check if content.isImage()
        if content.cached {
            print("Content cached:")
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
            let image = UIImage(data: content.cachedData)
            switch imageType {
            case .UserProfilePic:
                if let indexPath = indexPath {
                    self.searchedUsers[indexPath.row].profilePic = image
                    self.searchDelegate?.toggleSearchUsers(self.searchedUsers, isSearching: false)
                }
            default:
                self.searchDelegate?.toggleSearchCategories([], isSearching: false)
                return
            }
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
                            guard let imageData = data else {
                                return
                            }
                            let image = UIImage(data: imageData)
                            switch imageType {
                            case .UserProfilePic:
                                if let indexPath = indexPath {
                                    self.searchedUsers[indexPath.row].profilePic = image
                                    self.searchDelegate?.toggleSearchUsers(self.searchedUsers, isSearching: false)
                                }
                            default:
                                self.searchDelegate?.toggleSearchCategories([], isSearching: false)
                                return
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
    
    func userSelected(indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("segueToProfileVc", sender: indexPath)
    }
}

extension SearchTableViewController: SelectCategoryDelegate {
    
    func categorySelected(indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("segueToCategoryVc", sender: indexPath)
    }
}
