//
//  SearchCategoriesTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class SearchCategoriesTableViewController: UITableViewController {
    
    var scrollViewDelegate: ScrollViewDelegate?
    private var categories: [Category] = []
    private var showRecentCategories: Bool = true
    private var isSearchingCategories: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchingCategories {
            return 1
        }
        if !self.showRecentCategories && self.categories.count == 0 {
            return 1
        }
        return self.categories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.isSearchingCategories {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellSearching", forIndexPath: indexPath) as! SearchingTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        }
        if !self.showRecentCategories && self.categories.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellNoResults", forIndexPath: indexPath) as! NoResultsTableViewCell
            return cell
        }
        let category = self.categories[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cellSearchCategory", forIndexPath: indexPath) as! SearchCategoryTableViewCell
        cell.categoryNameLabel.text = category.categoryName
        cell.numberOfUsersPostsLabel.text = category.numberOfPostsString
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader") as! HeaderTableViewCell
        cell.headerTitle.text = self.showRecentCategories ? "RECENT" : "BEST MATCHES"
        cell.contentView.backgroundColor = UIColor.whiteColor()
        return cell.contentView
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.scrollViewDelegate?.didScroll()
    }
}

extension SearchCategoriesTableViewController: SearchCategoriesDelegate {
    
    func searchingCategories(isSearchingCategories: Bool) {
        self.isSearchingCategories = isSearchingCategories
        self.tableView.reloadData()
    }
    
    func showCategories(categories: [Category], showRecentCategories: Bool) {
        self.categories = categories
        self.showRecentCategories = showRecentCategories
        self.tableView.reloadData()
    }
}
