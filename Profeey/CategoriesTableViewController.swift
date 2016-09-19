//
//  CategoriesTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB

class CategoriesTableViewController: UITableViewController {
    
    @IBOutlet weak var categoryTextField: UITextField!
    
    private var categories: [Category] = []
    private var popularCategories: [Category] = []
    var categoryName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let categoryName = self.categoryName {
            self.categoryTextField.text = categoryName
            self.scanCategoriesByCategoryName(categoryName)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.categoryTextField.resignFirstResponder()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let text = self.categoryTextField.text else {
            return 0
        }
        return text.isEmpty ? self.popularCategories.count : self.categories.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let text = self.categoryTextField.text else {
            return UITableViewCell()
        }
        let searchText = text.trimm()
        let cell = tableView.dequeueReusableCellWithIdentifier("cellCategory", forIndexPath: indexPath) as! CategoryTableViewCell
        let category = searchText.isEmpty ? self.popularCategories[indexPath.row] : self.categories[indexPath.row]
        cell.categoryNameLabel.text = category.categoryName
        cell.numberOfPostsLabel.text = category.numberOfPostsString
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let text = self.categoryTextField.text else {
            return nil
        }
        let searchText = text.trimm()
        let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader") as! HeaderTableViewCell
        cell.headerTitle.text = searchText.isEmpty ? "POPULAR" : "BEST MATCHES"
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is CategoryTableViewCell {
            // Update category and unwind to EditPostVc
            // WONT WORK IF POPULAR ARE USED!
            self.categoryName = self.categories[indexPath.row].categoryName
            self.performSegueWithIdentifier("segueUnwindToEditPostVc", sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
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
        self.categoryTextField.resignFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        // Update category and unwind to EditPostVc
        self.categoryName = self.categoryTextField.text?.trimm()
        self.performSegueWithIdentifier("segueUnwindToEditPostVc", sender: self)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func categoryTextFieldChanged(sender: AnyObject) {
        guard let text = self.categoryTextField.text else {
            return
        }
        let searchText = text.trimm()
        if searchText.isEmpty {
            // Show popularCategories.
            self.tableView.reloadData()
        } else {
            // Do the search!
            self.scanCategoriesByCategoryName(searchText)
        }
    }
    
    // MARK: AWS
    
    private func scanCategoriesByCategoryName(searchText: String) {
        let searchCategoryName = searchText.lowercaseString
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanCategoriesByCategoryNameDynamoDB(searchCategoryName, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("scanCategoriesByCategoryName error: \(error)")
                } else {
                    guard let awsCategories = response?.items as? [AWSCategory] else {
                        return
                    }
                    var searchedCategories: [Category] = []
                    for awsCategory in awsCategories {
                        let category = Category(categoryName: awsCategory._categoryName, numberOfPosts: awsCategory._numberOfPosts)
                        searchedCategories.append(category)
                    }
                    self.categories = searchedCategories
                    self.tableView.reloadData()
                }
            })
        })
        
    }
}
