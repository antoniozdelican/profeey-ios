//
//  SearchViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

protocol SearchUsersDelegate {
    func showUsers(users: [User], showRecentUsers: Bool)
    func searchingUsers(isSearchingUsers: Bool)
}

protocol SearchCategoriesDelegate {
    func showCategories(categories: [Category], showRecentCategories: Bool)
    func searchingCategories(isSearchingCategories: Bool)
}

protocol ScrollViewDelegate {
    func didScroll()
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var indicatorScrollView: UIScrollView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var peopleImageView: UIImageView!
    @IBOutlet weak var peopleLabel: UILabel!
    @IBOutlet weak var categoriesImageView: UIImageView!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var segmentedControlView: UIView!
    
    private var searchController: UISearchController?
    private var searchUsersDelegate: SearchUsersDelegate?
    private var searchCategoriesDelegate: SearchCategoriesDelegate?
    
    private var recentUsers: [User] = []
    private var searchedUsers: [User] = []
    private var showRecentUsers: Bool = true
    
    private var recentCategories: [Category] = []
    private var searchedCategories: [Category] = []
    private var showRecentCategories: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.configureSearchController()
        self.mainScrollView.delegate = self
        self.adjustSegment(0)
        
        self.scanUsers()
        self.scanCategories()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.indicatorScrollView.contentOffset.x = -self.mainScrollView.contentOffset.x / 2
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchController?.searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    private func configureSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.hidesNavigationBarDuringPresentation = false
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.searchController?.searchBar.delegate = self
        
        //self.definesPresentationContext = true
        self.definesPresentationContext = false
        self.navigationItem.titleView = self.searchController?.searchBar
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? SearchUsersTableViewController {
            self.searchUsersDelegate = destinationViewController
            destinationViewController.scrollViewDelegate = self
            destinationViewController.selectUserDelegate = self
        }
        if let destinationViewController = segue.destinationViewController as? SearchCategoriesTableViewController {
            self.searchCategoriesDelegate = destinationViewController
            destinationViewController.scrollViewDelegate = self
            destinationViewController.selectCategoryDelegate = self
        }
        if let destinationViewController = segue.destinationViewController as? ProfileTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.user = self.showRecentUsers ? self.recentUsers[indexPath.row] : self.searchedUsers[indexPath.row]
        }
        if let destinationViewController = segue.destinationViewController as? CategoryTableViewController,
            let indexPath = sender as? NSIndexPath {
            destinationViewController.categoryName = self.showRecentCategories ? self.recentCategories[indexPath.row].categoryName : self.searchedCategories[indexPath.row].categoryName
        }
    }
    
    // MARK: IBActions
    
    @IBAction func peopleSegmentTapped(sender: AnyObject) {
        let rect = CGRectMake(0.0, 0.0, self.mainScrollView.bounds.width, self.mainScrollView.bounds.height)
        self.mainScrollView.scrollRectToVisible(rect, animated: true)
    }
    
    @IBAction func categoriesSegmentTapped(sender: AnyObject) {
        let rect = CGRectMake(self.view.bounds.width, 0.0, self.mainScrollView.bounds.width, self.mainScrollView.bounds.height)
        self.mainScrollView.scrollRectToVisible(rect, animated: true)
    }
    
    // MARK: Helper
    
    private func adjustSegment(segmentIndex: Int) {
        switch segmentIndex {
        case 0:
            if self.peopleLabel.textColor != Colors.black {
                self.peopleImageView.image = UIImage(named: "ic_people_black")
                self.peopleLabel.textColor = Colors.black
                self.categoriesImageView.image = UIImage(named: "ic_categories_grey")
                self.categoriesLabel.textColor = Colors.greyDark
            }
        case 1:
            if self.categoriesLabel.textColor != Colors.black {
                self.peopleImageView.image = UIImage(named: "ic_people_grey")
                self.peopleLabel.textColor = Colors.greyDark
                self.categoriesImageView.image = UIImage(named: "ic_categories_black")
                self.categoriesLabel.textColor = Colors.black
            }
        default:
            return
        }
    }
    
    // MARK: AWS
    
    private func scanUsers() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanUsersDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("scanUsers error: \(error)")
                } else {
                    guard let awsUsers = response?.items as? [AWSUser] else {
                        return
                    }
                    guard awsUsers.count > 0 else {
                        return
                    }
                    for awsUser in awsUsers {
                        let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationName: awsUser._locationName)
                        self.recentUsers.append(user)
                    }
                    if self.showRecentUsers {
                        self.searchUsersDelegate?.showUsers(self.recentUsers, showRecentUsers: true)
                    }
                }
            })
        })
    }
    
    private func scanUsersByFirstLastName(searchText: String) {
        let searchFirstName = searchText.lowercaseString
        let searchLastName = searchText.lowercaseString
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanUsersByFirstLastNameDynamoDB(searchFirstName, searchLastName: searchLastName, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("scanUsers error: \(error)")
                    self.searchedUsers = []
                    if !self.showRecentUsers {
                        self.searchUsersDelegate?.searchingUsers(false)
                        self.searchUsersDelegate?.showUsers(self.searchedUsers, showRecentUsers: false)
                    }
                } else {
                    guard let awsUsers = response?.items as? [AWSUser] else {
                        self.searchedUsers = []
                        if !self.showRecentUsers {
                            self.searchUsersDelegate?.searchingUsers(false)
                            self.searchUsersDelegate?.showUsers(self.searchedUsers, showRecentUsers: false)
                        }
                        return
                    }
                    guard awsUsers.count > 0 else {
                        self.searchedUsers = []
                        if !self.showRecentUsers {
                            self.searchUsersDelegate?.searchingUsers(false)
                            self.searchUsersDelegate?.showUsers(self.searchedUsers, showRecentUsers: false)
                        }
                        return
                    }
                    // Clear searched
                    self.searchedUsers = []
                    for awsUser in awsUsers {
                        let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationName: awsUser._locationName)
                        self.searchedUsers.append(user)
                    }
                    if !self.showRecentUsers {
                        self.searchUsersDelegate?.searchingUsers(false)
                        self.searchUsersDelegate?.showUsers(self.searchedUsers, showRecentUsers: false)
                    }
                }
            })
        })
    }
    
    private func scanCategories() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanCategoriesDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("scanCategories error: \(error)")
                } else {
                    guard let awsCategories = response?.items as? [AWSCategory] where awsCategories.count > 0 else {
                        return
                    }
                    for awsCategory in awsCategories {
                        let category = Category(categoryName: awsCategory._categoryName, numberOfPosts: awsCategory._numberOfPosts)
                        self.recentCategories.append(category)
                    }
                    if self.showRecentCategories {
                        self.searchCategoriesDelegate?.showCategories(self.recentCategories, showRecentCategories: true)
                    }
                }
            })
        })
    }
    
    private func scanCategoriesByCategoryName(searchText: String) {
        let searchCategoryName = searchText.lowercaseString
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanCategoriesByCategoryNameDynamoDB(searchCategoryName, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("scanCategoriesByCategoryName error: \(error)")
                    self.searchedCategories = []
                    if !self.showRecentCategories {
                        self.searchCategoriesDelegate?.searchingCategories(false)
                        self.searchCategoriesDelegate?.showCategories(self.searchedCategories, showRecentCategories: false)
                    }
                } else {
                    guard let awsCategories = response?.items as? [AWSCategory] where awsCategories.count > 0 else {
                        self.searchedCategories = []
                        if !self.showRecentCategories {
                            self.searchCategoriesDelegate?.searchingCategories(false)
                            self.searchCategoriesDelegate?.showCategories(self.searchedCategories, showRecentCategories: false)
                        }
                        return
                    }
                    // Clear searched
                    self.searchedCategories = []
                    for awsCategory in awsCategories {
                        let category = Category(categoryName: awsCategory._categoryName, numberOfPosts: awsCategory._numberOfPosts)
                        self.searchedCategories.append(category)
                    }
                    if !self.showRecentCategories {
                        self.searchCategoriesDelegate?.searchingCategories(false)
                        self.searchCategoriesDelegate?.showCategories(self.searchedCategories, showRecentCategories: false)
                    }
                }
            })
        })
    }
}

extension SearchViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.indicatorScrollView.contentOffset.x = -scrollView.contentOffset.x / 2
        if scrollView.contentOffset.x > scrollView.bounds.width / 2 {
            self.adjustSegment(1)
        } else {
            self.adjustSegment(0)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.trimm()
        if searchText.isEmpty {
            // Users.
            self.showRecentUsers = true
            self.searchUsersDelegate?.searchingUsers(false)
            self.searchUsersDelegate?.showUsers(self.recentUsers, showRecentUsers: self.showRecentUsers)
            
            // Categories.
            self.showRecentCategories = true
            self.searchCategoriesDelegate?.searchingCategories(false)
            self.searchCategoriesDelegate?.showCategories(self.recentCategories, showRecentCategories: self.showRecentCategories)
            
        } else {
            // Users.
            self.showRecentUsers = false
            self.searchUsersDelegate?.searchingUsers(true)
            self.scanUsersByFirstLastName(searchText)
            
            // Categories.
            self.showRecentCategories = false
            self.searchCategoriesDelegate?.searchingCategories(true)
            self.scanCategoriesByCategoryName(searchText)
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        // Users.
        self.showRecentUsers = true
        self.searchUsersDelegate?.searchingUsers(false)
        self.searchUsersDelegate?.showUsers(self.recentUsers, showRecentUsers: self.showRecentUsers)
        
        // Categories.
        self.showRecentCategories = true
        self.searchCategoriesDelegate?.searchingCategories(false)
        self.searchCategoriesDelegate?.showCategories(self.recentCategories, showRecentCategories: self.showRecentCategories)
    }
}

extension SearchViewController: ScrollViewDelegate {
    
    func didScroll() {
        self.searchController?.searchBar.resignFirstResponder()
    }
}

extension SearchViewController: SelectUserDelegate {
    
    func didSelectUser(indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("segueToProfileVc", sender: indexPath)
    }
}

extension SearchViewController: SelectCategoryDelegate {
    
    func didSelectCategory(indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("segueToCategoryVc", sender: indexPath)
    }
}
