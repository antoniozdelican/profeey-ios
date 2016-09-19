//
//  SearchCategoriesTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol SelectCategoryDelegate {
    func categorySelected(indexPath: NSIndexPath)
}

class SearchCategoriesTableViewController: UITableViewController {
    
    var scrollViewDelegate: ScrollViewDelegate?
    var selectCategoryDelegate: SelectCategoryDelegate?
    
    private var categories: [Category] = []
    private var isSearching: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 65.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.isSearching {
            return 1
        }
        if !self.isSearching && self.categories.count == 0 {
            return 1
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearching {
            return 1
        }
        if !self.isSearching && self.categories.count == 0 {
            return 1
        }
        return self.categories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.isSearching {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellSearching", forIndexPath: indexPath) as! SearchingTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        }
        if !self.isSearching && self.categories.count == 0 {
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is SearchCategoryTableViewCell {
            self.selectCategoryDelegate?.categorySelected(indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 12.0, 0.0, 12.0)
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.scrollViewDelegate?.scrollViewWillBeginDragging()
    }
}

extension SearchCategoriesTableViewController: SearchCategoriesDelegate {
    
    func toggleSearchCategories(categories: [Category], isSearching: Bool) {
        self.categories = categories
        self.isSearching = isSearching
        self.tableView.reloadData()
    }
}
