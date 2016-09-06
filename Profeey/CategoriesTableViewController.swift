//
//  CategoriesTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {
    
    var scrollViewDelegate: ScrollViewDelegate?
    var addCategoryDelegate: AddCategoryDelegate?
    
    private var categories: [Category] = []
    private var customCategoryName: String?
    private var isSearching: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // Custom categoryName cell.
            return customCategoryName != nil ? 1 : 0
        case 1:
            // Searching cell.
            return self.isSearching ? 1 : 0
        default:
            // Category cell.
            return self.isSearching ? 0 : self.categories.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellCategory", forIndexPath: indexPath) as! SearchCategoryTableViewCell
            cell.categoryNameLabel.text = self.customCategoryName
            cell.numberOfUsersPostsLabel.text = nil
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellSearching", forIndexPath: indexPath) as! SearchingTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellCategory", forIndexPath: indexPath) as! SearchCategoryTableViewCell
            let category = self.categories[indexPath.row]
            cell.categoryNameLabel.text = category.categoryName
            cell.numberOfUsersPostsLabel.text = category.numberOfPostsString
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            let newCategory = Category(categoryName: self.customCategoryName, numberOfPosts: 0)
            self.addCategoryDelegate?.addCategory(newCategory)
        } else if indexPath.section == 2 {
            self.addCategoryDelegate?.addCategory(self.categories[indexPath.row])
        }
        // Go back to EditPostVc.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.scrollViewDelegate?.scrollViewWillBeginDragging()
    }
    
}

// This delegate is defined in SearchResultVc.
extension CategoriesTableViewController: SearchCategoriesDelegate {
    
    func toggleSearchCategories(categories: [Category], isSearching: Bool) {
        self.categories = categories
        self.isSearching = isSearching
        self.tableView.reloadData()
    }
}

extension CategoriesTableViewController: CustomCategoryNameDelegate {
    
    func addCustomCategoryname(customCategoryName: String?) {
        self.customCategoryName = customCategoryName
        self.tableView.reloadData()
    }
}
