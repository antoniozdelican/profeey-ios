//
//  CategoriesTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB

protocol CategoriesTableViewControllerDelegate {
    
    func didSelectCategory(categoryName: String)
}

class CategoriesTableViewController: UITableViewController {
    
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    fileprivate var searchedCategories: [Category] = []
    fileprivate var popularCategories: [Category] = []
    fileprivate var showPopularCategories: Bool = true
    
    var categoriesTableViewControllerDelegate: CategoriesTableViewControllerDelegate?
    var isStatusBarHidden: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addButton.isEnabled = false
        self.scanCategories()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.isStatusBarHidden
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showPopularCategories {
            return self.popularCategories.count
        } else {
            return self.searchedCategories.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = self.showPopularCategories ? self.popularCategories[indexPath.row] : self.searchedCategories[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory", for: indexPath) as! CategoryTableViewCell
        cell.categoryNameLabel.text = category.categoryName
        cell.numberOfPostsLabel.text = category.numberOfPostsString
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! HeaderTableViewCell
        cell.headerTitle.text = self.showPopularCategories ? "RECENT" : "BEST MATCHES"
        cell.contentView.backgroundColor = Colors.greyLight
        cell.contentView.alpha = 0.95
        return cell.contentView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is CategoryTableViewCell {
            let category = self.showPopularCategories ? self.popularCategories[indexPath.row] : self.searchedCategories[indexPath.row]
            guard let categoryName = category.categoryName else {
                return
            }
            self.categoriesTableViewControllerDelegate?.didSelectCategory(categoryName: categoryName)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 0.0)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func addButtonTapped(_ sender: AnyObject) {
        guard let text = self.categoryTextField.text else {
            return
        }
        let categoryName = text.trimm()
        self.categoriesTableViewControllerDelegate?.didSelectCategory(categoryName: categoryName)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func categoryTextFieldChanged(_ sender: AnyObject) {
        guard let text = self.categoryTextField.text else {
            return
        }
        let categoryName = text.trimm()
        if categoryName.isEmpty {
            self.showPopularCategories = true
            self.tableView.reloadData()
            self.addButton.isEnabled = false
        } else {
            self.showPopularCategories = false
            self.searchedCategories = []
            self.tableView.reloadData()
            self.addButton.isEnabled = true
            self.scanCategoriesByCategoryName(categoryName)
        }
    }
    
    // MARK: AWS
    
    fileprivate func scanCategories() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanCategoriesDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    print("scanCategories error: \(error)")
                } else {
                    guard let awsCategories = response?.items as? [AWSCategory], awsCategories.count > 0 else {
                        return
                    }
                    for awsCategory in awsCategories {
                        let category = Category(categoryName: awsCategory._categoryName, numberOfPosts: awsCategory._numberOfPosts)
                        self.popularCategories.append(category)
                    }
                    self.tableView.reloadData()
                }
            })
        })
    }
    
    fileprivate func scanCategoriesByCategoryName(_ categoryName: String) {
        let searchCategoryName = categoryName.lowercased()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanCategoriesByCategoryNameDynamoDB(searchCategoryName, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    print("scanCategoriesByCategoryName error: \(error)")
                } else {
                    guard let awsCategories = response?.items as? [AWSCategory], awsCategories.count > 0 else {
                        return
                    }
                    self.searchedCategories = []
                    for awsCategory in awsCategories {
                        let category = Category(categoryName: awsCategory._categoryName, numberOfPosts: awsCategory._numberOfPosts)
                        self.searchedCategories.append(category)
                    }
                    self.tableView.reloadData()
                }
            })
        })
    }
}
