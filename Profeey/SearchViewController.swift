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
    func showUsers(_ users: [User], showRecentUsers: Bool)
    func searchingUsers(_ isSearchingUsers: Bool)
}

protocol SearchCategoriesDelegate {
    func showCategories(_ categories: [Category], showRecentCategories: Bool)
    func searchingCategories(_ isSearchingCategories: Bool)
}

protocol ScrollViewDelegate {
    func didScroll()
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var indicatorScrollView: UIScrollView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var peopleLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var segmentedControlView: UIView!
    
    fileprivate var searchController: UISearchController?
    fileprivate var searchUsersDelegate: SearchUsersDelegate?
    fileprivate var searchCategoriesDelegate: SearchCategoriesDelegate?
    
    fileprivate var recentUsers: [User] = []
    fileprivate var searchedUsers: [User] = []
    fileprivate var showRecentUsers: Bool = true
    
    fileprivate var recentCategories: [Category] = []
    fileprivate var searchedCategories: [Category] = []
    fileprivate var showRecentCategories: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.configureSearchController()
        self.mainScrollView.delegate = self
        self.adjustSegment(0)
        
        self.scanUsers()
        self.scanCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.indicatorScrollView.contentOffset.x = -self.mainScrollView.contentOffset.x / 2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchController?.searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.hidesNavigationBarDuringPresentation = false
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.searchController?.searchBar.delegate = self
        
        self.definesPresentationContext = true
        //self.definesPresentationContext = false
        self.navigationItem.titleView = self.searchController?.searchBar
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? SearchUsersTableViewController {
            self.searchUsersDelegate = destinationViewController
            destinationViewController.scrollViewDelegate = self
            destinationViewController.selectUserDelegate = self
        }
        if let destinationViewController = segue.destination as? SearchCategoriesTableViewController {
            self.searchCategoriesDelegate = destinationViewController
            destinationViewController.scrollViewDelegate = self
            destinationViewController.selectCategoryDelegate = self
        }
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.user = self.showRecentUsers ? self.recentUsers[(indexPath as NSIndexPath).row] : self.searchedUsers[(indexPath as NSIndexPath).row]
        }
        if let destinationViewController = segue.destination as? CategoryTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.categoryName = self.showRecentCategories ? self.recentCategories[(indexPath as NSIndexPath).row].categoryName : self.searchedCategories[(indexPath as NSIndexPath).row].categoryName
        }
        if let destinationViewController = segue.destination as? Category2TableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.category = self.showRecentCategories ? self.recentCategories[(indexPath as NSIndexPath).row] : self.searchedCategories[(indexPath as NSIndexPath).row]
        }
    }
    
    // MARK: IBActions
    
    @IBAction func peopleSegmentTapped(_ sender: AnyObject) {
        let rect = CGRect(x: 0.0, y: 0.0, width: self.mainScrollView.bounds.width, height: self.mainScrollView.bounds.height)
        self.mainScrollView.scrollRectToVisible(rect, animated: true)
    }
    
    @IBAction func categoriesSegmentTapped(_ sender: AnyObject) {
        let rect = CGRect(x: self.view.bounds.width, y: 0.0, width: self.mainScrollView.bounds.width, height: self.mainScrollView.bounds.height)
        self.mainScrollView.scrollRectToVisible(rect, animated: true)
    }
    
    // MARK: Helper
    
    fileprivate func adjustSegment(_ segmentIndex: Int) {
        switch segmentIndex {
        case 0:
            if self.peopleLabel.textColor != Colors.black {
                self.peopleLabel.textColor = Colors.black
                self.categoriesLabel.textColor = Colors.greyDark
            }
        case 1:
            if self.categoriesLabel.textColor != Colors.black {
                self.peopleLabel.textColor = Colors.greyDark
                self.categoriesLabel.textColor = Colors.black
            }
        default:
            return
        }
    }
    
    // MARK: AWS
    
    fileprivate func scanUsers() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanUsersDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
    
    fileprivate func scanUsersByFirstLastName(_ searchText: String) {
        let searchFirstName = searchText.lowercased()
        let searchLastName = searchText.lowercased()
        let searchPreferredUsername = searchText.lowercased()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanUsersByNameDynamoDB(searchFirstName, searchLastName: searchLastName, searchPreferredUsername: searchPreferredUsername, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
    
    fileprivate func scanCategories() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanCategoriesDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    print("scanCategories error: \(error)")
                } else {
                    guard let awsCategories = response?.items as? [AWSCategory] , awsCategories.count > 0 else {
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
    
    fileprivate func scanCategoriesByCategoryName(_ searchText: String) {
        let searchCategoryName = searchText.lowercased()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanCategoriesByCategoryNameDynamoDB(searchCategoryName, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    print("scanCategoriesByCategoryName error: \(error)")
                    self.searchedCategories = []
                    if !self.showRecentCategories {
                        self.searchCategoriesDelegate?.searchingCategories(false)
                        self.searchCategoriesDelegate?.showCategories(self.searchedCategories, showRecentCategories: false)
                    }
                } else {
                    guard let awsCategories = response?.items as? [AWSCategory] , awsCategories.count > 0 else {
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.indicatorScrollView.contentOffset.x = -scrollView.contentOffset.x / 2
        if scrollView.contentOffset.x > scrollView.bounds.width / 2 {
            self.adjustSegment(1)
        } else {
            self.adjustSegment(0)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
    
    func didSelectUser(_ indexPath: IndexPath) {
        self.performSegue(withIdentifier: "segueToProfileVc", sender: indexPath)
    }
}

extension SearchViewController: SelectCategoryDelegate {
    
    func didSelectCategory(_ indexPath: IndexPath) {
        self.performSegue(withIdentifier: "segueToCategoryVc", sender: indexPath)
    }
}
