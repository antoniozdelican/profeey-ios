//
//  CategoriesTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB

protocol CategoriesTableViewControllerDelegate: class {
    func didSelectCategory(_ categoryName: String?)
}

class CategoriesTableViewController: UITableViewController {
    
    @IBOutlet weak var addCategoryTextField: UITextField!
    
    var categoryName: String?
    var isStatusBarHidden: Bool = false
    weak var categoriesTableViewControllerDelegate: CategoriesTableViewControllerDelegate?
    
    fileprivate var popularCategories: [Category] = []
    fileprivate var regularCategories: [Category] = []
    fileprivate var isSearchingPopularCategories: Bool = false
    fileprivate var isSearchingRegularCategories: Bool = false
    fileprivate var isShowingPopularCategories: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        self.tableView.register(UINib(nibName: "TableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "tableSectionHeader")
        self.addCategoryTextField.text = self.categoryName?.replacingOccurrences(of: "_", with: " ")
        
        self.isShowingPopularCategories = true
        self.isSearchingPopularCategories = true
        self.scanCategories()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
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
        if self.isShowingPopularCategories {
            if self.isSearchingPopularCategories {
                return 1
            }
            if self.popularCategories.count == 0 {
                return 1
            }
            return self.popularCategories.count
        } else {
            if self.isSearchingRegularCategories {
                return 1
            }
            if self.regularCategories.count == 0 {
                return 1
            }
            return self.regularCategories.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isShowingPopularCategories {
            if self.isSearchingPopularCategories {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                cell.activityIndicator.startAnimating()
                return cell
            }
            if self.popularCategories.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategoryNew", for: indexPath) as! CategoryNewTableViewCell
                if let newCategoryName = self.addCategoryTextField.text {
                    cell.categoryNameLabel.text = "\"\(newCategoryName)\""
                } else {
                    cell.categoryNameLabel.text = "No results found"
                }
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory", for: indexPath) as! CategoryTableViewCell
            let category = self.popularCategories[indexPath.row]
            cell.categoryNameLabel.text = category.categoryNameWhitespace
            cell.numberOfPostsLabel.text = category.numberOfPostsString
            return cell
        } else {
            if self.isSearchingRegularCategories {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                cell.activityIndicator.startAnimating()
                return cell
            }
            if self.regularCategories.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategoryNew", for: indexPath) as! CategoryNewTableViewCell
                if let newCategoryName = self.addCategoryTextField.text {
                    cell.categoryNameLabel.text = "\"\(newCategoryName)\""
                } else {
                    cell.categoryNameLabel.text = "No results found"
                }
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory", for: indexPath) as! CategoryTableViewCell
            let category = self.regularCategories[indexPath.row]
            cell.categoryNameLabel.text = category.categoryNameWhitespace
            cell.numberOfPostsLabel.text = category.numberOfPostsString
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is CategoryTableViewCell {
            let selectedCategory = self.isShowingPopularCategories ? self.popularCategories[indexPath.row] : self.regularCategories[indexPath.row]
            self.categoriesTableViewControllerDelegate?.didSelectCategory(selectedCategory.categoryName)
            self.dismiss(animated: true, completion: nil)
        }
        if cell is CategoryNewTableViewCell, let newCategoryName = self.addCategoryTextField.text  {
            // If new category, create with appropriate categoryName.
            let newCategoryNameUnderscore = newCategoryName.trimm().replacingOccurrences(of: " ", with: "_")
            self.categoriesTableViewControllerDelegate?.didSelectCategory(newCategoryNameUnderscore)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isShowingPopularCategories {
            if self.isSearchingPopularCategories {
                return 64.0
            }
            if self.popularCategories.count == 0 {
                return 64.0
            }
            return UITableViewAutomaticDimension
        } else {
            if self.isSearchingRegularCategories {
                return 64.0
            }
            if self.regularCategories.count == 0 {
                return 64.0
            }
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "tableSectionHeader") as? TableSectionHeader
        if self.isSearchingPopularCategories || self.isSearchingRegularCategories {
            header?.titleLabel.text = nil
        } else {
            if self.isShowingPopularCategories {
                header?.titleLabel.text = self.popularCategories.count != 0 ? "POPULAR" : "CREATE SKILL"
            } else {
                header?.titleLabel.text = self.regularCategories.count != 0 ? "BEST MATCHES" : "CREATE SKILL"
            }
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func addCategoryTextFieldChanged(_ sender: AnyObject) {
        guard let text = self.addCategoryTextField.text else {
            return
        }
        var categoryName = text.trimm()
        categoryName = categoryName.replacingOccurrences(of: "_", with: " ")
        if categoryName.isEmpty {
            self.isShowingPopularCategories = true
            // Clear old.
            self.regularCategories = []
            self.isSearchingRegularCategories = false
            self.tableView.reloadData()
            self.categoryName = nil
        } else {
            self.isShowingPopularCategories = false
            // Clear old.
            self.regularCategories = []
            self.isSearchingRegularCategories = true
            self.tableView.reloadData()
            self.categoryName = categoryName
            self.filterCategories(categoryName)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helpers
    
    fileprivate func filterCategories(_ name: String) {
        // Clear old.
        self.regularCategories = []
        self.regularCategories = self.popularCategories.filter({
            (category: Category) in
            if let searchCategoryName = category.categoryName?.lowercased(), searchCategoryName.contains(name.lowercased()) {
                return true
            } else {
                return false
            }
        })
        self.regularCategories = self.sortCategories(self.regularCategories)
        self.isSearchingRegularCategories = false
        self.tableView.reloadData()
    }
    
    fileprivate func sortCategories(_ categories: [Category]) -> [Category] {
        return categories.sorted(by: {
            (category1, category2) in
            return category1.numberOfPostsInt > category2.numberOfPostsInt
        })
    }
    
    // MARK: AWS
    
    fileprivate func scanCategories() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanCategoriesDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingPopularCategories = false
                if let error = error {
                    print("scanCategories error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsCategories = response?.items as? [AWSCategory] else {
                        self.tableView.reloadData()
                        return
                    }
                    for awsCategory in awsCategories {
                        let category = Category(categoryName: awsCategory._categoryName, numberOfPosts: awsCategory._numberOfPosts)
                        self.popularCategories.append(category)
                    }
                    self.popularCategories = self.sortCategories(self.popularCategories)
                    self.tableView.reloadData()
                }
            })
        })
    }
}
