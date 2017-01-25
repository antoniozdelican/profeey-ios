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
        // Don't show empty sections.
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
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
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellAddCategory", for: indexPath) as! AddCategoryTableViewCell
            cell.addCategoryTextField.text = self.categoryName
            cell.addCategoryTableViewCellDelegate = self
            return cell
        case 1:
            if self.isShowingPopularCategories {
                if self.isSearchingPopularCategories {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                    cell.activityIndicator.startAnimating()
                    // TODO update text.
                    return cell
                }
                if self.popularCategories.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                    return cell
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory", for: indexPath) as! CategoryTableViewCell
                let category = self.popularCategories[indexPath.row]
                cell.categoryNameLabel.text = category.categoryName
                cell.numberOfPostsLabel.text = category.numberOfPostsString
                return cell
            } else {
                if self.isSearchingRegularCategories {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                    cell.activityIndicator.startAnimating()
                    // TODO update text.
                    return cell
                }
                if self.regularCategories.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                    return cell
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory", for: indexPath) as! CategoryTableViewCell
                let category = self.regularCategories[indexPath.row]
                cell.categoryNameLabel.text = category.categoryName
                cell.numberOfPostsLabel.text = category.numberOfPostsString
                return cell
            }
        default:
            return UITableViewCell()
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        }
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "tableSectionHeader") as? TableSectionHeader
        header?.titleLabel.text = self.isShowingPopularCategories ? "POPULAR" : "BEST MATCHES"
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1.0
        }
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func addButtonTapped(_ sender: AnyObject) {
        self.categoryName = self.categoryName?.replacingOccurrences(of: "_", with: " ")
        self.categoriesTableViewControllerDelegate?.didSelectCategory(self.categoryName)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helpers
    
    fileprivate func filterCategories(_ namePrefix: String) {
        // Clear old.
        self.regularCategories = []
        self.regularCategories = self.popularCategories.filter({
            (category: Category) in
            if let searchCategoryName = category.categoryName?.lowercased(), searchCategoryName.hasPrefix(namePrefix.lowercased()) {
                return true
            } else {
                return false
            }
        })
        self.regularCategories = self.sortCategories(self.regularCategories)
        self.isSearchingRegularCategories = false
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
        }
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
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                    }
                } else {
                    guard let awsCategories = response?.items as? [AWSCategory] else {
                        UIView.performWithoutAnimation {
                            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                        }
                        return
                    }
                    for awsCategory in awsCategories {
                        let category = Category(categoryName: awsCategory._categoryName, numberOfPosts: awsCategory._numberOfPosts)
                        self.popularCategories.append(category)
                    }
                    self.popularCategories = self.sortCategories(self.popularCategories)
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                    }
                }
            })
        })
    }
}

extension CategoriesTableViewController: AddCategoryTableViewCellDelegate {
    
    func addCategoryTextFieldChanged(_ text: String) {
        var categoryName = text.trimm()
        categoryName = categoryName.replacingOccurrences(of: "_", with: " ")
        if categoryName.isEmpty {
            self.isShowingPopularCategories = true
            // Clear old.
            self.regularCategories = []
            self.isSearchingRegularCategories = false
            UIView.performWithoutAnimation {
                self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
            }
            self.categoryName = nil
        } else {
            self.isShowingPopularCategories = false
            // Clear old.
            self.regularCategories = []
            self.isSearchingRegularCategories = true
            UIView.performWithoutAnimation {
                self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
            }
            self.categoryName = categoryName
            self.filterCategories(categoryName)
        }
    }
}
