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
    func didSelectCategory(_ categoryName: String?)
}

class CategoriesTableViewController: UITableViewController {
    
    var categoryName: String?
    var isStatusBarHidden: Bool = false
    var categoriesTableViewControllerDelegate: CategoriesTableViewControllerDelegate?
    fileprivate var categories: [Category] = []
    fileprivate var allCategories: [Category] = []
    fileprivate var searchedCategories: [Category] = []
    fileprivate var isSearching: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        
        self.isSearching = true
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
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if self.isSearching {
                return 1
            }
            if self.categories.count == 0 {
                return 1
            }
            return self.categories.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellAddCategory", for: indexPath) as! AddCategoryTableViewCell
            if self.categoryName != nil {
                cell.addCategoryTextField.text = self.categoryName
            }
            cell.addCategoryTableViewCellDelegate = self
            return cell
        case 1:
            if self.isSearching {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                cell.activityIndicator.startAnimating()
                return cell
            }
            if self.categories.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory", for: indexPath) as! CategoryTableViewCell
            let category = self.categories[indexPath.row]
            cell.categoryNameLabel.text = category.categoryName
            cell.numberOfPostsLabel.text = category.numberOfPostsString
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is CategoryTableViewCell {
            self.categoriesTableViewControllerDelegate?.didSelectCategory(self.categories[indexPath.row].categoryName)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 52.0
        case 1:
            return 64.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 52.0
        case 1:
            return 64.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1.0
        }
        return 12.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func addButtonTapped(_ sender: AnyObject) {
        self.categoriesTableViewControllerDelegate?.didSelectCategory(self.categoryName)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: AWS
    
    fileprivate func scanCategories() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanCategoriesDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearching = false
                if let error = error {
                    print("scanCategories error: \(error)")
                    self.reloadCategoriesSection()
                } else {
                    guard let awsCategories = response?.items as? [AWSCategory] else {
                        self.reloadCategoriesSection()
                        return
                    }
                    for awsCategory in awsCategories {
                        let category = Category(categoryName: awsCategory._categoryName, searchCategoryName: awsCategory._searchCategoryName, numberOfPosts: awsCategory._numberOfPosts)
                        self.allCategories.append(category)
                    }
                    self.categories = self.allCategories
                    self.reloadCategoriesSection()
                }
            })
        })
    }
    
    // MARK: Helper
    
    fileprivate func filterCategories(_ searchText: String) {
        self.searchedCategories = self.allCategories.filter({
            (category: Category) in
            if let searchCategoryName = category.searchCategoryName, searchCategoryName.hasPrefix(searchText.lowercased()) {
                return true
            } else {
                return false
            }
        })
        self.categories = self.searchedCategories
        self.reloadCategoriesSection()
    }
    
    fileprivate func reloadCategoriesSection () {
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
        }
    }
}

extension CategoriesTableViewController: AddCategoryTableViewCellDelegate {
    
    func addCategoryTextFieldChanged(_ text: String) {
        let categoryName = text.trimm()
        if categoryName.isEmpty {
            self.categories = self.allCategories
            self.reloadCategoriesSection()
            self.categoryName = nil
        } else {
            self.filterCategories(categoryName)
            self.categoryName = categoryName
        }
    }
}
