//
//  SearchCategoriesTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol SelectCategoryDelegate {
    func didSelectCategory(_ indexPath: IndexPath)
}

class SearchCategoriesTableViewController: UITableViewController {
    
    var scrollViewDelegate: ScrollViewDelegate?
    var selectCategoryDelegate: SelectCategoryDelegate?
    fileprivate var categories: [Category] = []
    fileprivate var showRecentCategories: Bool = true
    fileprivate var isSearchingCategories: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchingCategories {
            return 1
        }
        if !self.showRecentCategories && self.categories.count == 0 {
            return 1
        }
        return self.categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isSearchingCategories {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        }
        if !self.showRecentCategories && self.categories.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
            return cell
        }
        let category = self.categories[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearchCategory", for: indexPath) as! SearchCategoryTableViewCell
        cell.categoryNameLabel.text = category.categoryName
        cell.numberOfUsersPostsLabel.text = category.numberOfPostsString
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! HeaderTableViewCell
        cell.headerTitle.text = self.showRecentCategories ? "RECENT" : "BEST MATCHES"
        cell.contentView.backgroundColor = UIColor.white
        return cell.contentView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectCategoryDelegate?.didSelectCategory(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollViewDelegate?.didScroll()
    }
}

extension SearchCategoriesTableViewController: SearchCategoriesDelegate {
    
    func searchingCategories(_ isSearchingCategories: Bool) {
        self.isSearchingCategories = isSearchingCategories
        self.tableView.reloadData()
    }
    
    func showCategories(_ categories: [Category], showRecentCategories: Bool) {
        self.categories = categories
        self.showRecentCategories = showRecentCategories
        self.tableView.reloadData()
    }
}
