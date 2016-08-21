//
//  CategoriesTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 02/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol CategoriesTableViewControllerDelegate {
    func scrollViewWillBeginDragging()
    func didSelectRowAtIndexPath(category: String)
}

class CategoriesTableViewController: UITableViewController {
    
    private var categories: [String] = []
    var categoriesTableViewControllerDelegate: CategoriesTableViewControllerDelegate?
    
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let category = self.categories[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cellCategory", forIndexPath: indexPath) as! CategoryTableViewCell
        cell.categoryNameLabel.text = category
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // Trigger delegate.
        self.categoriesTableViewControllerDelegate?.didSelectRowAtIndexPath(self.categories[indexPath.row])
        // Clear tableView.
        self.filterCategoriesForSearchText("")
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.categoriesTableViewControllerDelegate?.scrollViewWillBeginDragging()
    }
    
    // MARK: Helpers
    
    private func filterCategoriesForSearchText(text: String) {
        let trimmedText = text.trimm()
        if trimmedText.isEmpty {
            self.categories = []
        } else {
            if self.categories.isEmpty {
                self.categories.insert(trimmedText, atIndex: 0)
            } else {
               self.categories[0] = trimmedText
            }
        }
        self.tableView.reloadData()
    }
}

extension CategoriesTableViewController: CategoriesTextFieldDelegate {
    
    func textFieldChanged(text: String) {
        self.filterCategoriesForSearchText(text)
    }
}
