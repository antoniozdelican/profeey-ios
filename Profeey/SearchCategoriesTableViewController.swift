//
//  SearchCategoriesTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol SelectCategoryDelegate {
    func categorySelected(index: Int)
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
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // Searching cell.
            return self.isSearching ? 1 : 0
        case 1:
            // No results cell.
            return self.isSearching ? 0 : (self.categories.count > 0 ? 0 : 1)
        default:
            // Category cell.
            return self.isSearching ? 0 : self.categories.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellSearching", forIndexPath: indexPath) as! SearchingTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellNoResults", forIndexPath: indexPath) as! NoResultsTableViewCell
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
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is SearchCategoryTableViewCell {
            self.selectCategoryDelegate?.categorySelected(indexPath.row)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
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
