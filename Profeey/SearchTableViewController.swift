//
//  SearchTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol ScrollViewDelegate {
    func scrollViewWillBeginDragging()
}

protocol SearchDelegate {
    func showUsers(users: [User])
    func showCategories(categories: [Category])
    func toggleSearchingIndicator(show: Bool)
}

class SearchTableViewController: UITableViewController {
    
    var searchController: UISearchController?
    var searchResultsController: SearchResultsViewController?
    var searchDelegate: SearchDelegate?
    
    private var allUsers: [User] = []
    private var searchedUsers: [User] = []
    private var allCategories: [Category] = []
    private var searchedCategories: [Category] = []
    private var popularCategories: [Category] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.tableView.estimatedRowHeight = 85.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.automaticallyAdjustsScrollViewInsets = false
        self.configureSearchController()
        
        // MOCK
        let user1 = User(firstName: "Ivan", lastName: "Zdelican", preferredUsername: "ivan", profession: "Fruit Grower", profilePic: UIImage(named: "pic_ivan"))
        let user2 = User(firstName: "Filip", lastName: "Vargovic", preferredUsername: "filja", profession: "Yacht Skipper", profilePic: UIImage(named: "pic_filip"))
        let user3 = User(firstName: "Josip", lastName: "Zdelican", preferredUsername: "jole", profession: "Agricultural Engineer", profilePic: UIImage(named: "pic_josip"))
        self.allUsers = [user1, user2, user3]
        
        // MOCK
        let category1 = Category(categoryName: "Engineering", numberOfUsers: 2, numberOfPosts: 12)
        let category2 = Category(categoryName: "Dental Medicine", numberOfUsers: 1, numberOfPosts: 5)
        let category3 = Category(categoryName: "Agriculture", numberOfUsers: 3, numberOfPosts: 28)
        let category4 = Category(categoryName: "Fruit growing", numberOfUsers: 1, numberOfPosts: 1)
        self.allCategories = [category1, category2, category3, category4]
        
        // MOCK
        self.popularCategories = [category1, category2, category3, category4]
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
            let indexPath = sender as? NSIndexPath,
            let text = self.searchController?.searchBar.text {
            // Searched or all users.
            destinationViewController.user = text.trimm().isEmpty ? self.allUsers[indexPath.row] : self.searchedUsers[indexPath.row]
            destinationViewController.isCurrentUser = false
        }
        if let destinationViewController = segue.destinationViewController as? CategoryTableViewController,
            let indexPath = sender as? NSIndexPath,
            let searchController = self.searchController,
            let text = searchController.searchBar.text {
            if searchController.active {
                // Searched or all categories.
                destinationViewController.category = text.trimm().isEmpty ? self.allCategories[indexPath.row] : self.searchedCategories[indexPath.row]
            } else {
                // Popular categories.
                destinationViewController.category = self.popularCategories[indexPath.row]
            }
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
            return self.popularCategories.count
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
            let category = self.popularCategories[indexPath.row]
            cell.categoryNameLabel.text = category.categoryName
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
    
    // MARK: Helper
    
    private func filterContentForSearchText(searchText: String) {
        // Simulate delay
        self.searchDelegate?.toggleSearchingIndicator(true)
        let delayInSeconds: Double = 1.0
        let popTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue(), {
            () -> Void in
            self.searchDelegate?.toggleSearchingIndicator(false)
            
            // Search users.
            self.searchedUsers = self.allUsers.filter({
                (user: User) -> Bool in
                let firstNameMatch = user.firstName?.lowercaseString.hasPrefix(searchText.lowercaseString)
                let lastNameMatch = user.lastName?.lowercaseString.hasPrefix(searchText.lowercaseString)
                let fullNameMatch = user.fullName?.lowercaseString.hasPrefix(searchText.lowercaseString)
                return (firstNameMatch != nil && firstNameMatch!) || (lastNameMatch != nil && lastNameMatch!) || (fullNameMatch != nil && fullNameMatch!)
            })
            self.searchDelegate?.showUsers(self.searchedUsers)
            
            // Search categories.
            self.searchedCategories = self.allCategories.filter({
                (category: Category) -> Bool in
                let categoryNameMatch = category.categoryName?.lowercaseString.hasPrefix(searchText.lowercaseString)
                return (categoryNameMatch != nil && categoryNameMatch!)
            })
            self.searchDelegate?.showCategories(self.searchedCategories)
            
        })
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
        // If search text is empty show all users.
        if searchText.isEmpty {
            self.searchDelegate?.showUsers(self.allUsers)
            self.searchDelegate?.showCategories(self.allCategories)
        }
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.trimm()
        // If search text is not empty, do the search.
        if !searchText.isEmpty {
            self.filterContentForSearchText(searchText)
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
        let indexPath = NSIndexPath(forRow: index, inSection: 1)
        self.performSegueWithIdentifier("segueToProfileVc", sender: indexPath)
    }
}

extension SearchTableViewController: SelectCategoryDelegate {
    
    func categorySelected(index: Int) {
        let indexPath = NSIndexPath(forRow: index, inSection: 1)
        self.performSegueWithIdentifier("segueToCategoryVc", sender: indexPath)
    }
}
